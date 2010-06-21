Webrat.configure do |config|
  config.mode = :mechanize
end

# disable file logging for heroku
module Webrat
  module Logging #:nodoc:

    def logger # :nodoc:
      Logger.new(STDOUT)
    end
  end
end

include CallFwdHelper

class CallFwdService
  include Webrat::Methods

  HOME_URL = "https://secure.vonage.com/webaccount"
  LOGIN_URL = "#{HOME_URL}/public/login.htm"
  FEATURES_URL = "#{HOME_URL}/features/index.htm"
  CALL_FORWARDING_URL = "#{HOME_URL}/features/callforwarding/edit.htm"

  def initialize username, password
    @username = username
    @password = password
    @logged_in = false
  end

  def login
    if not @logged_in
      visit(LOGIN_URL)

      fill_in('username', :with => @username)
      fill_in('password', :with => @password)

      response = click_button("Sign In")

      if response.header['set-cookie'].nil?
        @logged_in = false
      else
        @logged_in = true
      end
    end
  end

  def logout
    if @logged_in
      visit(HOME_URL)

      click_link("Logout")
    end
  end

  def customer_info
    if @logged_in
      response = visit(HOME_URL)

      did = extract_phone_number(response.body)

      response = visit("#{CALL_FORWARDING_URL}?did=#{did}&callForwardingButton=Configure")

      forwarding_number = extract_forwarding_number(response.body)
      rings_for_seconds = extract_rings_for_seconds(response.body)

      logout

      [did, forwarding_number, rings_for_seconds]
    end
  end

  def enable forwarding_number=nil, call_forwarding_seconds=nil
    if not login
      message = "Incorrect login info!"
    else
      response = visit(HOME_URL)

      did = extract_phone_number(response.body)

      click_link("Features")

      visit("#{CALL_FORWARDING_URL}?did=#{did}&callForwardingButton=Configure")

      set_hidden_field 'enableCallForwarding', :to => true

      select /#{call_forwarding_seconds_as_text(call_forwarding_seconds.to_i)}/, :from => 'callForwardingSeconds' unless call_forwarding_seconds.nil?
      fill_in "singleAddress", :with => forwarding_number unless forwarding_number.nil?

      begin
        click_button("Enable")

        message = "Call Forwarding is enabled"
      rescue Webrat::NotFoundError
        begin
          click_button("Save Changes")
          message = "Call Forwarding is updated"
        rescue Webrat::NotFoundError
          message = "Call Forwarding is already enabled"
        end
      end

      logout
    end

    message.nil? ? "" : message
  end

  def disable
    if not login
      message = "Incorrect login info!"
    else
      response = visit(HOME_URL)

      did = extract_phone_number(response.body)

      click_link("Features")

      visit("#{CALL_FORWARDING_URL}?saved=true&did=#{did}")

      begin
        click_button("Disable")

        message = "Call Forwarding is disabled"
      rescue Webrat::NotFoundError
        message = "Call Forwarding is already disabled"
      end

      logout
    end

    message.nil? ? "" : message
  end

  private

  def extract_phone_number html
    doc = Nokogiri::HTML(html)

    doc.css(".snippet_col_normal_right").text.gsub(/(\(|\)|-|\n|\r|\t)/, '')
  end

  def extract_forwarding_number html
    doc = Nokogiri::HTML(html)

    doc.css("#CFConfig .CFRowForward .CFField").at(0).attribute('value').text
  end

  def extract_rings_for_seconds html
    doc = Nokogiri::HTML(html)

    selected_option = doc.css("#CFConfig .CFRowDelay select/option").reject do |item|
      item.attribute("selected").nil?
    end

    selected_option[0].attribute('value').text
  end
end


