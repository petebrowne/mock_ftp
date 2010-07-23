require 'pathname'

module MockFTP
  class Net::FTP
    class << self
      def open(host, user = nil, passwd = nil, acct = nil)
        if block_given?
          ftp = new(host, user, passwd, acct)
          begin
            yield ftp
          ensure
            ftp.close
          end
        else
          new(host, user, passwd, acct)
        end
      end
    end
    
    def initialize(host = nil, user = nil, passwd = nil, acct = nil)
      @current_path = ''
      @closed       = false
      @host         = host || 'www.example.com'
      @user         = user || 'anonymous'
    end
    
    def abort
      raise_if_closed
      "226 Abort successful\n"
    end
    
    def chdir(path)
      raise_if_closed
      full_path = follow_path(path)
      file = MockFTP::Folder.find(full_path)
      raise_ftp_error("550 #{path}: No such file or directory") if file.nil?
      
      @current_path = full_path
    end
    
    def close
      @closed = true
    end
    
    def closed?
      !!@closed
    end
    
    def connect(host, port = nil)
      @host = host
      nil
    end
    
    def list(path = '')
      raise_if_closed
      file = find(path, "450 #{path}: No such file or directory")
      
      if file.folder?
        file.list.collect do |f|
          MockFTP::ListInfo.new(f, @user).to_s
        end
      else
        [ MockFTP::ListInfo.new(file, @user).to_s ]
      end
    end
    alias_method :ls, :list
    alias_method :dir, :list
    
    def login(user = 'anonymous', passwd = nil, acct = nil)
      raise_if_closed
      @user = user
      "230 User #{user} logged in.\n"
    end
    
    def mdtm(path)
      mtime(path).strftime('%Y%m%d%H%M%S')
    end
    
    def mtime(path, local = false)
      raise_if_closed
      file = find(path)
      raise_ftp_error("550 #{path}: not a plain file.") unless file.file?
      
      local ? file.mtime : file.mtime.utc
    end
    
    def nlst(path = '')
      raise_if_closed
      folder = find(path, '550 Directory not found')
      
      folder.list.collect do |f|
        path.empty? ? f.basename : (path / f.basename)
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
      file = find(path)
      raise_ftp_error("550 #{path}: not a regular file") unless file.file?
      
      file.size
    end
    
    protected
    
      def find(path, error_message = "550 #{path}: No such file or directory")
        if file = MockFTP::Folder.find(follow_path(path))
          file
        else
          raise_ftp_error(error_message)
        end
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
      
      def raise_ftp_error(error_message)
        raise ::Net::FTPPermError.new(error_message)
      end
    
      def raise_if_closed
        raise IOError.new('closed stream') if closed?
      end
  end
end
