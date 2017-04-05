module TenderSpec
  class CoveredLinesFinder
    class PathCoveredLinesFinder
      attr_reader :before_test_coverage, :after_test_coverage, :before_suite_coverage

      def initialize(before_test_coverage, after_test_coverage, before_suite_coverage)
        @before_test_coverage = before_test_coverage
        @after_test_coverage = after_test_coverage
        @before_suite_coverage = before_suite_coverage
      end

      def covered_lines
        covered_lines_count = [after_test_coverage.length, before_test_coverage.length, before_suite_coverage.length].max
        (1..covered_lines_count).to_a.select { |line_no| covered_line?(line_no) }
      end

      private

      def covered_line?(line_no)
        line_index = line_no - 1
        covered_durring_test = covered_line_in_coverage?(after_test_coverage[line_index])
        covered_before_test = covered_line_in_coverage?(before_test_coverage[line_index])
        covered_before_suite = covered_line_in_coverage?(before_suite_coverage[line_index])

        covered_durring_test && !(covered_before_suite)
      end

      def covered_line_in_coverage?(line_coverage)
        line_coverage.to_i > 0
      end
    end # class PathCoveredLinesFinder

    attr_reader :before_test_coverage, :after_test_coverage, :before_suite_coverage

    def initialize(before_test_coverage, after_test_coverage, before_suite_coverage)
      @before_test_coverage = before_test_coverage
      @after_test_coverage = after_test_coverage
      @before_suite_coverage = before_suite_coverage
    end

    def covered_lines_by_path
      paths.each.with_object({}) do |path, lines_by_path|
        before = before_test_coverage[path].to_a
        after = after_test_coverage[path].to_a
        before_suite = before_suite_coverage[path].to_a

        lines_by_path[path] = PathCoveredLinesFinder.new(before, after, before_suite).covered_lines
      end
    end

    private

    def paths
      before_test_coverage.keys | after_test_coverage.keys
    end
  end # class CoveredLinesFinder
end # module TenderSpec
