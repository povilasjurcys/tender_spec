require 'json'
require 'fileutils'
require_relative 'dir_locatable'
require_relative 'models/app_test'
require_relative 'models/line_test'
require_relative 'models/app_file'

module TenderSpec
  class CoverageStorage
    include DirLocatable

    attr_reader :coverage_path, :available_descriptions, :parent_file_path, :description_lines

    def initialize(coverage_path: nil)
      @coverage_path = coverage_path || "#{current_log_dir}/coverage.json"
      @description_lines = []
    end

    def ready?
      File.exist?(coverage_path)
    end

    def add(description, coverage)
      @description_lines ||= []

      coverage.each_pair do |file_name, file_coverage|
        file_coverage.each.with_index do |is_covered, line_index|
          next unless is_covered == 1

          description_lines << {
            description: description,
            path: file_name,
            line_no: line_index + 1
          }
        end
      end
    end

    def save_lines
      file_id_by_path = lines_file_id_by_path
      test_id_by_description = lines_test_id_by_description

      insert_sql = 'REPLACE INTO tender_spec_line_tests (app_test_id, app_file_id, line_no, sha) VALUES'
      sha = shared_commit_key
      sql_values_list = description_lines.map do |line|
        description, path, line_no = line.values
        sql_values = [test_id_by_description[description], file_id_by_path[path], line_no, "'#{sha}'"].join(', ')
        "(#{sql_values})"
      end

      AppTest.connection.execute "#{insert_sql} #{sql_values_list.join(', ')}"
    end

    def lines_file_id_by_path
      lines_object_ids_by_field(AppFile, :path)
    end

    def lines_test_id_by_description
      lines_object_ids_by_field(AppTest, :description)
    end

    def lines_object_ids_by_field(query, field)
      field_values = description_lines.map { |ln| ln[field] }.uniq
      id_by_field = {}

      query.where(field => field_values).find_each(batch_size: 100) do |instance|
        field_value = instance.public_send(field)
        id_by_field[field_value] = instance.id
      end

      (field_values - id_by_field.keys).each { |value| id_by_field[value] = query.find_or_create_by!(field => value).id }

      id_by_field
    end


    def descriptions(in_line:)
      file_path, line = in_line.split(':')

      app_file = shared_app_commit.app_files.find_by(path: file_path)
      app_line

      description_lines.select { |_, lines| lines.include?(in_line) }.keys
    end

    def save
      save_lines
      # json_lines = description_lines.each.with_object({}) do |(description, lines), result|
      #   result[description] = lines.to_a
      # end
      #
      # write_to_file(
      #   description_lines: json_lines,
      #   parent_file_path: parent_file_path,
      # )
    end

    private

    def write_to_file(json)
      path = coverage_path.sub(/[^\/]+\.json$/, '')
      FileUtils.mkdir_p(path)
      File.write(coverage_path, JSON.pretty_generate(json))
    end

    def reset
      data = data_from_file

      @parent_file_path = data['parent_file_path']

      file_description_lines = data['description_lines'] || {}
      @description_lines = file_description_lines.each.with_object({}) do |(description, lines), result|
        result[description] = Set.new(lines)
      end

      load_parent_data
      # load_missing_descriptions
    end

    def load_parent_data
      return unless parent_file_path

      parent_logger = self.class.new(coverage_path: parent_file_path)
      parent_logger.description_lines.each do |parent_description, parent_lines|
        lines = description_lines.fetch(parent_description, Set.new) + parent_lines
        description_lines[parent_description] = lines
      end
    end

    def data_from_file
      return {} unless File.exist?(coverage_path)

      json_text = File.read(coverage_path)
      return {} if json_text.nil? || json_text == ''

      JSON.parse(json_text)
    end
  end
end
