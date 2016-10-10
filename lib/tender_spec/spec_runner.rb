require 'tender_spec'
require 'tender_spec/configuration'
require 'shellwords'
require 'json'
require_relative 'dir_locatable'

module TenderSpec
  class SpecRunner
    include DirLocatable

    attr_reader :command_line_options

    def initialize(command_line_options)
      @command_line_options = command_line_options
    end

    def record
      Kernel.exec "TENDER_SPEC_MODE=\"record\" #{executable} #{command_line_options}"
    end

    def run_tests
      Kernel.exec "TENDER_SPEC_MODE=\"initialize\" #{command}"
    end

    def available_descriptions
      json_text = `#{executable} --dry-run -f json #{command_line_options}`.split("\n").last
      JSON.parse(json_text)['examples'].map { |example_data| example_data['full_description'] }
    end

    private

    def command
      "#{executable} #{predicted_example_args}"
    end

    def executable
      Configuration.instance.rspec_command
    end

    def predicted_example_args
      examples = RunnableTestsFinder.new(available_descriptions: available_descriptions).test_names
      args = examples.flat_map { |example| ['-e', example] }
      Shellwords.join(args)
    end
  end
end
