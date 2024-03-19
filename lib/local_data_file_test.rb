require 'json'
require_relative 'data_file'

test_url = 'https://www.gsaelibrary.gsa.gov/ElibMain/scheduleSummary.do?scheduleNumber=MAS'

# body = File.read('/../public/test_page.html').to_s
body = File.read(__dir__ + '/../public/product_page.html').to_s

datafile = DataFile.new(body, test_url)

File.open("output.json", "w") { |f| f.write(JSON.pretty_generate(datafile.to_h)) }

ap datafile.to_h
