module MockFTP
  class ListInfo
    
    def initialize(file, user = 'anonymous')
      @file = file
      @user = user
    end
    
    def to_s
      if @file.folder?
        folders_count = @file.list.select(&:folder?).count + 2
        [
          'drwxr-xr-x',
          folders_count.to_s.rjust(3),
          @user, @user,
          '    4096',
          formatted_date,
          @file.basename
        ].join(' ')
      else
        [
          '-rw-r--r--   1',
          @user, @user,
          @file.size.to_s.rjust(8),
          formatted_date,
          @file.basename
        ].join(' ')
      end
    end
    
    protected
      
      def formatted_date
        date        = @file.mtime.utc
        date_parts  = [ date.strftime('%b') ]
        date_parts << date.day.to_s.rjust(2)
        date_parts << if date.year == Time.now.year
          date.strftime('%H:%M').gsub(/^0/, '')
        else
          date.year.to_s
        end.rjust(5)
        date_parts.join(' ')
      end
  end
end
