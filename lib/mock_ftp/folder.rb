module MockFTP
  class Folder
    class << self
      def root(root_path, &block)
        begin
          new(root_path, &block)
        ensure
          @structure = nil
        end
      end
      
      def structure
        @structure ||= {}
      end
      
      def find(path)
        structure[normalize_path(path)]
      end
      
      def normalize_path(path)
        path.lchomp('/').chomp('/')
      end
    end
    
    attr_reader :path, :list, :mtime
    
    def initialize(path, mtime = Time.now)
      @path  = MockFTP::Folder.normalize_path(path)
      @list  = []
      @mtime = mtime
      
      MockFTP::Folder.structure[@path] = self
      
      yield self if block_given?
    end
    
    def folder(path, *args, &block)
      @list << MockFTP::Folder.new(@path / path, *args, &block)
    end
    
    def file(path, *args)
      @list << MockFTP::File.new(@path / path, *args)
    end
    
    def basename
      ::File.basename(@path)
    end
    
    def file?
      false
    end
    
    def folder?
      true
    end
  end
end
