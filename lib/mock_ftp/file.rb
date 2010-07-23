module MockFTP
  class File
    attr_reader :path, :content, :mtime
    
    def initialize(path, content = nil, mtime = Time.now)
      @path    = MockFTP::Folder.normalize_path(path)
      @content = content
      @mtime   = mtime
      
      MockFTP::Folder.structure[@path] = self
    end
    
    def basename
      ::File.basename(@path)
    end
    
    def file?
      true
    end
    
    def folder?
      false
    end
  end
end
