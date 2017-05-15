require 'spec_helper'

describe TenderSpec::CoveredLinesFinder::PathCoveredLinesFinder do
  subject(:finder) { described_class.new(before_test, after_test, before_suite) }
  let(:before_suite) { [nil, 1, 2, 3, nil] }
  let(:before_test) {  [1,   2, 2, 3, nil] }
  let(:after_test) {   [1,   2, 3, 3,   2] }

  describe '#after_test_coverage' do
    it 'returns coverage without before suite and test data' do
      expect(finder.after_test_coverage).to eq [0, 0, 1, 0, 2]
    end
  end

  describe '#before_test_coverage' do
    it 'returns coverage without before suite' do
      expect(finder.before_test_coverage).to eq [1, 1, 0, 0, nil]
    end
  end

  describe '#before_suite_coverage' do
    it 'returns original coverage' do
      expect(finder.before_suite_coverage).to eq before_suite
    end
  end
end
