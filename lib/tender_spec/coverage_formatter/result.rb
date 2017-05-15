module TenderSpec
  module CoverageFormatter
    require 'simplecov'

    class Result < SimpleCov::Result
      def filter!; end
    end
  end
end
