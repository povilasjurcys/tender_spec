module TenderSpec
  class Cli
    class ReverseTestsFinder
      attr_reader :pathes

      def initialize(pathes)
        @pathes = pathes
      end

      def test_names
        full_path_test_names + line_path_test_names
      end

      private

      def line_path_test_names
        return [] if lines_by_path.empty?


        sql = lines_by_path.each.with_object([]) do |(path, lines), ors|
          ors << "(app_file_id = #{file_id_by_path[path]} AND line_no IN (#{lines.join(',')}))"
        end
        app_lines = LineTest.where(sql.join(' OR '))

        AppTest.where(id: app_lines.uniq.pluck(:app_test_id)).pluck(:description)
      end

      def full_path_test_names
        app_file_ids = AppFile.where(path: pathes_without_line_number).pluck(:id)
        app_test_ids = LineTest.where(app_file_id: app_file_ids).uniq.pluck(:app_test_id)
        AppTest.where(id: app_test_ids).pluck(:description)
      end

      def pathes_without_line_number
        @pathes_without_line_number ||= pathes.reject { |path| path.include?(':') }
      end

      def pathes_with_line_number
        pathes - pathes_without_line_number
      end

      def lines_by_path
        @lines_by_path ||= pathes_with_line_number.each.with_object({}) do |path_with_line, by_path|
          path, line = path_with_line.split(':')
          by_path[path] ||= []
          by_path[path] << line.to_i
        end
      end

      def file_id_by_path
        @file_id_by_path ||= \
          AppFile
          .where(path: lines_by_path.keys)
          .pluck(:id, :path)
          .index_by(&:last)
          .transform_values(&:first)
      end
    end
  end
end
