require 'json'
require_relative 'data_file'

test_url = 'https://www.gsaelibrary.gsa.gov/ElibMain/scheduleSummary.do?scheduleNumber=MAS'

body = File.read('test_page.html').to_s
puts body

datafile = DataFile.new(body, test_url)

File.open("output.json", "w") { |f| f.write(JSON.pretty_generate(datafile.to_h)) }

ap datafile.to_h
