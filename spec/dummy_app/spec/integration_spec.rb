require 'rails_helper'
require 'tender_spec/models/line_test'
require 'tender_spec/models/app_file'
require 'tender_spec/models/app_test'

describe 'integration' do
  TESTABLE_FILE_PATH = Rails.root.join('app', 'models', 'dummy_thing.rb').to_s.freeze

  def run_command(command, debug: ENV['DEBUG_TENDER'].present?)
    debug ? Kernel.exec(command) : `#{command}`
  end

  def run_tender_record(debug: ENV['DEBUG_TENDER'].present?)
    run_command('tender record spec/models/dummy_thing_spec.rb', debug: debug).tap do
      # small hack to make it look like it was runned from root app
      TenderSpec::AppFile.find_each { |file| file.update(path: "spec/dummy_app/#{file.path}") }
    end
  end

  def run_tender_spec(debug: ENV['DEBUG_TENDER'].present?)
    run_command('tender spec spec/models/dummy_thing_spec.rb', debug: debug)
  end

  def with_modified_file
    original_content = File.read(TESTABLE_FILE_PATH)
    modified_content = original_content.sub("'Dummy '", "'Modified-Dummy '")

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
    content.split("\n").map { |line| line.sub(/^[-\d ]+\| ?/, '') }.join("\n")
  end

  def expect_coverage_in_file(file_path, content)
    file_id = TenderSpec::AppFile.find_by(path: "spec/dummy_app/#{file_path}").id
    covered_lines = TenderSpec::LineTest.where(app_file_id: file_id).pluck(:line_no)
    lines = file_content_without_coverage_flags(content).split("\n")
    real_coverage = lines.map.with_index do |line, line_index|
      line_coverage_size = covered_lines.select { |line_no| line_no == line_index + 1 }.count
      coverage_flag = line_coverage_size > 0 ? line_coverage_size : '-'
      ["#{coverage_flag}|", line.presence].compact.join(' ')
    end.join("\n")

    expect_identical_file_contens(file_path, content)
    expect(content).to eq real_coverage
  end

  before(:all) do
    `rake db:drop db:create db:migrate RAILS_ENV=tender_spec > /dev/null`
    `rm config/initializers/tender_spec.rb`
    `rails g tender_spec:install`
  end

  before do
    TenderSpec::AppFile.delete_all
    TenderSpec::LineTest.delete_all
    TenderSpec::AppTest.delete_all
  end

  describe '`> tender record`' do
    it 'creates line tests' do
      expect { run_tender_record }.to change(TenderSpec::LineTest, :count).by(18)
    end

    it 'records tested files' do
      expect { run_tender_record }.to change(TenderSpec::AppFile, :count).by(1)
    end

    it 'records same lines for tests that do the same', :aggregate_failures do
      run_tender_record

      test_pathes = TenderSpec::AppTest.first.line_tests.map(&:path)
      similar_test_pathes = TenderSpec::AppTest.last.line_tests.map(&:path)

      expect(test_pathes).to be_any
      expect(test_pathes).to match_array similar_test_pathes
    end

    it 'records checked tests' do
      expect { run_tender_record }.to change(TenderSpec::AppTest, :count).by(2)
    end

    it 'finds correct file paths' do
      run_tender_record

      # on the left: how many times line was touched by tests
      expect_coverage_in_file 'app/models/dummy_thing.rb',
        <<-COVERAGE.strip_heredoc.strip
          2| class DummyThing
          2|   def initialize(name)
          2|     @primary_name = name
          -|   end
          -|
          2|   def name # this method is made intentionaly long
          2|     result = 'Dummy '
          -|
          2|     if @primary_name.starts_with?('VIP')
          -|       primary_name = @primary_name.sub('VIP ', '')
          -|       upcased_name = primary_name.upcase
          -|       result += upcased_name
          -|     else
          2|       result += @primary_name
          -|     end
          -|
          2|     result
          -|   end
          -|
          2|   def special_case_name
          -|     'I am special!'
          -|   end
          -| end
        COVERAGE
    end

    it 'is sucessfull' do
      expect(run_tender_record).to include('2 examples, 0 failures')
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
            output = run_tender_spec
            expect(output).to include('2 examples, 2 failures')
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
