if ENV['TENDER_SPEC_MODE'] == 'record'
  require 'coverage'
  require 'tender_spec/tracker'
  require 'tender_spec/coverage_storage'

  puts 'runing Rspec with regression coverage'

  Coverage.start
  tracker = TenderSpec::Tracker.instance

  RSpec.configuration.before(:suite) do
    tracker.start
  end

  RSpec.configuration.after(:suite) do
    tracker.finish
    Coverage.result
  end

  RSpec.configuration.around(:each) do |example|
    coverage_before = Coverage.peek_result
    example.call
    coverage_after = Coverage.peek_result

    example_description = example.metadata[:full_description]
    tracker.track(example_description, coverage_before, coverage_after)
  end
end
