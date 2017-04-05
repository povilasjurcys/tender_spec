require 'rugged'
require_relative '../dir_locatable'

module TenderSpec
  class GitChangesDetector
    module ChangesDetector
      def modified_lines
        lines_to_run = Set.new

        diff.each_patch do |patch|
          lines_to_run += patch_lines(patch)
        end

        lines_to_run
      end

      def diff
        raise NotImplementedError
      end

      private

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
end
