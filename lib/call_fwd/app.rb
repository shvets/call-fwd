require 'rubygems' unless RUBY_VERSION =~ /1.9.*/

require 'sinatra/base'
require 'haml'
require 'sass'
require 'nokogiri'
require 'mechanize'

$:.unshift(File.expand_path(File.join(File.dirname(__FILE__))))

module CallFwd
  class App < Sinatra::Base

    set :haml, {:format => :html5, :attr_wrapper => '"'}
    set :views, File.dirname(__FILE__) + '/../../views'
    #set :public, File.dirname(__FILE__) + '/../../public'
    set :sessions, true

    get '/stylesheet.css' do
      headers 'Content-Type' => 'text/css; charset=utf-8'
      sass :stylesheet
    end

    get '/favicon.ico' do
      File.open(File.dirname(__FILE__) + '/../../views/favicon.ico', "rb") {|io| io.read }
    end

    get '/login' do
      haml :login
    end

    post "/login" do
      service = CallFwdService.new request[:username], request[:password]
      if service.login()
        phone_number, forwarding_number, rings_for_seconds = *service.customer_info
        
        session[:logged_in] = true
        session[:usrename] = request[:username]
        session[:password] = request[:password]
        session[:phone_number] = phone_number
        session[:forwarding_number] = forwarding_number
        session[:rings_for_seconds] = rings_for_seconds
        session[:message] = nil

        redirect "/"
      else
        redirect "login"
      end
    end

    get '/logout' do
      session[:logged_in] = false
      session[:usrename] = nil
      session[:password] = nil
      session[:phone_number] = nil
      session[:forwarding_number] = nil
      session[:rings_for_seconds] = nil
      session[:message] = nil

      haml :login
    end

    get '/' do
      authenticate do
        haml :index
      end
    end

    post "/call_fwd" do
      authenticate do
        service = CallFwdService.new request[:username], request[:password]

        message = ""

        if request[:fwd_flag] == 'true'
          message = service.enable request[:forwarding_number], request[:rings_for_seconds]
          session[:forwarding_number] = request[:forwarding_number]
          session[:rings_for_seconds] = request[:rings_for_seconds]
        end

        if request[:fwd_flag] == 'false'
          message = service.disable
        end

        session[:message] = message

        redirect "/"
      end
    end

    helpers do
      include CallFwdHelper
    end

    private

    def authenticate
      if session[:logged_in].nil?
        redirect "/login"
      else
        yield
      end
    end
  end
end

