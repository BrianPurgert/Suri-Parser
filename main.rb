require 'roda'
require 'json'
require 'addressable'
require 'ferrum'
require 'nokogiri'
require_relative 'lib/data_file'
require_relative 'lib/methods'
require 'amazing_print'
puts "#{'❄️' * 50}"

SAMPLE_URL = 'https://getthis.page/test_page.html'

class Main < Roda
	plugin :json, serializer: proc { |o| JSON.pretty_generate(o) }
	plugin :render
	plugin :request_headers
	plugin :public
	plugin :exception_page
	plugin :hooks
	plugin(:error_handler) { |e| exception_page e, json: false }

	route do |r|
		response['Access-Control-Allow-Origin'] = '*'
		r.public

		r.root do
			render('index')
		end

		r.on 'm' do
			url      = parse_and_normalize_url(r.params['url'])
			body     = fetch_body(url.to_s)
			document = rewrite_urls_in_document(Nokogiri.parse(body), url)
			document.to_s
		end

		r.on 'api' do
			url      = parse_and_normalize_url(r.params['url'])
			body     = fetch_body(url.to_s)
			datafile = DataFile.new(body, url)
			response = datafile.to_h
			save_response_as_json(response, url)
			response
		end
	end

	# private

	def parse_and_normalize_url(param_url)
		test_url = param_url.nil? ? SAMPLE_URL : param_url
		test_url = Addressable::URI.unencode(test_url.tr("+", " "))
		Addressable::URI.heuristic_parse(test_url).normalize
	end

	def rewrite_urls_in_document(document, base_url)
		document.css('a').each do |link|
			href         = link.attribute('href').to_s
			link['href'] = base_url.join(href).to_s unless href.empty?
		end
		document.css('img').each do |img|
			src        = img.attribute('src').to_s
			img['src'] = base_url.join(src).to_s unless src.empty?
		end
		document
	end

	def save_response_as_json(response, uri)
		name = "#{uri.host}#{uri.path}#{uri.query_values}".gsub(/[^0-9A-Za-z.-]/, '_')
		path = File.expand_path("../datafiles/#{name}.json", __FILE__)
		File.write(path, JSON.pretty_generate(response))
	end
end
