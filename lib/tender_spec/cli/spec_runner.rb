require 'shellwords'
require 'json'
require_relative '../dir_locatable'

module TenderSpec
  class Cli
    class SpecRunner
      include DirLocatable

      attr_reader :command_line_options

      def initialize(command_line_options)
        @command_line_options = command_line_options
      end

      def record
        Kernel.exec "TENDER_SPEC_MODE=\"record\" #{executable} #{command_line_options}"
      end

      def run_tests
        if predicted_examples.count == 0
          puts 'Nothing to run'
          return
        end

        puts "Running #{predicted_examples.count} out of #{available_examples.count} available examples"

        args = predicted_examples.flat_map { |example| ['-e', example] }
        Kernel.exec "TENDER_SPEC_MODE=\"initialize\" #{executable} #{Shellwords.join(args)}"
      end

      def available_examples
        @available_descriptions ||= begin
          json_text = `#{executable} --dry-run -f json #{command_line_options}`.split("\n").last

          examples = JSON.parse(json_text)['examples'].map { |example_data| example_data['full_description'] }
          register_tests(examples)

          examples
        end
      end

      private

      def register_tests(examples)
        examples.each { |example| AppTest.find_or_create_by!(description: example) }
      end

      def executable
        Configuration.instance.rspec_command
      end

      def predicted_examples
        @predicted_examples ||= RunnableTestsFinder.new(available_descriptions: available_examples).test_names
      end
    end
  end
end
