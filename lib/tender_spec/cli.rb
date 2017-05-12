module TenderSpec
  class Cli
    autoload :SpecRunner, 'tender_spec/cli/spec_runner'
    autoload :ReverseTestsFinder, 'tender_spec/cli/reverse_tests_finder'

    ALLOWED_COMMANDS = %w(spec record coverage test_descriptions).freeze

    attr_reader :command, :run_options

    def initialize(arguments)
      @run_options = Array(arguments).clone
      @command = run_options.shift || 'spec'

      if not ALLOWED_COMMANDS.include?(command)
        raise "Unknown command #{command}. Allowed commands are #{ALLOWED_COMMANDS.join(', ')}"
      end
    end

    def run
      public_send(command)
    end

    def spec
      require './config/environment'
      runner.run_tests
    end

    def record
      runner.record
    end

    def coverage
      puts runner.lines_touched.join("\n")
    end

    def test_descriptions
      puts runner.runnable_tests.join("\n").presence || 'Nothing found'
    end

    private

    def runner
      SpecRunner.new(run_options.join(' '))
    end
  end
end
