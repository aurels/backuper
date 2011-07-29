# coding: utf-8

class Backuper
    
  attr_accessor :source_path, :local_backup_base_path, :remote_backup_ssh_info,
                :remote_backup_base_path, :max_kept_backups, :mysql_params,
                :mongodb_params
  
  def initialize(&block)
    instance_eval(&block)
    
    mysql_params['host']     ||= 'localhost'
    mysql_params['username'] ||= 'root'
    
    system "mkdir -p #{local_backup_base_path}"
    
    perform_files_backup
    perform_database_backup
    perform_mongodb_backup
    perform_remote_sync
  end
  
  def set(attribute, value)
    instance_variable_set("@#{attribute}", value)
  end
  
  def perform_files_backup
    timestamp = "#{Time.now.strftime('%Y-%m-%d-%s')}"
    local_current_backup_path = "#{local_backup_base_path}/files/#{timestamp}"
    local_latest_backup_path = Dir["#{local_backup_base_path}/files/*"].sort.last
    system "mkdir -p #{local_current_backup_path}"
    
    # Local backup
    
    if File.exist?("#{local_latest_backup_path}")
      puts "Performing local backup with hard links to pervious version"
      system "nice -n 10 rsync -az --delete --link-dest=#{local_latest_backup_path} #{source_path} #{local_current_backup_path}"
    else
      puts "Performing initial local backup"
      system "nice -n 10 rsync -az #{source_path} #{local_current_backup_path}"
    end
    
    # Cleanup of old versions
    
    Dir["#{local_backup_base_path}/files/*"].sort.reverse.each_with_index do |backup_version, index|
      if index >= max_kept_backups
        system "rm -rf #{backup_version}"
      end
    end
  end
  
  def perform_database_backup
    if mysql_params == {} || mysql_params['database'] == '' || !(mysql_params['adapter'] =~ /mysql/)
      puts "Skipping MySQL backup as no configurtion given"
      return
    end
    
    timestamp = "#{Time.now.strftime('%Y-%m-%d-%s')}"
    local_current_backup_path = "#{local_backup_base_path}/mysql/#{timestamp}.sql"
    local_latest_backup_path = Dir["#{local_backup_base_path}/mysql/*.sql"].sort.last
    
    unless File.exist?("#{local_backup_base_path}/mysql")
      system "mkdir #{local_backup_base_path}/mysql"
    end
    
    # Local backup
    
    puts "Performing local backup of database '#{mysql_params['database']}' as user '#{mysql_params['username']}'"
    system "nice -n 10 mysqldump #{mysql_params['database']} --user=#{mysql_params['username']} --password=#{mysql_params['password']} > #{local_current_backup_path}"
    
    # Cleanup of old versions
    
    Dir["#{local_backup_base_path}/mysql/*"].sort.reverse.each_with_index do |backup_version, index|
      if index >= max_kept_backups
        system "rm -rf #{backup_version}"
      end
    end
  end
  
  def perform_mongodb_backup
    if mongodb_params == {}
      puts "Skipping MongoDB backup as no configurtion given"
      return
    end
    
    timestamp = "#{Time.now.strftime('%Y-%m-%d-%s')}"
    local_current_backup_path = "#{local_backup_base_path}/mongodb/#{timestamp}"
    local_latest_backup_path = Dir["#{local_backup_base_path}/mongodb/*"].sort.last
    
    unless File.exist?("#{local_backup_base_path}/mongodb")
      system "mkdir #{local_backup_base_path}/mongodb"
    end
    
    # Local backup
    
    puts "Performing local backup of mongo database '#{mongodb_params['database']}'"
    system "mkdir #{local_current_backup_path}"
    system "nice -n 10 mongodump #{mongodb_params['database']} --out #{local_current_backup_path}"
    
    # Cleanup of old versions
    
    Dir["#{local_backup_base_path}/mongodb/*"].sort.reverse.each_with_index do |backup_version, index|
      if index >= max_kept_backups
        system "rm -rf #{backup_version}"
      end
    end
  end
  
  def perform_remote_sync
    puts "Performing remote backup sync"
    system "nice -n 10 rsync -azH --delete #{local_backup_base_path} #{remote_backup_ssh_info}"
    puts "Done"
  end
end