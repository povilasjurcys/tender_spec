require 'spec_helper'
require 'tender_spec/git_changes_detector'

describe TenderSpec::GitChangesDetector do
  subject(:detector) { described_class.new(project_path: project_path) }
  let(:project_path) { 'spec/fixtures/fake_repo' }

  describe '#modified_lines' do
    it 'detects modified lines' do
      expect(detector.modified_lines.to_a).to match_array [
        'file_with_added_line.txt:2',
        'file_with_changed_line.txt:2',
        'file_with_removed_line.txt:2',
        'removed_file.txt:1'
      ]
    end
  end
end
