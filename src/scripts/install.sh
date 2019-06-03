#!/usr/bin/env bash

USER=$1

# import config paths
# https://stackoverflow.com/a/246128
dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" > /dev/null && pwd )"
cfg_file=$dir"/cfg.sh"
source $cfg_file

# make directories
mkdir -p $apache_bookshelf_dir
mkdir -p $wsgi_scripts_dir

# copy bookshelf.wsgi
cp $wsgi_script $wsgi_scripts_dir

# copy bookshelf.conf
cp $conf_file $apache_sites_available_dir

# copy src/svr to Apache bookshelf folder
cp -R "${svr_dir}/." $apache_bookshelf_dir

# remove any copies env dir
rm -rf $virtualenv_dir

# create a virtual environment
$virtualenv -p python3 $virtualenv_dir

# change the owner of the env folder to enable pip to install deps
chown -R $USER:$USER $virtualenv_dir

# activate env
source $virtualenv_activate

# install deps
pip install -r $copied_requirements_file

# deactivate and clean up unnecessary files
deactivate
rm -rf $copied_tests_dir
rm -rf $copied_requirements_file
rm -rf $copied_example_cfg_file
rm -rf $copied_example_github_client_file

# enable and reload Apache
a2ensite bookshelf.conf
systemctl reload apache2