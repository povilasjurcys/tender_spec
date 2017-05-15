require 'rugged'

module TenderSpec
  module DirLocatable
    INNER_ROOT_DIR = '.tender_spec'.freeze

    def current_log_dir
      head_id = repository.head.target_id
      [INNER_ROOT_DIR, head_id].join('/')
    end

    def repository
      @repository ||= Rugged::Repository.discover('.')
    end

    def shared_commit_key
      @shared_commit_key ||= `git merge-base HEAD origin/master`.strip
    end

    def app_copy_path
      "#{current_log_dir}/app"
    end
  end
end
