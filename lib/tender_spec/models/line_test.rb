require 'tender_spec/models/base_model'

module TenderSpec
  class LineTest < ActiveRecord::Base
    include BaseModel

    belongs_to :app_test, class_name: 'TenderSpec::AppTest'
    belongs_to :app_file, class_name: 'TenderSpec::AppFile'

    delegate :description, to: :app_test
    delegate :path, to: :app_file, prefix: :file

    def path
      "#{file_path}:#{line_no}"
    end
  end
end
