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
      @host         = host
      @user         = user || 'anonymous'
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
    
    def connect(host, port = nil)
      @host = host
      nil
    end
    
    def list(path = '')
      raise_if_closed
      full_path = follow_path(path)
      
      if file = find(full_path)
        if file.folder?
          file.list.collect do |f|
            list_details_for(f)
          end
        else
          [ list_details_for(file) ]
        end
      else
        raise ::Net::FTPPermError.new("450 #{path}: No such file or directory")
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
      full_path = follow_path(path)
      
      if file = find(full_path)
        if file.file?
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
        if file.file?
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
      
      def format_date(date)
        formatted_date  = [ date.strftime('%b') ]
        formatted_date << right_align_text(date.day.to_s, 2)
        formatted_date << if date.year == Time.now.year
          date.strftime('%H:%M').gsub(/^0/, ' ')
        else
          " #{date.year}"
        end
        formatted_date.join(' ')
      end
      
      def list_details_for(file)
        if file.folder?
          folders_count = file.list.select(&:folder?).count + 2
          [
            'drwxr-xr-x',
            right_align_text(folders_count.to_s, 3),
            @user, @user,
            '    4096',
            format_date(file.mtime.utc),
            file.basename
          ].join(' ')
        else
          [
            '-rw-r--r--   1',
            @user, @user,
            right_align_text(file.size.to_s, 8),
            format_date(file.mtime.utc),
            file.basename
          ].join(' ')
        end
      end
    
      def raise_if_closed
        raise IOError.new('closed stream') if closed?
      end
      
      def right_align_text(content, spaces)
        if content.length >= spaces
          content
        else
          ' ' * (spaces - content.length) + content
        end
      end
  end
end
