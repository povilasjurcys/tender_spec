require 'json'
require 'fileutils'
require_relative 'dir_locatable'
require_relative 'models/app_test'
require_relative 'models/line_test'
require_relative 'models/app_file'

module TenderSpec
  class CoverageStorage
    include DirLocatable

    def initialize
      @description_lines = []
    end

    def add(description, coverage)
      @description_lines ||= []

      coverage.each_pair do |file_name, covered_lines|
        covered_lines.each do |line_no|
          description_lines << {
            description: description,
            path: file_name,
            line_no: line_no
          }
        end
      end
    end

    def save
      file_id_by_path = lines_file_id_by_path
      test_id_by_description = lines_test_id_by_description
      sha = shared_commit_key

      LineTest.transaction do
        description_lines.each do |line|
          description, path, line_no = line.values_at(:description, :path, :line_no)

          LineTest.find_or_create_by!(
            app_test_id: test_id_by_description[description],
            app_file_id: file_id_by_path[path],
            line_no: line_no,
            sha: sha
          )
        end
      end
    end

    private

    attr_reader :description_lines

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
  end
end
