lib = File.expand_path('../../lib', __FILE__)
$:.unshift(lib) unless $:.include?(lib)

require 'rubygems'
require 'bundler'
Bundler.require(:default, :development)
require 'mock_ftp'

RSpec.configure do |config|
  config.include MockFTP
end

def open_ftp(&block)
  ::Net::FTP.open('www.example.com', &block)
end
