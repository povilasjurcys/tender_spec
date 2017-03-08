require 'singleton'

module TenderSpec
  class Configuration
    include Singleton

    DEFAULTS = {
      rspec_command: 'rspec',
      runner: 'rspec',
      storage: nil
    }.freeze

    DEFAULTS.each do |method_name, default_value|
      define_method "#{method_name}=" do |value|
        options[method_name] = value
      end

      define_method method_name do
        options[method_name] ||= options.fetch(method_name, default_value)
      end
    end

    def storage
      options[:storage] || default_storage
    end

    def options
      @options ||= {}
    end

    private

    def default_storage
      @default_storage ||= p(Rails.configuration.database_configuration['tender_spec'])
    end
  end
end
