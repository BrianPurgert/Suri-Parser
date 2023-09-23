require 'nokogiri'
require 'addressable'
require 'json'
require 'colorize'
require 'benchmark'
require 'amazing_print'
require 'deep_merge'
# Heuristic HTML Parser

class DataFile

	def initialize(html, url, content_type = nil)
		@time = Time.now
		@url  = Addressable::URI.parse(url).normalize

		@data_array = []
		@debug      = []
		@xpaths     = []
		xml(html)
	end

	def parse_xp_node(xp_node)
		puts xp_node
		urls = xp_node.xpath('.//@href').map { |a| a.to_s }.compact.uniq.sort!
		urls = urls.first unless urls.size > 1
		out  = { url: urls }
		xp_node.traverse do |node|
			if node.text?
				text = node.text.strip
				unless text.empty?
					out.deep_merge({ content: [text] }, merge_hash_arrays: true)
				end
			end
			xp_node.values.each do |attribute_value|
				begin
					attribute_uri = Addressable::URI.parse(attribute_value)
					out.deep_merge(attribute_uri.query_values, merge_hash_arrays: true)
				rescue
					out = out.merge(attribute_value => 'ERROR')
				end
			end
		end
		out
	end

	def decode(encoded)
		Addressable::URI.unencode(encoded.tr("+", " "))
	end

	def extract_uri_with_params
		# get all url's containing a query string with field-value pairs
		base_uris = @doc.xpath("//body//@href[contains(.,'?') and contains(.,'=')]").map do |link|
			(link.text.include? "'") ? nil : link.text
		end.uniq.compact
		add_debug(base_uris)
		queries = {}
		base_uris.each do |link|
			dirty_q = link.split('?').last
			dirty_h = {}
			dirty_q.split('&').each { |kv_str| dirty_h[kv_str.split('=').first] = kv_str.split('=').last }
			import_q = dirty_h
			queries.update(import_q) { |k, v1, v2| Array(v1) | Array(v2) }
		end
		# ap queries
		@xpaths           = queries
		@xpath_data_queue = Queue.new
		xpath_threads     = []
		puts "queries: #{ queries.size }"
		queries.each_pair do |k, a|
			xpath_threads << Thread.new(@doc) { |doc_copy|
				a = (a.is_a? Array) ? a : Array(a)
				a.each do |v|
					xp       = kv_xpath(k, v)
					xp_nodes = doc_copy.xpath(xp)
					unless xp_nodes.nil?
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

	def as_column_name(key_string)
		# my contr'actorList   \  my contractorList  \ my_contractorList \   my_contractor_list   \
		key_string.to_s.gsub(/[^a-zA-Z0-9\s]/, "").gsub(/\s/, "_").gsub(/\B[A-Z][^A-Z]/, '_\&').downcase.squeeze("_").gsub(/^[^a-zA-Z0-9]+|[^a-zA-Z0-9]+$/, "")
	end

	def to_column(dirty_string)
		str = as_column_name(dirty_string)
		str = nil if (str.empty?) || (str.equal?(' '))
		str
	end

	def collect_between(first, last)
		result = [first]
		until first == last
			ap first
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
		@data_array.each { |h| #   :preserve_unmergeables  DEFAULT: false      Set to true to skip any unmergeable elements from source
			#   :knockout_prefix        DEFAULT: nil        Set to string value to signify prefix which deletes elements from existing element
			#   :overwrite_arrays       DEFAULT: false      Set to true if you want to avoid merging arrays
			#   :sort_merged_arrays     DEFAULT: false      Set to true to sort all arrays that are merged together
			#   :unpack_arrays          DEFAULT: nil        Set to string value to run "Array::join" then "String::split" against all arrays
			#   :merge_hash_arrays      DEFAULT: false      Set to true to merge hashes within arrays
			#   :keep_array_duplicates  DEFAULT: false      Set to true to preserve duplicate array entries
			#   :merge_debug            DEFAULT: false      Set to true to get console output of merge process for debugging
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

	def kv_xpath(k, v)
		xp = '//body//*[ '
		xp << "#{count("#{k}=#{v}")} > 0 and "
		xp << "#{count("#{k}=")} = #{count("#{k}=#{v}")} and "
		xp << "#{countp("#{k}=")} > #{countp("#{k}=#{v}")}"
		xp << ']'
		add_debug({ "#{k}=#{v}" => xp })
		xp
	end

	def collect_form_attributes
		@doc.xpath('.//body//form//*[@value or @name or @action]').each do |element|
			@data_array << { "collect_form_attributes": element.to_h }
		end
	end

	def from_json(json)
		# symbolize_names: true
		@data_array << JSON.parse(json).to_h
	end

	def print_header(heading)
		puts "\n"
		puts "| #{heading.upcase} |".center(100, "_").colorize(:cyan)
	end

	def xml(html)
		@doc = Nokogiri.parse(html)
		puts Benchmark.realtime { extract_uri_with_params }

		# collect_form_attributes
		# clean_data_array
	end
end


