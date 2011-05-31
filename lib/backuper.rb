class Backuper
    
  attr_accessor :source_path, :local_backup_base_path, :remote_backup_ssh_info,
                :remote_backup_base_path, :max_kept_backups, :mysql_params
  
  def initialize(&block)
    instance_eval(&block)
    
    mysql_params['host']     ||= 'localhost'
    mysql_params['username'] ||= 'root'
    
    system "mkdir -p #{local_backup_base_path}"
    
    perform_files_backup
    perform_database_backup
    perform_remote_sync
  end
  
  def set(attribute, value)
    instance_variable_set("@#{attribute}", value)
  end
  
  def perform_files_backup
    timestamp = "#{Time.now.strftime('%Y-%m-%d-%s')}"
    local_current_backup_path = "#{local_backup_base_path}/files/#{timestamp}"
    local_latest_backup_path = Dir["#{local_backup_base_path}/files/*"].last
    system "mkdir -p #{local_current_backup_path}"
    
    # Local backup
    
    if File.exist?("#{local_latest_backup_path}")
      puts "Performing local backup with hard links to pervious version"
      system "rsync -az --delete --link-dest=#{local_latest_backup_path} #{source_path} #{local_current_backup_path}"
    else
      puts "Performing initial local backup"
      system "rsync -az #{source_path} #{local_current_backup_path}"
    end
    
    # Cleanup of old versions
    
    Dir["#{local_backup_base_path}/files/*"].reverse.each_with_index do |backup_version, index|
      if index >= max_kept_backups
        system "rm -rf #{backup_version}"
      end
    end
  end
  
  def perform_database_backup
    return if mysql_params['database'] == '' || !(mysql_params['adapter'] =~ /mysql/)
    
    timestamp = "#{Time.now.strftime('%Y-%-m-%d-%s')}"
    local_current_backup_path = "#{local_backup_base_path}/mysql/#{timestamp}.sql"
    local_latest_backup_path = Dir["#{local_backup_base_path}/mysql/*.sql"].last
    
    unless File.exist?("#{local_backup_base_path}/mysql")
      system "mkdir #{local_backup_base_path}/mysql"
    end
    
    # Local backup
    
    puts "Performing local backup of database '#{mysql_params['database']}' as user '#{mysql_params['username']}'"
    system "mysqldump #{mysql_params['database']} --user=#{mysql_params['username']} --password=#{mysql_params['password']} > #{local_current_backup_path}"
    
    # Cleanup of old versions
    
    Dir["#{local_backup_base_path}/mysql/*"].reverse.each_with_index do |backup_version, index|
      if index >= max_kept_backups
        system "rm -rf #{backup_version}"
      end
    end
  end
  
  def perform_remote_sync
    puts "Performing remote backup sync"
    system "rsync -azH --delete #{local_backup_base_path} #{remote_backup_ssh_info}"
    puts "Done"
  end
end