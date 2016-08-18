require 'json'
require 'fileutils'
require 'coverage'
require_relative 'differ'
require_relative 'dir_locatable'
require_relative 'coverage_logger'

module WhatToRun
  class Tracker
    include WhatToRun::DirLocatable

    attr_reader :logger, :root_path

    def initialize(root_path: nil)
      @root_path = root_path
      @root_path = nil if root_path == ''

      @logger = CoverageLogger.new
    end

    def start
      logger.clear_unfinished
      @before_suite = Coverage.peek_result
    end

    def finish
      logger.finish
    end

    def finished?
      logger.finished?
    end

    def track(description, before, after)
      coverage_before = trim_coverage_data(before)
      coverage_after = trim_coverage_data(after)

      coverage = Differ.coverage_delta(coverage_before, coverage_after, @before_suite)
      logger.log(description, coverage)
    end

    def read
      JSON.parse File.read(coverage_json_path)
    end

    private

    def trim_coverage_data(coverage_hash)
      important_path = "#{current_log_dir}/app/"
      coverage_hash.each_with_object({}) do |(file_path, data), formatted|
        next unless file_path.starts_with?(important_path)
        relative_path = file_path[important_path.length, file_path.length]
        formatted[relative_path] = data
      end
    end
  end
end
