require 'tender_spec/covered_lines_finder'

describe TenderSpec::CoveredLinesFinder do
  subject(:finder) { described_class.new(before_test_coverage, after_test_coverage, before_suite_coverage) }

  let(:before_test_coverage) do
    {
      'foo.rb' =>               [nil, 1,   1,   1, 2,   nil],
      'not_changed.rb' =>       [nil, nil, nil, 1, nil, nil],
      'nil_initial_coverage' => nil
    }
  end

  let(:after_test_coverage) do
    {
      'foo.rb' =>               [nil, 1,   2,   3, 2,   nil],
      'not_changed.rb' =>       [nil, nil, nil, 1, nil, nil],
      'nil_initial_coverage' => [1, 3, nil]
    }
  end

  let(:before_suite_coverage) do
    {
      'foo.rb' =>               [nil, 1,   0,   0, 0,   nil],
      'not_changed.rb' =>       [nil, nil, nil, 1, nil, nil],
      'nil_initial_coverage' => nil
    }
  end

  describe '#covered_lines_by_path' do
    subject(:covered_lines_by_path) { finder.covered_lines_by_path }

    it 'includes all pathes' do
      expect(covered_lines_by_path.keys).to match_array(%w[foo.rb not_changed.rb nil_initial_coverage])
    end

    it 'does not include unchanged lines' do
      expect(covered_lines_by_path['not_changed.rb']).to be_empty
    end
  end
end
