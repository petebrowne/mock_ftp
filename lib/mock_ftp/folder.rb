module MockFTP
  class Folder
    class << self
      def root(root_path, &block)
        @structure = nil
        self.new(root_path, &block)
      end
      
      def structure
        @structure ||= {}
      end
      
      def find(path)
        structure[path.lchomp('/')]
      end
    end
    
    attr_reader :path, :list
    
    def initialize(path)
      @path = path.lchomp('/')
      @list = []
      
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
  end
end
