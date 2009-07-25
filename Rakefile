require 'rake'
require 'lib/backuper'

desc "Show the crontab"
task :update_crontab do
  run "whenever"
end

desc "Updates the crontab"
task :update_crontab do
  run "whenever --update-crontab backuper"
end