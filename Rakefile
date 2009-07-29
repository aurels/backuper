require 'rake'
require 'lib/backuper'

desc "Executes a backup profile"
task :backup do
  Backuper.perform_profile(ARGS[1].split('=')[1])
end

desc "Show the crontab"
task :crontab do
  puts `whenever`
end

desc "Updates the crontab"
task :update_crontab do
  puts `whenever --update-crontab backuper`
end