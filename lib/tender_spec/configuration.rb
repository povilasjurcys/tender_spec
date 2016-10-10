require 'tender_spec'
require 'singleton'

module TenderSpec
  class Configuration
    include Singleton

    DEFAULTS = {
      rspec_command: 'rspec',
      runner: 'rspec'
    }

    DEFAULTS.keys.each do |method_name|
      define_method "#{method_name}=" do |value|
        options[method_name] = value
      end

      define_method method_name do
        options[method_name]
      end
    end

    def options
      @options ||= DEFAULTS.clone
    end
  end
end
