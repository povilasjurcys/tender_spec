require 'tender_spec/models/base_model'

module TenderSpec
  class AppFile < ActiveRecord::Base
    include BaseModel
    has_many :line_tests
  end
end
