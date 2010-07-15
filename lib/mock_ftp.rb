require 'net/ftp'
require 'mock_ftp/core_ext/string'

module MockFTP
  autoload :File,   'mock_ftp/file'
  autoload :Folder, 'mock_ftp/folder'
  
  module Net
    autoload :FTP, 'mock_ftp/net_ftp'
  end
  
  def mock_ftp(root_path = '', &block)
    @original_net_ftp = ::Net.__send__ :remove_const, :FTP
    ::Net.const_set :FTP, MockFTP::Net::FTP
    
    MockFTP::Folder.root(root_path, &block)
    
    ::Net.__send__ :remove_const, :FTP
    ::Net.const_set :FTP, @original_net_ftp
  end
end
