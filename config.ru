require 'rack'
require 'rack/unreloader'
require 'rack/static'
# Initialise the Unloader while passing the subclasses to unload
# every time it detects changes
Unreloader = Rack::Unreloader.new(subclasses: %w'Roda') { Main }
Unreloader.require './main.rb'
# Pass the favicon.ico location
use Rack::Static, urls: ['/favicon.ico']
run(Unreloader)
