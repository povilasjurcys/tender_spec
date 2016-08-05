require 'rspec/core/rake_task'
require 'rake/extensiontask'

RSpec::Core::RakeTask.new(:spec)

Rake::Task[:spec].prerequisites << :compile

task :default => :spec
