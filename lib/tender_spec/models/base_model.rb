require 'active_support/concern'
require 'active_record'
require 'tender_spec/configuration'

module TenderSpec
  module BaseModel
    extend ActiveSupport::Concern

    included do
      establish_connection Configuration.instance.storage
      self.table_name_prefix = 'tender_spec_'
    end
  end
end
