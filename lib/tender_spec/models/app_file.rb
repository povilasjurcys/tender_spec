require 'active_record'
require_relative '../configuration'

module TenderSpec
  class AppFile < ActiveRecord::Base
    establish_connection Configuration.instance.storage
    self.table_name_prefix = 'tender_spec_'

    has_many :line_tests
  end
end
