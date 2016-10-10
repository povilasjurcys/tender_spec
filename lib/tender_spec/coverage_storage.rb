require 'json'
require 'fileutils'
require_relative 'dir_locatable'

module TenderSpec
  class CoverageStorage
    include DirLocatable

    attr_reader :coverage_path, :available_descriptions, :parent_file_path

    def initialize(coverage_path: nil)
      @coverage_path = coverage_path || "#{current_log_dir}/coverage.json"
    end

    def description_lines
      reset if @description_lines.nil?
      @description_lines
    end

    def missed_descriptions(descriptions)
      descriptions.reject do |description|
        description_lines.key?(description) and description_lines[description].any?
      end
    end

    def ready?
      File.exist?(coverage_path)
    end

    def add(description, coverage)
      description_lines[description] ||= Set.new

      coverage.each_pair do |file_name, file_coverage|
        file_coverage.each.with_index do |is_covered, line_index|
          next unless is_covered == 1

          file_line = "#{file_name}:#{line_index + 1}"

          description_lines[description] << file_line
        end
      end
    end

    def descriptions(in_line:)
      description_lines.select { |_, lines| lines.include?(in_line) }.keys
    end

    def missing_descriptions
      description_lines.select { |_, lines| lines.empty? }.keys
    end

    def save
      json_lines = description_lines.each.with_object({}) do |(description, lines), result|
        result[description] = lines.to_a
      end

      write_to_file(
        description_lines: json_lines,
        parent_file_path: parent_file_path,
      )
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

    # def load_missing_descriptions
    #   json_text = `rspec --dry-run -f json`.split("\n").last
    #   available_descriptions = JSON.parse(json_text)['examples'].map { |example_data| example_data['full_description'] }
    #
    #   available_descriptions.each do |description|
    #     description_lines[description] ||= Set.new
    #   end
    # end

    def data_from_file
      return {} unless File.exist?(coverage_path)

      json_text = File.read(coverage_path)
      return {} if json_text.nil? || json_text == ''

      JSON.parse(json_text)
    end
  end
end
