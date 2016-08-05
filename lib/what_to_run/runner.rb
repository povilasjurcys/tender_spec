require 'what_to_run'
require_relative 'dir_locatable'

module WhatToRun
  ##
  # Abstract base spec runner
  class Runner
    include DirLocatable

    attr_reader :executable, :collect

    def initialize(opts = {})
      @executable = opts.fetch(:exec)
    end

    def run
      if !data_tracked?
        full_run_with_tracking
      elsif predicted_examples.empty?
        exit 0
      else
        Kernel.exec command
      end
    end

    private

    def data_tracked?
      File.exist?(coverage_json_path)
    end

    def full_run_with_tracking
      remote_url = `git config --get remote.origin.url`.strip
      app_path = "#{current_log_dir}/app"
      current_app_path = Dir.pwd

      `git clone #{remote_url} #{app_path}` unless File.exists?(app_path)
      %w(Gemfile.personal config/database.yml config/redis.yml).each do |file_path|
        `ln -sf #{current_app_path}/#{file_path} #{current_app_path}/#{app_path}/#{file_path}`
      end

      Kernel.exec "cd #{app_path} && git checkout #{shared_commit_key} && COLLECT_WHAT_TO_RUN=\"#{current_app_path}\" #{executable} && cd #{current_app_path}"
    end

    def command
      "#{executable} #{predicted_example_args}"
    end

    def predicted_example_args
      fail NotImplementedError, 'Subclass must override #predicted_example_args'
    end

    def predicted_examples
      @predicted_examples ||= WhatToRun.predict
    end
  end
end
