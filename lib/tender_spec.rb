module TenderSpec
  autoload :Cli, 'tender_spec/cli'
  autoload :VERSION, 'tender_spec/version'
  autoload :Configuration, 'tender_spec/configuration'
  autoload :AppTest, 'tender_spec/models/app_test'
  autoload :LineTest, 'tender_spec/models/line_test'
  autoload :AppFile, 'tender_spec/models/app_file'
  autoload :RunnableTestsFinder, 'tender_spec/runnable_tests_finder'
  autoload :DirLocatable, 'tender_spec/dir_locatable'

  class << self
    def configure
      yield Configuration.instance if block_given?
      Configuration.instance
    end

    def root
      File.dirname __dir__
    end
  end
end
