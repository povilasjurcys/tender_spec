module TenderSpec
  module Generators
    class InstallGenerator < ::Rails::Generators::Base
      NO_DB_MESSAGE = \
        "\n\n== OH NOES! ==\n\nDatabase %{database} not found.\n" \
        "Please run `rake db:create RAILS_ENV=tender_spec` before running `rails g tender_spec:install` again\n"

      SUCCESS_MESSAGE = "\nWOOHO! tender_spec setup is done :)".freeze

      INITIALIZER_DESTINATION_PATH = 'config/initializers/tender_spec.rb'.freeze
      source_root File.expand_path('../templates', __FILE__)

      def copy_initializer_file
        copy_file 'tender_spec.rb', INITIALIZER_DESTINATION_PATH
      end

      def copy_rspec_hook
        return unless File.exist?('spec/spec_helper.rb')
        prepend_to_file 'spec/spec_helper.rb', "require 'tender_spec/hooks/rspec'\n"
      end

      def migrate
        load INITIALIZER_DESTINATION_PATH # reload initializer
        puts SUCCESS_MESSAGE if migrate_database
      end

      private

      def migrate_database
        create_db_tables
      rescue ActiveRecord::NoDatabaseError
        puts NO_DB_MESSAGE % { database: Configuration.instance.storage['database'].inspect }
        false
      end

      def create_db_tables
        create_app_files_database
        create_app_tests_database
        create_line_tests_database
        true
      end

      def create_app_files_database
        require 'tender_spec/models/app_file'

        create_model_database(AppFile, unique_index: :path) do |t|
          t.string :path
        end
      end

      def create_app_tests_database
        require 'tender_spec/models/app_test'

        unique_index = {
          fields: [:description],
          length: { description: 1000 }
        }

        create_model_database(AppTest, unique_index: unique_index) do |t|
          t.text :description, length: 1000
        end
      end

      def create_line_tests_database
        require 'tender_spec/models/line_test'

        unique_index = {
          fields: [:app_test_id, :app_file_id, :line_no, :sha],
          name: :line_uniqueness_idx
        }

        create_model_database(LineTest, unique_index: unique_index) do |t|
          t.integer :app_file_id
          t.integer :app_test_id
          t.integer :line_no
          t.string :sha
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
