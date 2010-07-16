module MockFTP
  class File
    attr_reader :path, :content
    
    def initialize(path, content = nil)
      @path    = MockFTP::Folder.normalize_path(path)
      @content = content
      
      MockFTP::Folder.structure[@path] = self
    end
    
    def basename
      ::File.basename(@path)
    end
  end
end
