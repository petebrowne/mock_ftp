lib = File.expand_path('../../lib', __FILE__)
$:.unshift(lib) unless $:.include?(lib)

require 'rubygems'
require 'bundler'
Bundler.require(:default, :development)
require 'mock_ftp'
require 'fileutils'

RSpec.configure do |config|
  config.include MockFTP
  
  TMP_PATH = ::File.expand_path('../tmp', __FILE__)

  def open_ftp(with_tmp_files = false, &block)
    if with_tmp_files
      FileUtils.mkdir_p(TMP_PATH)
      FileUtils.cd(TMP_PATH)
    end
    ::Net::FTP.open 'www.example.com', &block
    FileUtils.rm_rf(TMP_PATH) if with_tmp_files
  end
end

