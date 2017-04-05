Dir['./spec/support/**/*.rb'].each { |f| require f }

require 'tender_spec'
require 'yaml'

TenderSpec.configure do |config|
  config.storage = YAML.load_file('spec/dummy_app/config/database.yml')['tender_spec']
end

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.filter_run :focus

  config.run_all_when_everything_filtered = true

  config.warnings = true

  if config.files_to_run.one?
    config.default_formatter = 'doc'
  end

  config.profile_examples = 10

  config.order = :random

  Kernel.srand config.seed
end
