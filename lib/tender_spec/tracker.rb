require 'json'
require 'fileutils'
require 'coverage'
require 'singleton'
require_relative 'covered_lines_finder'
require_relative 'dir_locatable'
require_relative 'coverage_storage'

module TenderSpec
  class Tracker
    include TenderSpec::DirLocatable
    include Singleton

    attr_reader :storage

    def initialize
      @storage = CoverageStorage.new
    end

    def self.start
      instance.start
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
      coverage = CoveredLinesFinder.new(coverage_before, coverage_after, before_suite).covered_lines_by_path
      storage.add(description, coverage)
    end

    private

    attr_reader :before_suite

    def trim_coverage_data(coverage_hash)
      important_path = Rails.root.to_s
      coverage_hash.each_with_object({}) do |(file_path, data), formatted|
        next unless file_path.starts_with?(important_path)
        next if file_path.starts_with?("#{important_path}/spec/")
        relative_path = file_path[important_path.length + 1, file_path.length]
        formatted[relative_path] = data
      end
    end
  end
end
