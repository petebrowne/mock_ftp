module MockFTP
  class Net::FTP
    class << self
      def open(*args)
        yield self.new
      end
    end
    
    def initialize(*args)
      @current_path = ''
    end
    
    def nlst(path = '')
      if folder = MockFTP::Folder.find(@current_path / path)
        folder.list.collect do |f|
          path.empty? ? f.basename : (path / f.basename)
        end
      else
        raise ::Net::FTPPermError.new('550 Directory not found')
      end
    end
  end
end
