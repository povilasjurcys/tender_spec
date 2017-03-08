require 'rails_helper'
require 'tender_spec/models/line_test'
require 'tender_spec/models/app_file'

describe 'integration' do
  TESTABLE_FILE_PATH = Rails.root.join('app', 'models', 'dummy_thing.rb').to_s

  def run_tender_record
    `tender record spec/models/dummy_thing_spec.rb`
  end

  def run_tender_spec
    `tender spec spec/models/dummy_thing_spec.rb`
  end

  def with_modified_file
    original_content = File.read(TESTABLE_FILE_PATH)
    modified_content = original_content.sub('result = \'Dummy \'', 'result = \'Modified-Dummy \'')

    begin
      File.write(TESTABLE_FILE_PATH, modified_content)
      yield
    ensure
      File.write(TESTABLE_FILE_PATH, original_content)
    end
  end

  before do
    `rake db:drop db:create db:migrate RAILS_ENV=tender_spec > /dev/null`
    `rm config/initializers/tender_spec.rb`
    `rails g tender_spec:install`
  end

  describe '`> tender record`' do
    it 'creates line tests' do
      expect { run_tender_record }.to change(TenderSpec::LineTest, :count).by(6)
    end

    it 'finds correct file paths' do
      record_code_coverage

      expect(TenderSpec::LineTest.all.map(&:path)).to match_array(
        [
          '/app/models/dummy_thing.rb:2',
          '/app/models/dummy_thing.rb:3',
          '/app/models/dummy_thing.rb:4',
          '/app/models/dummy_thing.rb:6',
          '/app/models/dummy_thing.rb:7',
          '/app/models/dummy_thing.rb:8'
        ]
      )
    end
  end

  describe '> tender spec' do
    context 'with coverage data' do
      before do
        run_tender_record
      end

      context 'without modifications' do
        it 'does not run rspec' do
          expect(run_tender_spec.strip).to eq 'Nothing to run'
        end
      end

      context 'with modifications in covered file' do
        it 'runs rspec' do
          with_modified_file do
            expect(run_tender_spec.strip).to eq 'Something to run'
          end
        end
      end
    end

    context 'without coverage data' do
      it 'does not run rspec' do
        with_modified_file do
          expect(run_tender_spec.strip).to eq 'Nothing to run'
        end
      end
    end
  end
end
