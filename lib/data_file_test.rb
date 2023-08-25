require 'ferrum'
require 'json'
require_relative 'data_file'

test_url = 'http://192.168.1.9/2017/84/PAGEproductdetaildo-GSIN11000040723989-CVIEWtrue-.html'

browser = Ferrum::Browser.new(timeout: 30, window_size: [1440, 900], process_timeout: 30, headless: false)
browser.go_to(test_url)
body       = browser.page.body.to_s
datafile   = DataFile.new(body, test_url)
input_hash = datafile.to_h
json_str   = JSON.generate(input_hash)
File.open("output.json", "w") do |file|
	file.write(json_str)
end
browser.quit