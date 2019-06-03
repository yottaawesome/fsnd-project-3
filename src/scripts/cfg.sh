#!/usr/bin/env bash

set -u

database="postgres"

# do not modify
svr_dir="../svr"
google_client_secrets_file="${svr_dir}/secret.google_client_secrets.json"
github_client_secrets_file="${svr_dir}/secret.github_client_secrets.json"
requirements_file="${svr_dir}/requirements.txt"
create_db_file="${svr_dir}/create_db.py"
essential_files="${svr_dir}/cfg ${svr_dir}/app ${svr_dir}/db ${svr_dir}/__init__.py ${svr_dir}/main.py"

# where the Bookshelf Apache dir lives
apache_bookshelf_dir="/var/www/bookshelf"

# the directory to place secret.* files for GitHub and Google
installed_secrets_dir="${apache_bookshelf_dir}"

# Apache's sites-available dir
apache_sites_available_dir="/etc/apache2/sites-available"
# Where the WSGi script should live
wsgi_scripts_dir="/usr/local/www/bookshelf/wsgi"

wsgi_script_name="bookshelf.wsgi"

conf_file_name="bookshelf.conf"

installed_conf_file="${apache_sites_available_dir}/${conf_file_name}"

virtualenv="${HOME}/.local/bin/virtualenv"
virtualenv_dir="${apache_bookshelf_dir}/env"
virtualenv_activate="${virtualenv_dir}/bin/activate"

wsgi_script="../apache-wsgi/${wsgi_script_name}"
conf_file="../apache-wsgi/${conf_file_name}"

copied_example_cfg_file="${apache_bookshelf_dir}/cfg/example.secret.cfg.json"
