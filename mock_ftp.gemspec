require 'bundler'

Gem::Specification.new do |s|
  s.name        = 'mock_ftp'
  s.version     = '0.1'
  s.summary     = 'MockFTP ...'
  s.description = 'MockFTP ...'
  
  s.authors           = 'Pete Browne'
  s.email             = 'me@petebrowne.com'
  s.homepage          = 'http://github.com/petebrowne/mock_ftp'
  s.rubyforge_project = 'mock_ftp'
  
  s.files = Dir['lib/**/*'] + %w(LICENSE README.md)
  
  s.add_bundler_dependencies
end
