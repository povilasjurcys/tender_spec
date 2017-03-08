require 'rails_helper'

describe DummyThing do
  subject(:thing) { described_class.new(name) }
  let(:name) { 'test' }

  describe '#name' do
    it 'appends "Dummy" at the beggining' do
      expect(thing.name).to eq 'Dummy test'
    end
  end
end
