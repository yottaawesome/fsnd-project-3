#!/usr/bin/env bash

set -u

database="postgres"

apache_user="www-data"
apache_user_group="www-data"

# do not modify
yellow='\033[1;33m'
blue='\033[1;34m'
nc='\033[0m'
red='\033[1;31m'
svr_dir="../svr"
google_client_secrets_file="${svr_dir}/secret.google_client_secrets.json"
github_client_secrets_file="${svr_dir}/secret.github_client_secrets.json"
requirements_file="${svr_dir}/requirements.txt"
create_db_file="${svr_dir}/create_db.py"
cfg_json_file="${svr_dir}/cfg/secret.cfg.json"
essential_files="${svr_dir}/cfg ${svr_dir}/app ${svr_dir}/db ${svr_dir}/__init__.py ${svr_dir}/main.py"

sqlite_dir='/non/existent/dir'
if grep -Fq "sqlite:////" $cfg_json_file; then
    sqlite_dir=`grep -F "sqlite:///" ../svr/cfg/secret.cfg.json | sed -e 's/^[[:space:]]*//' | sed -e 's/"//g' | sed -e 's/conn_string://g' | sed -e 's/^[[:space:]]*//' | cut -c11-`
    sqlite_dir=${sqlite_dir%/*}
fi

containsElement () {
  local e match="$1"
  shift
  for e; do [[ "$e" == "$match" ]] && return 0; done
  return 1
}

forbidden_array=(
    "/"
    "/bin"
    "/boot"
    "/cdrom"
    "/dev"
    "/etc"
    "/home"
    "/lib"
    "/lib64"
    "/lost+found"
    "/media"
    "/mnt"
    "/opt"
    "/proc"
    "/root"
    "/run"
    "/sbin"
    "/snap"
    "/srv"
    "/swapfile"
    "/sys"
    "/tmp"
    "/usr"
    "/var")
if containsElement $sqlite_dir "${forbidden_array[@]}"; then
    echo -e "${red}sqlite_dir resolved to a protected dir ${sqlite_dir}. Aborting.${nc}"
    exit 1
fi

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
