module TenderSpec
  class AppTest < ActiveRecord::Base
    include LocalModel
    has_many :line_tests
  end
end
