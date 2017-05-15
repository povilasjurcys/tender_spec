module TenderSpec
  class CoveredLinesFinder
    class PathCoveredLinesFinder
      attr_reader :before_suite_coverage

      def initialize(before_test_coverage, after_test_coverage, before_suite_coverage)
        @full_before_test_coverage = before_test_coverage
        @full_after_test_coverage = after_test_coverage
        @before_suite_coverage = before_suite_coverage
      end

      def covered_lines
        covered_lines_count = [
          after_test_coverage.length,
          before_test_coverage.length,
          before_suite_coverage.length
        ].max
        (1..covered_lines_count).to_a.select { |line_no| covered_line?(line_no) }
      end

      def before_test_coverage # test coverage excluding before suite
        @before_test_coverage ||= @full_before_test_coverage.map.with_index do |cover_count, i|
          suite_cover_count = before_suite_coverage[i]
          if suite_cover_count.to_i == 0 || cover_count.to_i == 0
            cover_count
          else
            cover_count.to_i - suite_cover_count.to_i
          end
        end
      end

      def after_test_coverage # test coverage including before test, but excluding before suite
        @after_test_coverage ||= @full_after_test_coverage.map.with_index do |cover_count, i|
          before_cover_count = full_before_test_coverage[i]
          if before_cover_count.to_i == 0 || cover_count.to_i == 0
            cover_count
          else
            cover_count.to_i - before_cover_count.to_i
          end
        end
      end

      private

      attr_reader :full_after_test_coverage, :full_before_test_coverage

      def covered_line?(line_no)
        line_index = line_no - 1
        # covered_durring_test = covered_line_in_coverage?(after_test_coverage[line_index])
        # covered_before_test = covered_line_in_coverage?(before_test_coverage[line_index])
        # covered_before_suite = covered_line_in_coverage?(before_suite_coverage[line_index])

        covered_line_in_coverage?(after_test_coverage[line_index])
      end

      def covered_line_in_coverage?(line_coverage)
        line_coverage.to_i > 0
      end
    end # class PathCoveredLinesFinder
  end # class CoveredLinesFinder
end # module TenderSpec
