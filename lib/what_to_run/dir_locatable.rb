module WhatToRun
  module DirLocatable
    INNER_ROOT_DIR = '.what_to_run'.freeze

    def root_path # override in class if you need more specific path
    end

    def current_log_dir
      [root_path, INNER_ROOT_DIR, shared_commit_key].compact.join('/')
    end

    def shared_commit_key
      @shared_commit_key ||= `git merge-base HEAD origin/master`.strip
    end

    def coverage_json_path
      "#{current_log_dir}/coverage.json"
    end
  end
end
