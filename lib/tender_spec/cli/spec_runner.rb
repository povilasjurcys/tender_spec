require 'shellwords'
require 'json'
require_relative '../dir_locatable'
require 'active_support/core_ext/array'

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

      def lines_touched
        CoverageFormatter::Formatter.new(available_examples).format
      end

      def runnable_tests
        @runnable_tests ||=  \
          if app_files_given?
            ReverseTestsFinder.new(command_line_files).test_names
          else
            RunnableTestsFinder.new(available_descriptions: available_examples).test_names
          end
      end

      def run_tests
        if runnable_tests.empty?
          puts 'Nothing to run'
          return
        end

        display_prerun_notification

        args = runnable_tests.flat_map { |example| ['-e', example] }
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

      def display_prerun_notification
        if app_files_given?
          puts "Running #{runnable_tests.count}"
        else
          puts "Running #{runnable_tests.count} out of #{available_examples.count} available examples"
        end
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
