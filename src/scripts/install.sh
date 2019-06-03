#!/usr/bin/env bash

#https://stackoverflow.com/a/10383546

# import config paths
# https://stackoverflow.com/a/246128
dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" > /dev/null && pwd )"
cfg_file=$dir"/cfg.sh"
sql_install_file=$dir"/install.sql"
source $cfg_file

yellow='\033[1;33m'
blue='\033[1;34m'
nc='\033[0m'

# $? gives the return value of the last command
if grep -Fq "postgres" $cfg_json_file; then
    sudo -u postgres psql -f $sql_install_file
elif grep -Fq "sqlite:////" $cfg_json_file; then
    echo -e "${blue}Don't forget to set permissions on your SQLite directory.${nc}"
elif grep -Fq "sqlite:///" $cfg_json_file; then
    echo -e "${yellow}WARNING: Relative SQLite db path detected. This works for development but will likely cause problems in WSGI deployments. Consider an absolute path.${nc}"
fi

# make directories
mkdir -p $apache_bookshelf_dir
mkdir -p $wsgi_scripts_dir

# copy bookshelf.wsgi
cp $wsgi_script $wsgi_scripts_dir

# copy bookshelf.conf
cp $conf_file $apache_sites_available_dir

# copy src/svr to Apache bookshelf folder
cp -R ${essential_files} $apache_bookshelf_dir

# copy client secrets files
cp $google_client_secrets_file $github_client_secrets_file $installed_secrets_dir 

# create virtual environment
$virtualenv -p python3 $virtualenv_dir

# change the owner of the env folder to enable pip to install deps
chown -R $USER:$USER $virtualenv_dir

# activate env
source $virtualenv_activate

# install deps
pip install -q -r $requirements_file

# install the DB
python $create_db_file

# deactivate and clean up unnecessary files
deactivate
rm -rf $copied_example_cfg_file

# enable and reload Apache
a2ensite bookshelf.conf
systemctl reload apache2