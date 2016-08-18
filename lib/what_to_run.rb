require 'set'
require 'rugged'

require_relative 'what_to_run/tracker'
require_relative 'what_to_run/coverage_logger'
require_relative 'what_to_run/git_changes_detector'

module WhatToRun
  autoload :CLI, 'what_to_run/cli'
  autoload :VERSION, 'what_to_run/version'

  class << self
    def predict
      logger = CoverageLogger.new
      tests = Set.new

      lines = GitChangesDetector.new.lines
      lines.each do |file_line|
        tests += logger.get_descriptions(file_line)
      end

      tests
    end
  end
end
