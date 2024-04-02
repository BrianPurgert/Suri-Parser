require 'nokogiri'
require 'addressable'
require 'json'
require 'colorize'
require 'benchmark'
require 'amazing_print'
require 'deep_merge'

class DataFile
	def initialize(html, url, content_type = nil)
		@time       = Time.now
		@url        = Addressable::URI.parse(url).normalize
		@data_array = []
		@debug      = []
		@xpaths     = []
		xml(html)
	end

	# 🚀 This function parses a provided xml node and extracts relevant information from it 🚀
	def parse_xp_node(xp_node)

		# 🌐 Gather all href attribute URLs, remove duplicates, and sort them 🌐
		urls = xp_node.xpath('.//@href').map { |a| a.to_s }.compact.uniq.sort!

		# 💡 If there is only one URL, use that instead of the array 💡
		urls = urls.first unless urls.size > 1

		# ✅ Initialize the output hash with the gathered URLs ✅
		out = { url: urls }

		# 🌀 Traverse through each node in the xp_node 🌀
		xp_node.traverse do |node|

			# 📋 If the node contains text, strip it of whitespace and add it to the output if it's not empty 📋
			if node.text?
				text = node.text.strip
				unless text.empty?
					out.deep_merge({ content: [text] }, merge_hash_arrays: true)
				end
			end

			# 🎯 For each attribute value in the node, parse it as a URI and merge it into the output. If an exception occurs, mark the attribute value with 'ERROR' 🎯
			xp_node.values.each do |attribute_value|
				begin
					attribute_uri = Addressable::URI.parse(attribute_value)
					out.deep_merge(attribute_uri.query_values, merge_hash_arrays: true)
				rescue
					out = out.merge(attribute_value => 'ERROR')
				end
			end
		end

		# 🔚 Return the final output hash 🔚
		out
	end

	def decode(encoded)
		Addressable::URI.unencode(encoded.tr("+", " "))
	end

	def extract_uri_with_params
		# 🎯 Extract urls containing query parameters from the document 🎯
		base_uris = @doc.xpath("//body//@href[contains(.,'?') and contains(.,'=')]").map do |link|
			(link.text.include? "'") ? nil : link.text
		end.uniq.compact
		add_debug(base_uris)
		queries = {}
		base_uris.each do |link|
			# 💡 Cleaning query parameters from url and generating a hash 💡
			dirty_q = link.split('?').last
			dirty_h = {}
			dirty_q.split('&').each { |kv_str| dirty_h[kv_str.split('=').first] = kv_str.split('=').last }
			import_q = dirty_h
			queries.update(import_q) { |k, v1, v2| Array(v1) | Array(v2) }
		end
		@xpaths           = queries
		@xpath_data_queue = Queue.new
		xpath_threads     = []
		puts "queries: #{ queries.size }"
		queries.each_pair do |k, a|
			xpath_threads << Thread.new(@doc) { |doc_copy|
				# 🚀 Launching threads to search xml doc for each query parameter key-value pair 🚀
				a = (a.is_a? Array) ? a : Array(a)
				a.each do |v|
					xp       = kv_xpath(k, v)
					xp_nodes = doc_copy.xpath(xp)
					unless xp_nodes.nil?
						# 🔍 Parsing each found xml node and placing the output in queue 🔍
						xp_nodes.each { |xp_node|
							pxn     = parse_xp_node(xp_node)
							kv_node = { k => { decode(v) => pxn } }
							@xpath_data_queue << kv_node
						}
					end
				end
			}
		end
		xpath_threads.each { |thread| thread.join }
		until @xpath_data_queue.empty?
			@data_array << @xpath_data_queue.deq
		end
	end

	def add_debug(info)
		ap info
		@debug << info
	end

	def collect_between(first, last)
		result = [first]
		until first == last
			# ap first
			first = first.next
			result << first
		end
		result
	end

	def concat(datafile)
		@data_array = @data_array.concat(datafile.to_a)
	end

	def to_a
		@data_array
	end

	def to_e
		@debug
	end

	def to_h
		data_hash = {}
		@data_array.each { |h|
			data_hash.deep_merge(h, sort_merged_arrays: false, merge_hash_arrays: false)
		}
		{ @url.to_s.to_sym => data_hash }
	end

	def count(attribute)
		"count(.//@href[contains(.,'#{attribute}')])"
	end

	def countp(attribute)
		"count(..//*[@href[contains(.,'#{attribute}')]]) "
	end

	# 🧮 This function generates and returns XPath expressions for searching specific key-value pairs within a document's body 🧮
	def kv_xpath(k, v)
		xp = '//body//*[ ' # 📍 Begin building XPath expression with a default starting point 📍
		xp << "#{count("#{k}=#{v}")} > 0 and " # 🗝️ Add condition: there must be at least one instance of the key=value pair 🗝️
		xp << "#{count("#{k}=")} = #{count("#{k}=#{v}")} and " # 🔐 Add condition: the count of instances of the key must equal the count of instances of the key=value pair 🔐
		xp << "#{countp("#{k}=")} > #{countp("#{k}=#{v}")}" # 🔎 Add condition: the count of parent nodes containing the key must be greater than the count of parent nodes containing the key=value pair 🔎
		xp << ']' # 📍 End the XPath expression 📍
		add_debug({ "#{k}=#{v}" => xp }) # 🕹️ Add the XPath expression to the debug information 🕹️
		xp # ⏭️ Return the generated XPath expression ⏭️
	end

	def collect_form_attributes
		@doc.xpath('.//body//form//*[@value or @name or @action]').each do |element|
			@data_array << { "collect_form_attributes": element.to_h }
		end
	end

	def xml(html)
		@doc = Nokogiri.parse(html)
		puts Benchmark.realtime { extract_uri_with_params }
	end
end


