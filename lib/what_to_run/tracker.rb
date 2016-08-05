require 'json'
require 'fileutils'
require 'coverage'
require_relative 'differ'
require_relative 'dir_locatable'

module WhatToRun
  class Tracker
    include WhatToRun::DirLocatable

    attr_reader :log, :root_path

    def initialize(root_path)
      @root_path = root_path
      @root_path = nil if root_path == ''

      @log = []
    end

    def log_exists?
      File.exist?(current_log_dir)
    end

    def start
      FileUtils.mkdir_p(current_log_dir)
      @before_suite = Coverage.peek_result
    end

    def track(description, before, after)
      coverage = Differ.coverage_delta(before, after, @before_suite)
      log << [description, coverage]
    end

    def finish
      File.write(coverage_json_path, JSON.dump(log))
    end

    def read
      JSON.parse File.read(coverage_json_path)
    end
  end
end
