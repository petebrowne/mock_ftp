Gem::Specification.new do |s|
  s.name        = 'mock_ftp'
  s.version     = '0.1'
  s.summary     = 'MockFTP is a gem for mocking Net::FTP and returning the files and folders you expect.'
  s.description = 'MockFTP is a gem for mocking Net::FTP and returning the files and folders you expect.'
  
  s.authors           = 'Pete Browne'
  s.email             = 'me@petebrowne.com'
  s.homepage          = 'http://github.com/petebrowne/mock_ftp'
  s.rubyforge_project = 'mock_ftp'
  
  s.files = Dir['lib/**/*'] + %w(LICENSE README.md)
  
  s.add_development_dependency 'rspec',   '~> 2.0.0.beta.22'
  s.add_development_dependency 'timecop', '~> 0.3.0'
end