require 'roda'
require 'json'
require 'ferrum'
require 'nokogiri'
require_relative 'lib/data_file'
require_relative 'lib/methods'

SAMPLE_URL = 'https://getthis.page/test_page.html'

class Main < Roda

    plugin :json, serializer: proc { |o| JSON.pretty_generate(o) }
    plugin :render
    plugin :request_headers
    plugin :public
    plugin :exception_page
    plugin(:error_handler) { |e| exception_page e, json: true }

    route do |r|
        response['Access-Control-Allow-Origin'] = '*'
        r.public
        r.root do
            render('index')
        end

        r.on 'm' do
            test_url = r.params['url'].nil? ? SAMPLE_URL : r.params['url']
            test_url = Addressable::URI.unencode(test_url.tr("+", " "))
            url      = Addressable::URI.heuristic_parse(test_url).normalize

            body     = fetch_body(url.to_s)
            document = Nokogiri.parse(body)

            document.css('a').each do |link|
                href = link.attribute('href').to_s
                unless href.empty?
                    link['href'] = url.join(href).to_s
                end
            end
            document.css('img').each do |img|
                src = img.attribute('src').to_s
                unless src.empty?
                    img['src'] = url.join(src).to_s
                end
            end

            document.to_s
        end

        r.on 'api' do

            test_url = r.params['url'].nil? ? SAMPLE_URL : r.params['url']

            test_url = Addressable::URI.unencode(test_url.tr("+", " "))
            url      = Addressable::URI.heuristic_parse(test_url).normalize.to_s

            body = fetch_body(url)

            datafile = DataFile.new(body, url)
            datafile.to_h
        end

    end
end
