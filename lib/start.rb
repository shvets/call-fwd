require 'rubygems' unless RUBY_VERSION =~ /1.9.*/

$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'haml'
require 'sass'
require 'webrat'

require 'mongrel'
require 'call_fwd/call_fwd_helper'
require 'call_fwd/call_fwd_service'
require 'call_fwd/app'

Rack::Handler::Mongrel.run CallFwd::App.new, :Port => 4567
