module TenderSpec
  class AppFile < ActiveRecord::Base
    include LocalModel
    has_many :line_tests
  end
end
