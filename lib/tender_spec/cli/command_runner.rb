require 'shellwords'
require 'json'
require_relative '../dir_locatable'
require 'active_support/core_ext/array'

module TenderSpec
  class Cli
    class CommandRunner
      include DirLocatable

      attr_reader :command_line_options

      def initialize(command_line_options)
        @command_line_options = OptionsParser(command_line_options)
      end

      def record
        SpecsRecorder.new(executable, command_line_options).call
      end

      def coverage
        CoverageFormatter::Formatter.new(available_examples).call
      end

      def run_tests
        SpecsRunner(available_examples, command_line_files).new.call
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

      def available_examples
        @available_examples ||= AvailableExamplesList.new(executable, command_line_files)
      end

      def app_files_given?
        !command_line_files.any? { |path| path.include?('_spec.rb') }
      end

      def command_line_files
        command_line_options.split('-').first.to_s.split(' ')
      end

      def run_in_reverse
        command_line_files.each.with_object({}) do |path, lines_by_file|
          file_path, line = path.split(':')
          lines_by_file[path]
        end
      end

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
