require File.expand_path('sanity_shared_examples', File.dirname(__FILE__))

describe 'RSpec sanity test' do
  it_behaves_like 'a sanity check', 'rspec', 'rspec' do
    let(:tender_spec_result_matches) do
      [
        '1 example, 1 failure'
      ]
    end
  end
end
