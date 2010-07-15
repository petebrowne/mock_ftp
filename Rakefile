task :default => :spec

#------------------------------------
#  Specs
#------------------------------------

begin
  require 'rspec/core'
  require 'rspec/core/rake_task'
rescue LoadError
  raise 'Run `gem install rspec --pre` to be able to run specs'
else
  desc 'Run the specs'
  RSpec::Core::RakeTask.new
end

#------------------------------------
#  YARD Docs
#------------------------------------

begin
  require 'yard'
rescue LoadError
  raise 'Run `gem install yard` to be able to build the docs'
else
  YARD::Rake::YardocTask.new
end

#------------------------------------
#  Console
#------------------------------------

desc 'Open an irb session preloaded with this library'
task :console do
  sh 'irb -rubygems -I lib -r mock_ftp.rb'
end

#------------------------------------
#  Packaging
#------------------------------------

def spec
  @spec ||= eval File.read('mock_ftp.gemspec')
end

require 'rake/gempackagetask'
Rake::GemPackageTask.new(spec) do |pkg|
  pkg.gem_spec = spec
end

desc 'Install the gem locally'
task :install => :package do
  sh %{gem install pkg/mock_ftp-#{spec.version}}
end

desc 'Release the gem'
task :release => :package do
  sh %{gem push pkg/mock_ftp-#{spec.version}.gem}
end

desc 'Validate the gemspec'
task :gemspec do
  spec.validate
end

task :package => :gemspec
