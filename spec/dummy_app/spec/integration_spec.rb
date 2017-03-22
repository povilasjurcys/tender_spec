require 'rails_helper'
require 'tender_spec/models/line_test'
require 'tender_spec/models/app_file'
require 'tender_spec/models/app_test'

describe 'integration' do
  TESTABLE_FILE_PATH = Rails.root.join('app', 'models', 'dummy_thing.rb').to_s.freeze

  def run_command(command)
    if ENV['DEBUG_TENDER'].nil?
      `#{command}`
    else
      Kernel.exec(command)
    end
  end

  def run_tender_record
    run_command 'tender record spec/models/dummy_thing_spec.rb'
  end

  def run_tender_spec
    run_command 'tender spec spec/models/dummy_thing_spec.rb'
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

  def expect_identical_file_contens(file_path, content)
    original_content = File.read(file_path)
    expect(original_content.strip).to eq file_content_without_coverage_flags(content).strip
  end

  def file_content_without_coverage_flags(content)
    content.split("\n").map { |line| line.sub(/^[-+]?/, '') }.join("\n")
  end

  def expect_coverage_in_file(file_path, content)
    file_id = TenderSpec::AppFile.find_by(path: file_path).id
    covered_lines = TenderSpec::LineTest.where(app_file_id: file_id).pluck(:line_no)
    lines = file_content_without_coverage_flags(content).split("\n")
    real_coverage = lines.map.with_index do |line, line_index|
      coverage_flag = covered_lines.include?(line_index + 1) ? '+' : '-'
      "#{coverage_flag}#{line}"
    end.join("\n")

    expect_identical_file_contens(file_path, content)
    expect(content).to eq real_coverage
  end

  before do
    `rake db:drop db:create db:migrate RAILS_ENV=tender_spec > /dev/null`
    `rm config/initializers/tender_spec.rb`
    `rails g tender_spec:install`
  end

  describe '`> tender record`' do
    it 'creates line tests' do
      expect { run_tender_record }.to change(TenderSpec::LineTest, :count).by(15)
    end

    it 'records tested files' do
      expect { run_tender_record }.to change(TenderSpec::AppFile, :count).by(1)
    end

    it 'records same lines for tests that do the same' do
      run_tender_record

      test_pathes = TenderSpec::AppTest.first.line_tests.map(&:path)
      similar_test_pathes = TenderSpec::AppTest.last.line_tests.map(&:path)

      aggregate_failures do
        expect(test_pathes).to be_any

        expect(test_pathes).to match_array similar_test_pathes
      end
    end

    it 'records checked tests' do
      expect { run_tender_record }.to change(TenderSpec::AppTest, :count).by(2)
    end

    it 'finds correct file paths' do
      run_tender_record

      expect_coverage_in_file 'app/models/dummy_thing.rb',
        <<~COVERAGE.strip
          +class DummyThing
          +  def initialize(name)
          +    @primary_name = name
          +  end
          +
          +  def name # this method is made intentionaly long
          +    result = 'Modified-Dummy '
          +
          +    if @primary_name.starts_with?('VIP')
          -      primary_name = @primary_name.sub('VIP ', '')
          -      upcased_name = primary_name.upcase
          -      result += upcased_name
          +    else
          +      result += @primary_name
          +    end
          +
          +    result
          +  end
          +
          +  def special_case_name
          -    'I am special!'
          +  end
          +end
        COVERAGE
    end

    it 'is sucessfull' do
      output = run_tender_record
      aggregate_failures do
        expect(output).to include('expected: "Dummy test"')
        expect(output).to include('got: "Modified-Dummy test"')
      end
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
