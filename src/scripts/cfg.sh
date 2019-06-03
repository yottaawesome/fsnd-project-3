#!/usr/bin/env bash

set -u

#https://stackoverflow.com/a/10383546
apache_bookshelf_dir="/var/www/bookshelf"
apache_sites_available_dir="/etc/apache2/sites-available"
wsgi_scripts_dir="/usr/local/www/bookshelf"
usr_dir="/usr/local/www/bookshelf"
wsgi_script_name="bookshelf.wsgi"
conf_file_name="bookshelf.conf"
svr_dir="../svr"

virtualenv="${HOME}/.local/bin/virtualenv"
virtualenv_dir="${apache_bookshelf_dir}/env"
virtualenv_activate="${virtualenv_dir}/bin/activate"

wsgi_script="../apache-wsgi/${wsgi_script_name}"
conf_file="../apache-wsgi/${conf_file_name}"

copied_requirements_file="${apache_bookshelf_dir}/requirements.txt"
copied_tests_dir="${apache_bookshelf_dir}/tests"
copied_example_cfg_file="${apache_bookshelf_dir}/cfg/example.secret.cfg.json"
copied_example_github_client_file="${apache_bookshelf_dir}/example.secret.github_client_secrets.json"
