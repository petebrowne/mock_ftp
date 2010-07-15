lib = File.expand_path('../../lib', __FILE__)
$:.unshift(lib) unless $:.include?(lib)

require 'rubygems'
require 'bundler'
Bundler.require(:default, :development)
require 'mock_ftp'

Spec::Runner.configure do |config|
  
end
