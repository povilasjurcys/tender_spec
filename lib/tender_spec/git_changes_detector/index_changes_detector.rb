require_relative 'changes_detector'

module TenderSpec
  class GitChangesDetector
    class IndexChangesDetector
      include ChangesDetector

      def diff
        repository.diff_workdir(repository.head.target)
      end
    end
  end
end
