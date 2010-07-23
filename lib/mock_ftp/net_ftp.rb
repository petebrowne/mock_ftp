require 'pathname'

module MockFTP
  class Net::FTP
    class << self
      def open(*args)
        yield self.new
      end
    end
    
    def initialize(*args)
      @current_path = ''
      @closed       = false
    end
    
    def abort
      raise_if_closed
      "226 Abort successful\n"
    end
    
    def chdir(path)
      raise_if_closed
      full_path = follow_path(path)
      
      if folder = find(full_path)
        @current_path = full_path
      else
        raise ::Net::FTPPermError.new("550 #{path}: No such file or directory")
      end
    end
    
    def close
      @closed = true
    end
    
    def closed?
      !!@closed
    end
    
    def connect(host, *args)
    end
    
    def login(username = 'anonymous', passwd = nil, acct = nil)
      raise_if_closed
      "230 User #{username} logged in.\n"
    end
    
    def mdtm(path)
      mtime(path).strftime('%Y%m%d%H%M%S')
    end
    
    def mtime(path, local = false)
      raise_if_closed
      full_path = follow_path(path)
      
      if file = find(full_path)
        if file.respond_to?(:mtime)
          local ? file.mtime : file.mtime.utc
        else
          raise ::Net::FTPPermError.new("550 #{path}: not a plain file.")
        end
      else
        raise ::Net::FTPPermError.new("550 #{path}: No such file or directory")
      end
    end
    
    def nlst(path = '')
      raise_if_closed
      full_path = follow_path(path)
      
      if folder = find(full_path)
        folder.list.collect do |f|
          path.empty? ? f.basename : (path / f.basename)
        end
      else
        raise ::Net::FTPPermError.new('550 Directory not found')
      end
    end
    
    def noop
      raise_if_closed
    end
    
    def pwd
      raise_if_closed
      if @current_path =~ /^\//
        @current_path
      else
        "/#{@current_path}"
      end
    end
    alias_method :get_dir, :pwd
    
    def quit
      raise_if_closed
    end
    
    def size(path)
      raise_if_closed
      full_path = follow_path(path)
      
      if file = find(full_path)
        if file.respond_to?(:content)
          file.content.size
        else
          raise ::Net::FTPPermError.new("550 #{path}: not a regular file")
        end
      else
        raise ::Net::FTPPermError.new("550 #{path}: No such file or directory")
      end
    end
    
    protected
    
      def find(path)
        MockFTP::Folder.find(path)
      end
    
      def follow_path(path)
        path = Pathname.new(path).cleanpath.to_s
        
        case path
        when '..'
          @current_path.sub %r{/([^/]*)$}, ''
        when /^\.\/?/
          @current_path
        else
          @current_path / path
        end
      end
    
      def raise_if_closed
        raise IOError.new('closed stream') if closed?
      end
  end
end
