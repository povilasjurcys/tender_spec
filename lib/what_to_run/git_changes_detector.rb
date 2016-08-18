require_relative 'dir_locatable'

module WhatToRun
  class GitChangesDetector
    include DirLocatable

    def lines
      lines = Set.new

      shared_comit_object.diff(repository.head.target).each_patch do |patch|
        lines += patch_lines(patch)
      end

      repository.index.diff.each_patch do |patch|
        lines += patch_lines(patch)
      end

      lines
    end

    private

    def repository
      @repository ||= Rugged::Repository.discover('.')
    end

    def repository_root
      @repository_root ||= File.expand_path("..", repository.path)
    end

    def shared_comit_object
      repository.lookup(shared_commit_key)
    end

    def patch_lines(patch)
      lines = Set.new
      file = patch.delta.old_file[:path]
      file_path = file

      patch.each_hunk do |hunk|
        hunk.each_line do |line|
          case line.line_origin
          when :addition
            lines << "#{file_path}:#{line.new_lineno}"
          when :deletion
            lines << "#{file_path}:#{line.old_lineno}"
          when :context
            # do nothing
          end
        end
      end

      lines
    end
  end
end
