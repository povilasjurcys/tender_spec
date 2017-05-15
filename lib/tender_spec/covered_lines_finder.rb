module TenderSpec
  class CoveredLinesFinder
    autoload :PathCoveredLinesFinder, 'tender_spec/covered_lines_finder/path_covered_lines_finder'
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
