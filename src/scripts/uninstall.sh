#!/usr/bin/env bash

# import config paths
# https://stackoverflow.com/a/246128
dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" > /dev/null && pwd )"
cfg_file=$dir"/cfg.sh"
sql_uninstall_file=$dir"/uninstall.sql"
source $cfg_file

if [ "$database" = "postgres" ]; then
    sudo -u postgres psql -d bookshelf -f $sql_uninstall_file
elif [ "$database" = "sqlite" ]; then
    echo "No action for SQLite"
fi

# disable site
a2dissite bookshelf.conf
systemctl reload apache2

# clear directories
rm -rf $installed_secrets_dir
rm -rf $apache_bookshelf_dir
rm -rf $installed_conf_file
rm -rf $installed_secrets_dir