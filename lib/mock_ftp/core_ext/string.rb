class String

  # Left chomp.
  #
  #   "help".lchomp("h")  #=> "elp"
  #   "help".lchomp("k")  #=> "help"
  def lchomp(match = /[\r\n]/)
    if index(match) == 0
      self[match.size..-1]
    else
      self.dup
    end
  end

  # In-place left chomp.
  #
  #   "help".lchomp!("h")  #=> "elp"
  #   "help".lchomp!("k")  #=> nil
  def lchomp!(match = /[\r\n]/)
    if index(match) == 0
      self[0...match.size] = ''
      self
    end
  end
  
  # File#join shortcut.
  #
  #   'some' / 'path'  #=> 'some/path'
  def /(path)
    ::File.join(self, path)
  end

end
