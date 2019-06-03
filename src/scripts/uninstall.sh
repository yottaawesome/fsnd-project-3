#!/usr/bin/env bash

# import config paths
# https://stackoverflow.com/a/246128
dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" > /dev/null && pwd )"
cfg_file=$dir"/cfg.sh"
source $cfg_file

# disabled site
a2dissite bookshelf.conf
systemctl reload apache2

# clear directories
rm -rf $apache_bookshelf_dir
rm -rf $usr_dir
rm -rf "${apache_sites_available_dir}/${conf_file_name}"
