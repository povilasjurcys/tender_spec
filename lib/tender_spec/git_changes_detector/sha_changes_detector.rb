require_relative 'changes_detector'

module TenderSpec
  class GitChangesDetector
    class ShaChangesDetector
      include ChangesDetector
      include DirLocatable

      def initialize(sha)
      end

      def diff
        repository.diff_workdir(repository.lookup(shared_commit_key))
      end
    end
  end
end
