require 'rugged'
require_relative 'dir_locatable'

module TenderSpec
  class GitChangesDetector
    include DirLocatable
    attr_reader :project_path

    def initialize(project_path: '.')
      @project_path = project_path
    end

    def modified_lines
      lines_to_run = Set.new

      diff.each_patch do |patch|
        lines_to_run += patch_lines(patch)
      end

      lines_to_run
    end

    def diff
      uncommited_diff # TODO: add support for unmerged_diff
    end

    private

    def uncommited_diff # uncommited changes
      repository.diff_workdir(repository.head.target)
    end

    def unmerged_diff # diff between "master" and working tree
      repository.diff_workdir(repository.lookup(shared_commit_key))
    end

    def repository
      @repository ||= Rugged::Repository.discover('.')
    end

    def patch_lines(patch)
      lines = Set.new

      file_path = patch.delta.old_file[:path]
      patch.each_hunk do |hunk|
        lines += modified_file_line_numbers(hunk).map { |line_no| [file_path, line_no].join(':') }
      end

      lines
    end

    def modified_file_line_numbers(hunk)
      line_numbers = []

      hunk.each_line do |line|
        line_numbers << changed_line_number(line)
      end

      line_numbers.compact.uniq
    end

    def changed_line_number(line)
      origin = line.line_origin
      if origin == :addition
        line.new_lineno
      elsif origin == :deletion
        line.old_lineno
      end
    end
  end
end
