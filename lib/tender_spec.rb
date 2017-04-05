module TenderSpec
  autoload :CLI, 'tender_spec/cli'
  autoload :VERSION, 'tender_spec/version'

  class << self
    def configure
      require 'tender_spec/configuration'

      yield Configuration.instance if block_given?
      Configuration.instance
    end

    def root
      File.dirname __dir__
    end
  end
end
