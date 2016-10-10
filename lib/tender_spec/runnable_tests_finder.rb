module TenderSpec
  class RunnableTestsFinder
    attr_reader :available_descriptions, :coverage_storage

    def initialize(available_descriptions:)
      @available_descriptions = available_descriptions
      @coverage_storage = CoverageStorage.new
    end

    def test_names
      tests = Set.new(uncovered_descriptions)
      tests += modified_line_tests & available_descriptions
      tests
    end

    private

    def modified_line_tests
      lines = GitChangesDetector.new.modified_lines
      lines.flat_map { |file_line| coverage_storage.descriptions(in_line: file_line) }
    end

    def uncovered_descriptions
      coverage_storage.missed_descriptions(available_descriptions)
    end
  end
end
