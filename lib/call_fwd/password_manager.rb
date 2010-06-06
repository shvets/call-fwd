require "highline/import"

class PasswordManager
  def initialize file_name
    @file_name = file_name
  end

  def load_file
    File.exist?(@file_name) ? read_file : nil
  end

  def save_file username, password
    return if username.nil? or password.nil?

    File.open(@file_name, 'w') do |file|
      file.puts username
      file.puts password
    end
  end

  def delete_file
    File.delete @file_name if File.exist? @file_name
  end

  def read_file
    File.open(@file_name, 'r') { |file| [file.gets.chomp, file.gets.chomp] }
  end

  def self.ask_credentials
    password_manager = PasswordManager.new "#{ENV['HOME']}/.call_fwd"

    file = password_manager.load_file

    username = file.nil? ? "" : file[0]
    password = file.nil? ? "" : file[1]

    new_username = ask("Enter username (#{username}):  ")
    new_password = ask("Enter password (#{password.gsub(/./, '*')}): ")  { |q| q.echo = '*' }

    new_username = (new_username.nil? or new_username.strip.size == 0) ? username : new_username.chomp
    new_password = (new_password.nil? or new_password.strip.size == 0) ? password : new_password.chomp

    password_manager.save_file new_username, new_password

    [new_username, new_password]
  end
end