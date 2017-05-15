module TenderSpec
  module CoverageFormatter
    class Formatter
      def initialize(available_examples)
        @available_examples = available_examples
      end

      def call
        Result.new(raw_coverage).format!
      end

      private

      attr_reader :available_examples

      def line_tests
        @app_tests ||= begin
          app_test_ids = AppTest.where(description: available_examples).pluck(:id)
          LineTest.includes(:app_file).where(app_test: app_test_ids)
        end
      end

      def raw_coverage
        line_tests
          .find_each
          .group_by(&:path)
          .each_with_object({}) do |(_, lines), coverage|
            file_path = lines.first.app_file.path
            line_no = lines.first.line_no

            coverage[file_path] ||= [0] * file_lines_count(file_path)
            coverage[file_path][line_no - 1] += lines.count
          end
      end

      def file_lines_count(file_path)
        File.read(file_path).scan(/\n/).count
      end
    end
  end
end
