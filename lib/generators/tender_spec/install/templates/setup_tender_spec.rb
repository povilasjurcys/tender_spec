class SetupTenderSpec < ActiveRecord::Migration
  def connection
    ActiveRecord::Base.establish_connection('tender_spec').connection
  end

  def self.up
    create_table :tender_spec_app_files do |t|
      t.string  :path
    end

    create_table :tender_spec_app_tests do |t|
      t.text :description
    end

    create_table :tender_spec_line_tests do |t|
      t.integer :app_file_id
      t.integer :app_test_id
      t.integer :line_no
      t.string :sha
    end

    add_index :tender_spec_line_tests, [:app_test_id, :app_file_id, :line_no, :sha], unique: true, name: :line_uniqueness_idx
    add_index :tender_spec_app_files, [:path], unique: true
    add_index :tender_spec_app_tests, [:description], unique: true
  end

  def self.down
    drop_table :tender_spec_app_files
    drop_table :tender_spec_app_tests
    drop_table :tender_spec_line_tests
  end
end
