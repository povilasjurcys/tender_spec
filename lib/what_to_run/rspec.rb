if ENV['COLLECT_WHAT_TO_RUN']
  require 'coverage'
  require 'what_to_run/tracker'

  Coverage.start

  tracker = WhatToRun::Tracker.new(logs_path: ENV['COLLECT_WHAT_TO_RUN'])

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

    tracker.track(example.metadata[:full_description], coverage_before, coverage_after)
  end
end
