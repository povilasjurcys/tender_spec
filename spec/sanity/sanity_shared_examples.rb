require 'English'

shared_examples 'a sanity check' do |framework, run_cmd|
  describe framework, :slow do
    let(:sandbox_uuid) { SecureRandom.uuid[0..7] }
    let(:app_path) { File.expand_path('fake_app', File.dirname(__FILE__)) }
    let(:sandbox_path)  { File.expand_path(sandbox_uuid, File.dirname(__FILE__)) }
    let(:sandbox_app_path) { File.join(sandbox_path, 'fake_app') }
    let(:framework) { framework }

    before do
      FileUtils.mkdir sandbox_path
      FileUtils.cp_r app_path, sandbox_app_path
    end

    after { FileUtils.rm_r sandbox_path }

    context 'collecting' do
      let(:tender_spec_dir) { File.join(sandbox_app_path, '.tender_spec') }

      before do
        Bundler.with_clean_env do
          Dir.chdir(sandbox_app_path) do
            `git init; git add -A; git commit -m \'Initial commit\';
             COLLECT=1 bundle exec #{run_cmd}`
          end
        end
      end

      it 'creates .tender_spec dir' do
        expect(Dir.exist?(tender_spec_dir)).to be_truthy
      end

      it 'creates log_run.db' do
        run_log_path = File.join(tender_spec_dir, 'run_log.db')
        expect(File.exist?(run_log_path)).to be_truthy
      end

      describe 'tender_spec command' do
        def exec_tender_spec
          Dir.chdir(sandbox_app_path) do
            `bundle exec tender_spec #{framework}`
          end
        end

        context 'without any changes' do
          it 'runs nothing' do
            output = exec_tender_spec
            expect($CHILD_STATUS.to_i).to eq(0)
            expect(output).to eq('')
          end
        end

        context 'after modifying lib files' do
          before do
            Dir["#{sandbox_app_path}/lib/*_modified.rb"].each do |modified|
              FileUtils.cp modified, modified.gsub('_modified', '')
            end
          end

          it 'runs the predicted examples' do
            output = exec_tender_spec

            tender_spec_result_matches.each do |match|
              expect(output).to include(match)
            end
          end
        end
      end
    end
  end
end
