module TenderSpec
  class Cli
    class SpecsRunner
      def initialize(executable, command_line_files, available_examples)
        @executable = executable
        @command_line_files = command_line_files
        @available_examples = available_examples
      end

      def call
        if runnable_tests.empty?
          puts 'Nothing to run'
          return
        end

        display_prerun_notification

        args = runnable_tests.flat_map { |example| ['-e', example] }
        Kernel.exec "TENDER_SPEC_MODE=\"initialize\" #{executable} #{Shellwords.join(args)}"
      end

      private

      attr_reader :executable, :command_line_files, :available_examples

      def display_prerun_notification
        if app_files_given?
          puts "Running #{runnable_tests.count}"
        else
          puts "Running #{runnable_tests.count} out of #{available_examples.count} available examples"
        end
      end

      def runnable_tests
        @runnable_tests ||=  \
          if app_files_given?
            ReverseTestsFinder.new(command_line_files).test_names
          else
            RunnableTestsFinder.new(available_descriptions: available_examples.to_a).test_names
          end
      end
    end
  end
end
