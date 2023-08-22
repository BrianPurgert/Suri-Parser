require 'roda'
require 'json'
require 'ferrum'
require 'nokogiri'
require_relative 'lib/data_file'
require_relative 'lib/methods'


class Main < Roda

	plugin :json, serializer: proc { |o| JSON.pretty_generate(o) }
	plugin :render



	route do |r|
		r.root do
			render('index')
		end

		r.on 'm' do
			test_url = r.params['url'].nil? ? 'https://catalog.gsa.gov/help' : r.params['url']
			test_url = Addressable::URI.unencode(test_url.tr("+", " "))
			body     = fetch_body(test_url)
			document = Nokogiri.parse(body)
			document.css('script').remove
			document.css('style').remove
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
