module TenderSpec
  module Generators
    class InstallGenerator < ::Rails::Generators::Base
      INITIALIZER_DESTINATION_PATH = 'config/initializers/tender_spec.rb'.freeze
      source_root File.expand_path("../templates", __FILE__)

      def copy_initializer_file
        copy_file 'tender_spec.rb', INITIALIZER_DESTINATION_PATH
      end

      def migrate
        load INITIALIZER_DESTINATION_PATH # reload initializer

        create_app_files_database
        create_app_tests_database
        create_line_tests_database
      end

      private

      def create_app_files_database
        require 'tender_spec/models/app_file'

        create_model_database(AppFile, unique_index: :path) do |t|
          t.string :path
        end
      end

      def create_app_tests_database
        require 'tender_spec/models/app_test'

        create_model_database(AppTest, unique_index: :description) do |t|
          t.text :description, length: 1000
        end
      end

      def create_line_tests_database
        require 'tender_spec/models/line_test'

        unique_index = {
          fields: [:app_test_id, :app_file_id, :line_no],
          name: :line_uniqueness_idx
        }

        create_model_database(LineTest, unique_index: unique_index) do |t|
          t.integer :app_file_id
          t.integer :app_test_id
          t.integer :line_no
        end
      end

      def add_unique_index_to(model, options)
        index_options = if options.is_a?(Hash)
          options.clone
        else
          { fields: options }
        end

        fields = index_options.delete(:fields)
        model.connection.add_index(model.table_name, fields, index_options)
      end

      def create_model_database(model, unique_index: nil)
        connection = model.connection
        table_name = model.table_name

        return if connection.table_exists?(table_name)

        connection.create_table(table_name) do |table|
          yield(table)
        end

        add_unique_index_to(model, unique_index) if unique_index
      end
    end
  end
end
