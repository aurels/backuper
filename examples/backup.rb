#!/usr/bin/ruby

require 'rubygems'
require 'backuper'

################################################################################

backup = Backuper.new

# Unix general #################################################################

backup.config_file "/etc/ssh/sshd_config"
backup.config_file "/etc/passwd"
backup.config_file "/etc/group"
backup.config_file "/etc/contab"

# Apache2 ######################################################################

backup.config_file "/etc/apache2/httpd.conf"
backup.config_dir  "/etc/apache2/sites-available"

# SQLite databases #############################################################

backup.sqlite_database "/path/to/my/database1.sqlite3"
backup.sqlite_database "/path/to/my/database2.sqlite3"

# MySQL databases ##############################################################

# use creadentials which have at least all read access
backup.mysql_params = {
  :user    => 'your my sql user',
  :pasword => 'yout sql pass'
}

backup.mysql_database 'db1'
backup.mysql_database 'db2'

# Data directories #############################################################

backup.data_dir "/a/folder/important/to/me"
backup.data_dir "/another/folder/important/to/me"

# FTP setup ####################################################################

backup.ftp_params = {
  :host     => 'ftp host',
  :user     => 'ftp username',
  :password => 'ftp password',
  :path     => '/backups'
}

################################################################################

backup.perform!
