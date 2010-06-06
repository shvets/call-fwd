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

    get '/login' do
      haml :login
    end

    post "/login" do
      service = CallFwdService.new request[:username], request[:password]
      if service.login()
        session[:logged_in] = true
        session[:usrename] = request[:username]
        session[:password] = request[:password]
        session[:phone] = service.phone_number
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
      session[:phone] = nil
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
          message = service.enable
        end

        if request[:fwd_flag] == 'false'
          message = service.disable
        end

        session[:message] = message

        redirect "/"
      end
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

