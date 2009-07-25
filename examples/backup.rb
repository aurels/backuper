#!/usr/bin/ruby

require 'rubygems'
require 'backuper'

################################################################################

backup = Backuper.new

# Unix general =================================================================

backup.config_file "/etc/ssh/sshd_config"
backup.config_file "/etc/passwd"
backup.config_file "/etc/group"
backup.config_file "/etc/contab"

# Apache2 ======================================================================

backup.config_file "/etc/apache2/httpd.conf"
backup.config_dir  "/etc/apache2/sites-available"

# Nginx ========================================================================

backup.config_file "/opt/nginx/conf/nginx.conf"
backup.config_dir  "/opt/nginx/conf/sites-available"

# SQLite databases =============================================================

backup.sqlite_database "/home/aurels/databases/espassvie.sqlite3"
                                                                
# MySQL databases ==============================================================

backup.mysql_params = {
  :user    => 'backup',
  :password => 'blup'
}

# We recommend creating a 'backup' user with only SELECT and LOCK TABLES
# privileges :
#
# mysql -u root -p
# GRANT SELECT, LOCK TABLES ON *.* TO backup@localhost IDENTIFIED BY 'blup';
# FLUSH PRIVILEGES;

backup.mysql_database 'db1'
backup.mysql_database 'db2'

# Data directories =============================================================

backup.data_dir "/super/projet/rails/public/assets"

# FTP or SSH setup =============================================================

backup.ftp_params = {
  :host     => '',
  :user     => '',
  :password => '',
  :path     => '/backups' # path on host
}

# or:

#backup.ssh_params = {
#  :host => '',
#  :user => '', # this user needs to have his public key authorized on the host
#  :path => '/home/aurels/backups' # path on host
#}

################################################################################

backup.perform!