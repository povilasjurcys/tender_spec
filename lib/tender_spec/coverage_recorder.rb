module TenderSpec
  class CoverageRecorder
    def record_exists?
      File.exist?(destination_file_path)
    end

    def destination_file_path
      repo = Rugged::Repository.new('.')
      [DirLocatable::INNER_ROOT_DIR, repo.head.target_id].join('/')
    end
  end
end
