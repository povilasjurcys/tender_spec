require 'tender_spec/spec_runner'

module TenderSpec
  class CLI
    ALLOWED_COMMANDS = %w(spec record).freeze

    attr_reader :command, :run_options

    def initialize(arguments)
      puts caller
      @run_options = Array(arguments).clone
      @command = run_options.shift || 'spec'

      if not ALLOWED_COMMANDS.include?(command)
        raise "Unknown command #{command}. Allowed commands are #{ALLOWED_COMMANDS.join(', ')}"
      end
    end

    def run
      send(command)
    end

    def spec
      runner.run
    end

    def record
      runner.record
    end

    private

    def runner
      SpecRunner.new(run_options.join(' '))
    end
  end
end
