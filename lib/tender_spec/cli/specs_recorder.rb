module TenderSpec
  class Cli
    class SpecsRecorder
      UNIMPORTANT_FILES = %w[
        Gemfile Gemfile.lock config/initializers/tender_spec.rb spec/spec_helper.rb
        .gitignore
      ].freeze

      UNCOMMITED_CHANGES_NOTICE = (
        'You can run record only when repo contains no uncommited changes. ' +
        'Please commit or stash them and run `tender record` again.'
      ).freeze

      def initialize(executable, command_line_options)
        @executable = executable
        @command_line_options = command_line_options
      end

      def call
        if changes_uncommited?
          puts UNCOMMITED_CHANGES_NOTICE
        else
          Kernel.exec "TENDER_SPEC_MODE=\"record\" #{executable} #{command_line_options}"
        end
      end

      private

      attr_reader :executable, :command_line_options

      def changes_uncommited?
        important_deltas = repository.index.diff.deltas.reject do |delta|
          UNIMPORTANT_FILES.include?(delta.new_file[:path])
        end
        important_deltas.any?
      end

      def repository
        @repository ||= Rugged::Repository.discover('.')
      end
    end
  end
end
