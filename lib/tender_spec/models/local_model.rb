module TenderSpec
  require 'active_support/concern'
  require 'active_record'

  module LocalModel
    extend ActiveSupport::Concern

    included do
      establish_connection Configuration.instance.storage
      self.table_name_prefix = 'tender_spec_'
    end
  end
end
