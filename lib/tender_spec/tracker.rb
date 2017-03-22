require 'json'
require 'fileutils'
require 'coverage'
require_relative 'differ'
require_relative 'dir_locatable'
require_relative 'coverage_storage'

module TenderSpec
  class Tracker
    include TenderSpec::DirLocatable

    attr_reader :storage

    def initialize
      @storage = CoverageStorage.new
    end

    def start
      @before_suite = Coverage.peek_result
    end

    def finish
      storage.save
    end

    def track(description, before, after)
      coverage_before = trim_coverage_data(before)
      coverage_after = trim_coverage_data(after)

      coverage = Differ.coverage_delta(coverage_before, coverage_after, @before_suite)
      storage.add(description, coverage)
    end

    private

    def trim_coverage_data(coverage_hash)
      important_path = Rails.root.to_s
      coverage_hash.each_with_object({}) do |(file_path, data), formatted|
        next unless file_path.starts_with?(important_path)
        relative_path = file_path[important_path.length + 1, file_path.length]
        formatted[relative_path] = data
      end
    end
  end
end
