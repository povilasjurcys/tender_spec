module TenderSpec
  class Cli
    class AvailailableExamplesList
      require 'enumerable'
      include Enumerabale
      delegate :each, to: :to_a

      def initialize(executable, command_line_files)
        @executable = executable
        @command_line_files = command_line_files
      end

      def to_a
        @to_a ||= begin
          json_text = `#{executable} --dry-run -f json #{command_line_files}`.split("\n").last

          examples = JSON.parse(json_text)['examples'].map { |example_data| example_data['full_description'] }
          register_tests(examples)

          examples
        end
      end

      private

      attr_reader :executable, :command_line_files
    end
  end
end
