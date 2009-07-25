class Backuper
  
  TMP_DIR = "/tmp/backuper"
  
  attr_writer :mysql_params
  attr_writer :ftp_params
  attr_writer :ssh_params
  
  def initialize
    @config_files     = []
    @config_dirs      = []
    @sqlite_databases = []
    @mysql_params     = {}
    @mysql_databases  = []
    @data_dirs        = []
    @ftp_params       = {}
    @ssh_params       = {}
    @archive_filename = "backup-#{Time.now.strftime('%Y-%m-%d')}-#{Time.now.to_i}.tar.gz"
  end
  
  def self.perform_profile(profile)
    unless File.exist?(File.join('.', 'config', 'profiles', "#{profile}.rb"))
      say "#{profile} backup profile does not exist"
    else
      require "config/profiles/#{profile}"
      say "backup profile #{profile} performed"
    end
  end
  
  def config_file(path)
    @config_files << path
  end
  
  def config_dir(path)
    @config_dirs << path
  end
  
  def sqlite_database(path)
    @sqlite_databases << path
  end
  
  def mysql_database(name)
    @mysql_databases << name
  end
  
  def data_dir(path)
    @data_dirs << path
  end
  
  def perform!
    self.prepare
    self.backup_config_files_and_dirs
    self.backup_sqlite_databases
    self.backup_mysql_databases
    self.create_archive
    self.upload_archive
    self.cleanup
  end
  
  protected
  
  def prepare
    run "mkdir #{TMP_DIR}"
    run "mkdir #{File.join(TMP_DIR, 'config_files')}"
    run "mkdir #{File.join(TMP_DIR, 'databases')}"
    run "mkdir #{File.join(TMP_DIR, 'databases', 'sqlite')}"
    run "mkdir #{File.join(TMP_DIR, 'databases', 'mysql')}"
  end
  
  def backup_config_files_and_dirs
    @config_files.each do |config_file|
      run "cp #{config_file} #{File.join(TMP_DIR, 'config_files')}"
    end
    @config_dirs.each do |config_dir|
      run "cp -R #{config_dir} #{File.join(TMP_DIR, 'config_files')}"
    end
  end
  
  def backup_sqlite_databases
    @sqlite_databases.each do |db|
      run "cp #{db} #{File.join(TMP_DIR, 'databases', 'sqlite')}"
    end
  end
  
  def backup_mysql_databases
    unless @mysql_params.empty?
      @mysql_databases.each do |db|
        run "mysqldump #{db} --user=#{@mysql_params[:user]} --password=#{@mysql_params[:password]} > #{File.join(TMP_DIR, 'databases', 'mysql', "#{db}.sql")}"
      end
    end
  end
  
  def create_archive
    run "tar czf /tmp/#{@archive_filename} #{TMP_DIR}"
  end
  
  def upload_archive
    unless @ftp_params.empty?
      run "ncftpput -u #{@ftp_params[:user]} -p #{@ftp_params[:password]} #{@ftp_params[:host]} #{@ftp_params[:path]} /tmp/#{@archive_filename}"
    end
    
    unless @ssh_params.empty?
      run "scp /tmp/#{@archive_filename} #{@ssh_params[:user]}@#{@ssh_params[:host]}:#{@ssh_params[:path]}"
    end
  end
  
  def cleanup
    run "rm -rf #{TMP_DIR}"
    run "rm -f /tmp/#{@archive_filename}"
  end
  
  def self.say(str)
    puts "#{str}"
  end
  
  def run(cmd)
    puts "#{cmd}"
    system("#{cmd}")
  end
end