require 'spec_helper'
require 'tender_spec'
require 'tender_spec/git_changes_detector/index_changes_detector'

describe TenderSpec::GitChangesDetector::IndexChangesDetector do
  subject(:detector) { described_class.new }

  describe '#modified_lines' do
    subject(:modified_lines) { detector.modified_lines }

    it 'returns something' do
      file_with_transaction("#{TenderSpec.root}/spec/dummy_app/app/models/dummy_thing.rb") do |file|
        file.sub("'Dummy '", "'Modified dummy '")
        expect(modified_lines).to eq 'a'
      end
    end
  end
end
