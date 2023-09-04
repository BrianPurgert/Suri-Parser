require 'roda'
require 'json'
require 'ferrum'
require 'nokogiri'
require_relative 'lib/data_file'
require_relative 'lib/methods'

class Main < Roda

	plugin :json, serializer: proc { |o| JSON.pretty_generate(o) }
	plugin :render
	plugin :request_headers

	route do |r|
		response['Access-Control-Allow-Origin'] = '*'

		r.root do
			render('index')
		end

		r.on 'm' do
			test_url = r.params['url'].nil? ? 'https://gsaadvantage-test.fas.gsa.gov/advantage/ws/search/advantage_search?q=0:8desktop&db=0&searchType=0' : r.params['url']
			test_url = Addressable::URI.unencode(test_url.tr("+", " "))
			body     = fetch_body(test_url)
			document = Nokogiri.parse(body)

			document.to_s
		end

		r.on 'api' do
			test_url = r.params['url'].nil? ? 'https://gsaadvantage-test.fas.gsa.gov/advantage/ws/search/advantage_search?q=0:8desktop&db=0&searchType=0' : r.params['url']
			test_url = Addressable::URI.unencode(test_url.tr("+", " "))
			browser  = Ferrum::Browser.new(browser_options: { 'no-sandbox': nil })
			browser.go_to(test_url)
			body     = browser.page.body.to_s
			datafile = DataFile.new(body, test_url)
			browser.quit
			datafile.to_h
		end

	end
end
