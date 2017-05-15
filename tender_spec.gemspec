Gem::Specification.new do |s|
  s.name        = 'tender_spec'
  s.version     = '0.0.1'
  s.date        = '2016-10-10'

  s.summary     = 'Regression test selection'
  s.description = 'Predict which tests are likely to fail after you’ve changed the code'
  s.authors     = ['Aaron Patterson', 'Dyego Costa']
  s.email       = 'dyego@dyegocosta.com'
  s.homepage    = 'https://github.com/povilasjurcys/tender_spec'
  s.license     = 'MIT'

  s.files       = ['README.md', 'Rakefile']
  s.files       += Dir.glob("ext/**/*.*")
  s.files       += Dir.glob("lib/**/*.rb")

  s.executables << 'tender'
  s.required_ruby_version = '>= 1.9.3'

  s.add_development_dependency 'rake-compiler', '~> 0.9', '>= 0.9.0'
  s.add_development_dependency 'byebug'
  s.add_development_dependency 'sqlite3'

  s.add_runtime_dependency 'activesupport'
  s.add_runtime_dependency 'simplecov'
  s.add_runtime_dependency 'activerecord'
  s.add_runtime_dependency 'rugged', '~> 0.21', '>= 0.21.0'
  end
