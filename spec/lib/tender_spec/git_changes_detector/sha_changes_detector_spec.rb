require 'spec_helper'
require 'tender_spec'
require 'tender_spec/git_changes_detector/sha_changes_detector'

describe TenderSpec::GitChangesDetector::ShaChangesDetector do
  subject(:detector) { described_class.new(commit_sha, parent_commit_sha: parent_commit_sha) }
  let(:parent_commit_sha) { '8519383f4253e1ba5c62430d9821d29e516cfc78' }
  let(:commit_sha) { '57b99c41aa9131e06e2467d17d7edf4c9aaa174d' }

  describe '#modified_lines' do
    subject(:modified_lines) { detector.modified_lines.to_a }

    context 'when working tree has changes' do
      it 'ignores working tree changes' do
        file_with_transaction("#{TenderSpec.root}/spec/dummy_app/app/models/dummy_thing.rb") do |file|
          file.sub("'Dummy '", "'Modified dummy '")
          dummy_thing_change_lines = modified_lines.select { |line| line['spec/dummy_app/app/models/dummy_thing.rb'] }
          expect(dummy_thing_change_lines).to be_empty
        end
      end
    end

    it 'returns changes between two commits' do
      expeted_changed_lines = (1..20).map { |line| ".rubocop.yml:#{line}"}
      expect(modified_lines).to eq expeted_changed_lines
    end
  end
end
