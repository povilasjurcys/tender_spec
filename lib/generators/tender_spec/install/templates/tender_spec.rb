require 'tender_spec'

TenderSpec.configure do |config|
  config.rspec_command = 'rspec'
  config.runner = 'rspec'
  config.storage = YAML.load_file(Rails.root.join('config', 'database.yml'))['tender_spec']
end
