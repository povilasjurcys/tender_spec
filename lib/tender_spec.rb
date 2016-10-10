require 'set'
require 'rugged'

require_relative 'tender_spec/tracker'
require_relative 'tender_spec/coverage_storage'
require_relative 'tender_spec/git_changes_detector'
require_relative 'tender_spec/configuration'

module TenderSpec
  autoload :CLI, 'tender_spec/cli'
  autoload :VERSION, 'tender_spec/version'

  class << self
    def configure
      yield Configuration.instance if block_given?
      Configuration.instance
    end
  end
end
