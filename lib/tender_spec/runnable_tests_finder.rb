require_relative 'models/app_file'
require_relative 'models/line_test'
require_relative 'models/app_test'
require_relative 'dir_locatable'

module TenderSpec
  class RunnableTestsFinder
    include DirLocatable
    attr_reader :available_descriptions, :coverage_storage

    def initialize(available_descriptions:)
      @available_descriptions = available_descriptions
      @coverage_storage = CoverageStorage.new
    end

    def test_names
      tests = Set.new
      tests += modified_line_tests & available_descriptions
      tests
    end

    private

    def modified_line_tests
      lines = GitChangesDetector.new.modified_lines
      puts lines.to_a
      app_test_for(lines: lines).pluck(:description)
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
      puts lines_by_path(lines)
      lines_by_path(lines).each do |path, lines|
        file = AppFile.find_by(path: path)
        if file.nil?
          puts "Missed: #{path}"
          next
        else
          puts "Found: #{path}"
        end

        query = { line_no: lines.to_a, sha: shared_commit_key, app_file_id: file.id }
        puts query

        test_ids += LineTest.where(line_no: lines.to_a, sha: shared_commit_key, app_file_id: file.id).pluck(:app_test_id)
      end

      AppTest.where(id: test_ids.to_a)
    end
  end
end
