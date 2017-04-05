require_relative 'models/app_file'
require_relative 'models/line_test'
require_relative 'models/app_test'
require_relative 'dir_locatable'
require 'tender_spec/coverage_storage'
require 'tender_spec/git_changes_detector'

module TenderSpec
  class RunnableTestsFinder
    include DirLocatable
    attr_reader :available_descriptions, :coverage_storage

    def initialize(available_descriptions:)
      @available_descriptions = available_descriptions
      @coverage_storage = CoverageStorage.new
    end

    def test_names
      available_modified_line_tests + untracked_tests
    end

    private

    def untracked_tests
      available_descriptions - modified_line_tests
    end

    def available_modified_line_tests
      modified_line_tests & available_descriptions
    end

    def modified_line_tests
      @modified_line_tests ||= begin
        lines = GitChangesDetector.new.modified_lines
        app_test_for(lines: lines).pluck(:description)
      end
    end

    def lines_by_path(lines)
      lines.each.with_object({}) do |line, result|
        match = line.match(/\A([^:]+):(\d+)/)
        path = match[1]
        line = match[2].to_i
        result[path] ||= Set.new
        result[path] << line
      end
    end

    def app_test_for(lines:)
      test_ids = Set.new

      lines_by_path(lines).each do |path, lines|
        file = AppFile.find_by(path: path)
        next if file.nil?

        query = { line_no: lines.to_a, sha: shared_commit_key, app_file_id: file.id }
        test_ids += LineTest.where(query).pluck(:app_test_id)
      end

      AppTest.where(id: test_ids.to_a)
    end
  end
end
