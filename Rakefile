require 'rake'
require 'lib/backuper'

desc "Executes a backup profile"
task :backup do
  Backuper.perform_profile(ARGV[1].split('=')[1])
end

desc "Show the crontab"
task :crontab do
  puts `whenever`
end

desc "Updates the crontab"
task :update_crontab do
  puts `whenever --update-crontab backuper`
end

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "backuper"
    gemspec.summary = "simple server backup tool"
    gemspec.description = "simple server backup tool"
    gemspec.email = "aurelien.malisart@gmail.com"
    gemspec.homepage = "http://github.com/aurels/backuper"
    gemspec.authors = ["Aurélien Malisart"]
  end
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
end