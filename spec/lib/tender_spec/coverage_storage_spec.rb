require 'spec_helper'
require 'tempfile'
require 'tender_spec/coverage_storage'

describe TenderSpec::CoverageStorage do
  subject(:storage) { described_class.new }

  describe 'descriptions' do
    context 'when line exist' do
      it 'returns descriptions' do
        expect(logger.descriptions(in_line: 'foo.rb:1')).to eq ["test 3", "test 1"]
      end
    end

    context 'when line does not exist' do
      it 'returns empty list' do
        expect(logger.descriptions(in_line: 'does_not_exist.rb:1')).to be_empty
      end
    end
  end

  describe '#description_lines' do
    context 'when file is empty' do
      let(:coverage_path) { 'spec/fixtures/empty_coverage.json' }

      it 'returns empty hash' do
        expect(logger.description_lines).to be_empty
      end
    end

    context 'when file contains some data' do
      let(:coverage_path) { 'spec/fixtures/coverage.json' }

      it 'loads file content' do
        expect(logger.description_lines).to eq(
          'test 1' => Set.new(['foo.rb:1']),
          'test 2' => Set.new(['foo.rb:2', 'bar.rb:2'])
        )
      end
    end

    context 'when coverage has parent file' do
      let(:coverage_path) { 'spec/fixtures/coverage_with_parent.json' }

      it 'loads parent data too' do
        expect(logger.description_lines).to eq(
          'test 3' => Set.new(['foo.rb:1']),
          'test 1' => Set.new(['foo.rb:1']),
          'test 2' => Set.new(['baz.rb:2', 'foo.rb:2', 'bar.rb:2'])
        )
      end
    end
  end
end
