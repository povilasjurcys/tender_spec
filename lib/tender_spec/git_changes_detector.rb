require 'rugged'
require_relative 'dir_locatable'
require_relative 'git_changes_detector/uncommited_changes_detector'

module TenderSpec
  class GitChangesDetector
    def initialize(project_path: '.')
      @project_path = project_path
    end

    def modified_lines
      UncommitedChangesDetector.new.modified_lines
    end
  end
end
