# To use with thin
#  thin start -p PORT -R config.ru
require File.join(File.dirname(__FILE__), 'lib', 'call_fwd')

trap(:INT) { exit }

app = Rack::Builder.new {
 use Rack::CommonLogger
 run CallFwd::App
}.to_app

run app

require 'launchy'

Launchy::Browser.run("http://localhost:9292")