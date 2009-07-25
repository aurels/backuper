require 'rake'
require 'lib/backuper'

desc 'Performs a backup'
task :backup do
  unless ARGV[1]
    puts "You must specify a backup profile name"
    puts "e.g.: rake backup PROFILE=server"
  else
    profile = ARGV[1].split('=')[1]
    unless File.exist?(File.join('.', 'config', 'profiles', "#{profile}.rb"))
      puts "#{profile} backup profile does not exist"
    else
      require "config/profiles/#{profile}"
      puts "backup profile #{profile} performed"
    end
  end
end