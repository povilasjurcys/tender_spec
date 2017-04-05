require 'rails_helper'

describe DummyThing do
  subject(:thing) { described_class.new(name) }

  describe '#name' do
    context 'with "first-test" name' do
      let(:name) { 'first-test' }

      it 'appends "Dummy" at the beggining' do
        expect(thing.name).to eq 'Dummy first-test'
      end
    end

    context 'with "second-test" name' do
      let(:name) { 'second-test' }

      it 'appends "Dummy" at the beggining' do
        expect(thing.name).to eq 'Dummy second-test'
      end
    end
  end
end
