require_relative 'changes_detector'

module TenderSpec
  class GitChangesDetector
    # Used for detecting what test needs to be run, to make coverage data up to date
    class ShaChangesDetector
      include ChangesDetector
      include DirLocatable

      attr_reader :commit_sha, :parent_commit_sha

      def initialize(commit_sha, parent_commit_sha: nil)
        @commit_sha = commit_sha
        @parent_commit_sha = parent_commit_sha
      end

      def diff
        parent_commit.diff(current_commit)
      end

      private

      def current_commit
        repository.lookup(commit_sha)
      end

      def parent_commit
        repository.lookup(parent_commit_sha)
      end
    end
  end
end
