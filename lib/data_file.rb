require 'nokogiri'
require 'addressable'
require 'json'
require 'colorize'
require 'benchmark'
require 'amazing_print'
require 'deep_merge'
# Heuristic HTML Parser
DELETE_FROM_DATA_ARRAY = [' ', ''].freeze

class DataFile
	# @param [String] html
	# @param [String] url
	# @param [String] content_type
	def initialize(html, url, content_type = nil)
		@time       = Time.now
		@url        = Addressable::URI.parse(url).normalize
		@links      = []
		@data_array = [{ url: @url.to_s, page: @url.basename }]
		@dom_uri    = {}
		@debug      = []
		xml(html)
	end

	def elapsed
		(@time - Time.now).to_s
	end

	def links
		arr = []
		search(['?']).each do |element| element.values.each do |att| arr << att.to_s
		end
		end
		arr
	end

	# @param [Object] attributes
	def having(attributes)
		puts "having: #{attributes}".colorize(:red)
		xpath = './/@*'
		attributes.each do |attribute| xpath = xpath + "[contains(., '#{attribute}')]"
		end
		@doc.xpath(xpath)
	end

	# @return [Float]
	def ⏱
		if @r0.nil?
			@r0 = Process.clock_gettime(Process::CLOCK_MONOTONIC)
		else puts "stopwatch: #{Process.clock_gettime(Process::CLOCK_MONOTONIC) - @r0}s"
		@r0 = Process.clock_gettime(Process::CLOCK_MONOTONIC)
		end
	end

	def parse_xp_node(xp_node)
		urls = xp_node.xpath('.//@href').map { |a| a.to_s }.compact.uniq.sort!
		urls = urls.first unless urls.size > 1
		out  = { url: urls }
		xp_node.traverse do |node| if node.text?
			                           text = node.text.strip
			                           unless text.empty?
				                           out.deep_merge({ content: [text] }, merge_hash_arrays: true)
			                           end
		                           end
		xp_node.values.each do |attribute_value| begin
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
		base_uris = @doc.xpath("//body//@href[contains(.,'?') and contains(.,'=')]").map do |link| (link.text.include? "'") ? nil : link.text
		end.uniq.compact
		add_debug(base_uris)
		queries = {}
		base_uris.each do |link| dirty_q = link.split('?').last
		dirty_h                          = {}
		dirty_q.split('&').each { |kv_str| dirty_h[kv_str.split('=').first] = kv_str.split('=').last }
		import_q = dirty_h
		queries.update(import_q) { |k, v1, v2| Array(v1) | Array(v2) }
		end
		ap queries
		add_debug(queries)
		@xpath_data_queue = Queue.new
		xpath_threads     = []
		puts "queries: #{ queries.size }"
		queries.each_pair do |k, a| xpath_threads << Thread.new(@doc) { |doc_copy| a = (a.is_a? Array) ? a : Array(a)
		a.each do |v| xp = kv_xpath(k, v)
		xp_nodes         = doc_copy.xpath(xp)
		unless xp_nodes.nil?
			xp_nodes.each { |xp_node| pxn = parse_xp_node(xp_node)
			kv_node                       = { k => { decode(v) => pxn } }
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

	# @param [Addressable::URI] gsa_uri
	def unique_value_dom_grouping(gsa_uri)
		print_header 'unique_value_dom_grouping'
		inner_xquery              = gsa_uri.queries(false).map { |url_key, url_value| url_value = encode(url_value)
		".//*[ count(./@href[contains(.,'#{url_key}')]) = count(.//@href[contains(.,'#{url_value}')]) and count(parent::*//@href[contains(.,'#{url_key}')]) > count(parent::*//@*[contains(.,'#{url_value}')]) ]"
		}.join(' and ')
		xquery_uri_unique_parents = ".//*[#{inner_xquery}]"
		add_debug([xquery_uri_unique_parents, @doc.xpath(xquery_uri_unique_parents).count])
		@doc.xpath(xquery_uri_unique_parents).each { |uri_unique_parent| add_debug({ "#{gsa_uri.queries.to_s}" => uri_unique_parent.xpath('.//text()').text.strip.split(/\s{2,}/)
		                                                                           })
		}
	end

	def uri_unique_data_capture(gsa_uri)
		inner_xquery              = gsa_uri.queries(false).map { |url_key, url_value| url_value = encode(url_value)
		".//*[count(.//@*[contains(.,'#{url_key}=#{url_value}')]) >=1 and count(parent::*//@*[contains(.,'#{url_key}=#{url_value}')]) < count(parent::*//@*[contains(.,'#{url_key}=')]) ]"
		}.join(' and ')
		xquery_uri_unique_parents = ".//*[#{inner_xquery}]"
		add_debug([xquery_uri_unique_parents, @doc.xpath(xquery_uri_unique_parents).count])
		@doc.xpath(xquery_uri_unique_parents).each { |uri_unique_parent| add_debug({ "#{gsa_uri.queries.to_s}" => uri_unique_parent.xpath('.//text()').text.strip.split(/\s{2,}/) })
		}
	end

	def extract_table_transposed
		@doc.search('//table[count(.//table)=0 and count(.//tr[1]//td)=2 and count(.//tr[last()]//td)=2]//tr[count(td)=2]').each do |row| pair = row.search('td').map { |td| td.text.squeeze(' ').strip }
		key                                                                                                                                    = to_column(pair[0])
		unless pair[1].empty? || pair[1] == ' ' || key.nil? || key.empty?
			key_pair = { key => soft_clean(pair[1]) }
			ap key_pair
			@data_array << key_pair
		end
		row.replace('')
		end
	end

	def extract_each_line
		kv        = {}
		last_line = ''
		str_doc   = @doc.to_str
		str_doc.each_line do |line| line = soft_clean(line)
		if line
			if last_line.end_with? ':'
				kv[to_column(last_line.chomp(':'))] = line
			end
			last_line = line
		end
		end
		ap kv
		@data_array << kv
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

	def soft_clean(dirty_string)
		str = dirty_string.gsub(/\s+/, ' ').strip
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

	def collect_comments
		out      = []
		comments = @doc.xpath('.//body//comment()')
		cols     = comments.map { |c| to_column(c.text)
		}
		comments.each { |c| if c.text.downcase.include? 'end'
			                    start_i = cols.find_index { |x| x == to_column(c.text.gsub(/(ends?)/i, '')) }
			                    if start_i
				                    comment = comments.at(start_i)
				                    if comment && c
					                    out << collect_between(comment, c)
				                    end
			                    end
		                    end
		}
		out
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
		data_hash
	end

	def promote(selector)
		@doc.xpath(selector).each { |node| @doc.at_xpath('//body').replace("<body>#{node}</body>")
		}
	end

	def unwrap(selector)
		@doc.search(selector).map { |node| txt = node.children.text.strip
		node.replace('')
		txt
		}.uniq
	end

	def children_text_array(selector)
		@doc.search(selector).map { |node| node.xpath('.//text()')
		txt = node.children.text.strip
		txt
		}.uniq
	end

	def replace_wrap(selector, delimiter = ['', "\n"])
		@doc.search(selector).each { |node| node.replace("#{delimiter[0]}#{node.children}#{delimiter[1]}") }
	end

	def add_data_array(data_array = [])
		@data_array << data_array
	end

	def clean_data_array
		@data_array.each { |inner_data_hash| inner_data_hash.delete_if { |k, v| DELETE_FROM_DATA_ARRAY.include? k
		}
		}
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

	def clean_nodes
		remove_nodes = ['script', "[type='text/javascript']", "[type='text/css']", 'noscript', 'button', 'link', 'br', '#sectionheader', 'meta', 'style']
		remove_nodes.each do |selector| @doc.css("#{selector}").remove
		end
	end

	def clean_attributes
		remove_attributes = %w(colspan bgcolor size width height border nowrap align target cellspacing cellpadding width border valign bgcolor style class bordercolor color)
		remove_attributes.each do |attribute| @doc.xpath(".//@#{attribute}").remove
		end
	end

	def collect_form_attributes
		@doc.xpath('.//body//form//*[@value or @name or @action]').each { |element| @data_array << element.to_h
		}
	end

	def extract_src
		@doc.xpath('.//body//*[@src]').each { |element| @data_array << element.to_h
		}
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
		# clean_document
		# clean_attributes
		print_header 'clean_nodes'
		# clean_nodes
		print_header 'extract_gsa_uri'
		puts Benchmark.realtime { extract_uri_with_params }
		# print_header 'table_transposed'
		# extract_table_transposed
		# print_header 'table data'
		# print_header 'strip_doc'
		extract_each_line
		collect_form_attributes
		extract_src
		print_header 'clean_data_array'
		# clean_data_array
	end
end


