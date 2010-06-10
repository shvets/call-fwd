require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "call-fwd"
    gemspec.summary = "Enables/disables call forwarding feature."
    gemspec.description = "Enables/disables call forwarding feature for phone service."
    gemspec.email = "alexander.shvets@gmail.com"
    gemspec.homepage = "http://github.com/shvets/call-fwd"
    gemspec.authors = ["Alexander Shvets"]
    gemspec.files = FileList["CHANGES", "call-fwd.gemspec", "Rakefile", "README", "VERSION", "lib/**/*", "bin/**", "public/**", "views/**"]

    gemspec.executables = ['cfwd', 'call-fwd']
    gemspec.requirements = ["none"]
    gemspec.bindir = "bin"
  end
rescue LoadError
  puts "Jeweler not available. Install it for jeweler-related tasks with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
end

Rake::TestTask.new do |t|
  t.libs << 'lib'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = false
end

task :default => :test
