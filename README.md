# FSND Project 3: Going live with Digital Bookshelf

This is the final project for Udacity's Full Stack Developer Nanodegree. This project sees the deployment of [Project 2: Digital Bookshelf](https://github.com/yottaawesome/fsnd-project-2) to a live, configured, and secured Ubuntu server hosted via Amazon Lightsail.

## Status

_Complete. Successfully graded. Lightsail instance decommissioned._ **Warning:** I'm no longer committing to this repo as it was for an assessment which is now complete. Some dependencies are now reporting vulnerabilities, so don't use anything from this repo in production code without validation.

## Application URL

Digital Bookshelf was live and has now been taken down following successful grading. I used one of my parked domains in order to enable SSL as I was uncomfortable having information passed around in plaintext over the Web. Following grading, I revoked the SSL certificates, deleted the Lightsail instance, and parked my domain again. However, I plan on hosting Digital Bookshelf under a subdomain on my personal Azure Ubuntu VM at a later time.

## How to SSH in as the grader user

I chose to change the default SSH port to 1012. This is a well-known port that requires `root` access to listen on. This means if a malicious non-`root` user manages to access the server, they can't potentially [crash the SSH daemon and replace it with their own](https://serverfault.com/a/232242).

The private key for user grader is surrendered as part of the submission process and is not present in this repository. I have also altered the server to allow grader to run `sudo` without having to enter their password. This is purely out of convenience and I would not normally recommend this for an online server.

Using the submitted private key, follow the instructions below to SSH in.

1. In your `~/.ssh` folder, run `sudo vim config`.
2. Append the following lines, save your changes, and close the file:

    ```config
    Host 13.236.68.94
    User grader
    Port 1012
    IdentityFile ~/.ssh/grader_id_rsa
    ```

3. Run `sudo vim grader_id_rsa`.
4. Copy the submitted private key into the file, save your changes, and close the file.
5. Run `ssh grader@13.236.68.94`.

## Summary of software installed

* `fail2ban`: bans IP addresses that have failed authentication in rapid succession.
* `virtualenv`: required to isolate the Digital Bookshelf application into its own environment.
* `apache2`: server that hosts the Digital Bookshelf application.
* `postgresql-11`: to provide the Digital Bookshelf with data persistence.
* `libapache2-mod-wsgi-py3`: the Python 3 version of `mod_wsgi`; necessary for serving Python applications from Apache.
* `python-certbot-apache`: automates server SSL certificate creation, Apache configuration, and redirection (very useful!).

## Installing with scripts

In the `src/scripts` directory are scripts for installing and uninstalling the application. It's strongly recommended you first set up your `secret.cfg.json`, `secret.github_client_secrets.json`, and `secret.google_client_secrets.json` files before running these scripts. This will allow the scripts to copy the required files and set up the database. In particular, remember to set up the connection string `conn_string` in `secret.cfg.json`. Below are some examples of connection string usings Postgres and SQLite.

* Example using Postgres: `postgres://bookshelfuser:<password>@localhost:5432/bookshelf`
* Example using SQLite and relative path: `sqlite:///bookshelf.db`
* Example using SQLite and absolute path: `sqlite:////usr/local/bookshelf/db/bookshelf.db`

Before you can run these scripts, you'll need to mark them as executable. Run the following.

* `chmod +x cfg.sh`
* `chmod +x install.sh`
* `chmod +x uninstall.sh`

Modify `cfg.sh` with the appropriate variables for your setup, e.g. where you want your Apache Bookshelf directory to be, where your WSGI scripts should be, where your `virtualenv` is located, etc. `$installed_secrets_dir` should match where you `secret.*` client secrets files are in `secret.cfg.json`. You may also need to modify the `bookshelf.conf` file for directory permissions if you install in other places than what this repository assumes.

If you're using Postgres, modify the install.sql file to have the password for your database user. The scripts themselves will autodetect whether you're using Postgres or not, but the database creation to Postgres will only occur if the connection string specifies localhost.

If you're using SQLite, the Apache user will [need to own and have read-write permissions to the directory](https://stackoverflow.com/questions/42260451/proper-write-permissions-for-apache-user-with-sqlite) where the SQLite database is. The scripts will try to account for this by extracting the absolute path from the `conn_string` attribute in `secret.cfg.json` and changing the owner to `$apache_user` and `$apache_user_group`. Ensure that you verify these values are correct for your server setup.

```Bash
chown -R www-data:www-data <your_sqlite_dir>
chmod -R u+w <your_sqlite_dir>
```

## Summary of changes to Digital Bookshelf

A number of changes to the Digital Bookshelf application were necessary to prepare it for deployment. All of these improvements have been backported to the [Project 2 repository](https://github.com/yottaawesome/fsnd-project-2).

* Added `psycopg2-binary` to `requirements.txt` to enable SQLAlchemy to use PostgreSQL.
* Created a new module `cfg` to hold configuration information located in `secret.cfg.json`, such as absolute paths to `secret.*` files, the server session key, and the database connection string.
* Refactored the existing codebase (mainly the `dal` and `app`) modules to use the new `cfg` module for configuration data and to remove relative file paths that were causing issues.
* Refactored `main.py` to export the `flask` app (required for the WSGI script), remove dynamic session key generation, and not run in debug server mode unless it is directly invoked.

## Detailed list of actions and changes

The order this list is in is not the order I took these actions in due to the fact I often discovered issues after the logical sequence of steps were undertaken, and sometimes some experimentation was required. I've nonetheless ordered this list in a logical sequence for future reference.

During development of this project, `sudo apt update` and `sudo apt upgrade` were regularly used to keep the software up-to-date.

* Enabled port 443 in Amazon Networking tab for SSL.
* Set the timezone to Australian Central Standard Time (ACST -- GMT+9:30): `sudo dpkg-reconfigure tzdata`.
* Enabled UFW:
  * Enabled SSH: `sudo ufw allow ssh`.
  * Enabled HTTP: `sudo ufw allow http`.
  * Enabled HTTPS: `sudo ufw allow https`.
  * Enabled NTP: `sudo ufw allow ntp`.
  * Enable alternate SSH port: `sudo ufw allow 1012`.
  * Disabled incoming traffic by default: `sudo ufw default deny incoming`.
  * Enabled outgoing traffic by default: `sudo ufw default allow outgoing`.
  * Enable UFW: `sudo ufw enable`.
* Disabled SSH root login.
  * Edit global SSHD config file: `sudo vim /etc/ssh/sshd_config`.
  * Edit `PermitRootLogin` setting to be `PermitRootLogin no`.
* Change default SSH port to 1012:
  * Snapshot VM in case we lock ourselves out.
  * Double-check port 1012 is enabled in UFW: `sudo ufw status`.
  * Open port 1012 in Amazon networking tab.
  * Open `sshd_config`: `sudo vim /etc/ssh/sshd_config`.
  * Change `# Port 22` to `Port 1012`.
  * Restart SSHD: `service sshd restart`.
  * Connect as `ubuntu` to confirm change is nominal.
  * Deny port 22: `sudo ufw deny ssh`.
  * Remove SSH from allowed firewall ports in Lightsail.
* Installed fail2ban: `sudo apt install fail2ban`.
* Created and configured user grader.
  * Create user: `adduser grader`.
  * Add grader to `sudo` group: `usermod -aG sudo grader`.
  * Login as grader: `su - grader`.
  * Create `.ssh`: `mkdir ~/.ssh`.
  * Generate keypair for grader: `ssh-keygen -t rsa -b 4096 -C "grader@grader.com"`.
  * Copy `id_rsa` locally and then `rm -rf ~/.ssh/id_rsa`.
  * Rename `id_rsa.pub` to `authorized_keys`: `sudo mv ~/.ssh/id_rsa.pub ~/.ssh/authorized_keys`.
  * Confirm `.ssh` has right permissions: `sudo chmod 700 ~/.ssh`.
  * Confirm `authorized_keys` has right permissions: `sudo chmod 644 ~/.ssh/authorized_keys`.
  * Remove need to enter password every time `sudo` is invoked:
    * `sudo visudo`
    * Append `grader ALL=(ALL) NOPASSWD:ALL` and save.
    * Connect as grader and test.
* Installed `virtualenv`: `sudo apt install virtualenv`.
* Installed Apache2: `sudo apt install apache2`.
* Installed PostgreSQL:
  * Install certificates: `sudo apt-get install curl ca-certificates`.
  * Add key: `curl https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -`.
  * Create `/etc/apt/sources.list.d/pgdg.list`: `sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'`.
  * Update packages: `sudo apt-get update`.
  * Install PostgreSQL: `sudo apt-get install postgresql-11`.
  * Verify with `sudo -u postgres psql`.
* Created database and configured PostgreSQL user:
  * Start PSQL: `sudo -u postgres psql`.
  * Create database: `create database bookshelf;`.
  * Create user: `create user bookshelfuser with encrypted password '<password>';`.
  * Connect to bookshelf DB: `\connect bookshelf`.
  * Grant privileges to user:
    * `grant all privileges on database bookshelf to bookshelfuser;`
    * `grant all privileges on all tables in schema public to bookshelfuser;`
    * `grant all privileges on all functions in schema public to bookshelfuser;`
* Installed `mod-wsgi` for Python 3: `sudo apt-get install libapache2-mod-wsgi-py3`.
* Enabled Apache URL Rewrite module: `sudo a2enmod rewrite`.
* Prepared web application:
  * Clone this repo.
  * Create web app directory: `var/www/bookshelf`.
  * Copy `src/svr/*` to `var/www/bookshelf`.
  * Create `virtualenv` in `var/www/bookshelf`: `sudo virtualenv -p python3 env`.
  * Change owner to install dependencies: `chown -R ubuntu:ubuntu env`.
  * Activate environment: `source env/bin/activate`.
  * Install Python dependencies: `pip install -r requirements.txt`.
  * Create database: `python create_db.py`.
  * Configure `cfg/secret.cfg.json`.
  * Remove unnecessary files:
    * `create_db.py`
    * `example.secret.github_client_secrets.py`
    * `tests/`
    * `requirements.txt`
    * `cfg/example.secret.cfg.json`
  * Add [`bookshelf.conf`](https://github.com/yottaawesome/fsnd-project-3/blob/master/src/apache-wsgi/bookshelf.conf) to `/etc/apache2/sites-available`.
  * Add [`bookshelf.wsgi`](https://github.com/yottaawesome/fsnd-project-3/blob/master/src/apache-wsgi/bookshelf.wsgi) to `/usr/local/www/wsgi-scripts`.
  * Disable `default` site: `sudo a2dissite 000-default.conf`.
  * Enable `bookshelf` app: `sudo a2ensite bookshelf.conf`.
  * Restart Apache2: `sudo systemctl restart apache2`.
* Installed `python-certbot-apache` and auto-generated SSL certificates and enabled URL rewrite from HTTP to HTTPS.
  
## Potential improvements

* Use [`mod_wsgi-express`](https://pypi.org/project/mod_wsgi/) instead of having to configure `mod_wsgi` and Apache2 the traditional way.
* Run `mod_wsgi` as a daemon using a different system account that only has permissions to the assigned Apache virtual directory. This means that if the process ever gets compromised, it would only be able to affect the Digital Bookshelf application and database.
* Containerize the app with Docker, and use Apache2 or nginx on the server as a reverse proxy to the hosted container. This allows multiple container-hosted applications to run relatively isolated from each other. I regard this to be the ideal setup.

## Resources used

A long list of resources that either directly assisted me or gave me ideas on improving the deployment process.

### Users

* https://linuxize.com/post/how-to-create-a-sudo-user-on-ubuntu/
* https://linuxize.com/post/how-to-add-and-delete-users-on-ubuntu-18-04/
* https://www.digitalocean.com/community/tutorials/how-to-create-a-sudo-user-on-ubuntu-quickstart
* https://superuser.com/questions/77617/how-can-i-create-a-non-login-user
* https://www.cyberciti.biz/faq/linux-unix-running-sudo-command-without-a-password/
* https://superuser.com/questions/77617/how-can-i-create-a-non-login-user

### SSH

* https://linuxize.com/post/how-to-set-up-ssh-keys-on-ubuntu-1804/
* https://mediatemple.net/community/products/dv/204643810/how-do-i-disable-ssh-login-for-the-root-user
* https://askubuntu.com/questions/1962/how-can-multiple-private-keys-be-used-with-ssh
* https://superuser.com/questions/215504/permissions-on-private-key-in-ssh-folder
* https://www.cyberciti.biz/tips/setup-ssh-to-run-on-a-non-standard-port.html
* https://au.godaddy.com/help/changing-the-ssh-port-for-your-linux-server-7306
* https://www.cyberciti.biz/faq/create-ssh-config-file-on-linux-unix/
* https://serverfault.com/questions/189282/why-change-default-ssh-port
* https://unix.stackexchange.com/questions/2942/why-change-default-ssh-port

### UFW

* https://linuxhint.com/ufw_list_rules/
* https://www.digitalocean.com/community/tutorials/how-to-set-up-a-firewall-with-ufw-on-ubuntu-18-04

### Apache and WSGI

* http://tangothu.github.io/blog/2016/08/16/python-How-To-Serve-Python-Flask-Application-Using-mod_wsgi-express/
* https://modwsgi.readthedocs.io/en/develop/configuration-directives/WSGIDaemonProcess.html
* https://serverfault.com/questions/294101/wsgidaemonprocess-specifying-a-user
* https://stackoverflow.com/questions/22346618/mod-wsgi-user-option-in-wsgidaemonprocess-doesnt-work
* https://www.shellhacks.com/modwsgi-hello-world-example/
* https://modwsgi.readthedocs.io/en/develop/user-guides/quick-configuration-guide.html
* https://unix.stackexchange.com/questions/38978/where-are-apache-file-access-logs-stored
* https://stackoverflow.com/questions/42260451/proper-write-permissions-for-apache-user-with-sqlite
* https://cloudkul.com/blog/apache-virtual-hosting-with-different-users/
* https://hostadvice.com/how-to/how-to-enable-apache-mod_rewrite-on-an-ubuntu-18-04-vps-or-dedicated-server/

### SSL

* https://certbot.eff.org/lets-encrypt/ubuntubionic-apache.html
* https://www.ssllabs.com/ssltest/analyze.html
* https://security.stackexchange.com/questions/166684/should-i-revoke-no-longer-used-lets-encrypt-certificates-before-destroying-them
* https://letsencrypt.org/docs/revoking/

### Postgres, SQLite, and SQLAlchemy

* https://wiki.postgresql.org/wiki/Apt
* https://suhas.org/sqlalchemy-tutorial/
* https://stackoverflow.com/questions/19260067/sqlalchemy-engine-absolute-path-url-in-windows
* https://www.digitalocean.com/community/tutorials/how-to-secure-postgresql-on-an-ubuntu-vps
* https://www.compose.com/articles/using-postgresql-through-sqlalchemy/

## Bash scripting

* https://landoflinux.com/linux_bash_scripting_structure.html
* https://stackoverflow.com/questions/19306771/get-current-users-username-in-bash
* https://stackoverflow.com/questions/5228345/how-to-reference-a-file-for-variables-using-bash
* https://unix.stackexchange.com/questions/42847/are-there-naming-conventions-for-variables-in-shell-scripts
* https://stackoverflow.com/questions/9772036/pass-all-variables-from-one-shell-script-to-another
* https://stackoverflow.com/questions/17622106/variable-interpolation-in-shell
* https://stackoverflow.com/questions/20615217/bash-bad-substitution
* https://stackoverflow.com/questions/3643848/copy-files-from-one-directory-into-an-existing-directory
* http://linuxcommand.org/lc3_wss0120.php
* https://stackoverflow.com/questions/20858381/what-does-bash-c-do
* https://stackoverflow.com/questions/3924182/how-the-does-keyword-if-test-if-a-value-is-true-of-false
* http://tldp.org/LDP/Bash-Beginners-Guide/html/sect_07_02.html
* https://stackoverflow.com/questions/10376206/what-is-the-preferred-bash-shebang/10383546#10383546
* https://stackoverflow.com/questions/2237080/how-to-compare-strings-in-bash
* https://stackoverflow.com/questions/4749330/how-to-test-if-string-exists-in-file-with-bash
* https://stackabuse.com/substrings-in-bash/
* http://www.robelle.com/smugbook/regexpr.html
* https://stackoverflow.com/questions/369758/how-to-trim-whitespace-from-a-bash-variable
* https://www.cyberciti.biz/faq/how-to-use-sed-to-find-and-replace-text-in-files-in-linux-unix-shell/
* https://stackoverflow.com/questions/16153446/bash-last-index-of
* https://stackoverflow.com/questions/5947742/how-to-change-the-output-color-of-echo-in-linux
* https://unix.stackexchange.com/questions/423329/trivial-rm-rf-command-destroys-my-operating-system-in-a-testing-machine
* https://stackoverflow.com/questions/3685970/check-if-a-bash-array-contains-a-value
* https://ryanstutorials.net/linuxtutorial/cheatsheetgrep.php
* https://stackoverflow.com/questions/10552711/how-to-make-if-not-true-condition
* https://stackoverflow.com/questions/1378274/in-a-bash-script-how-can-i-exit-the-entire-script-if-a-certain-condition-occurs

### Miscellaneous

* https://blender.stackexchange.com/questions/31964/problem-with-paths-in-my-script-relative-to-local-python-file
* https://stackoverflow.com/questions/50335676/sudo-privileges-within-python-virtualenv
* https://askubuntu.com/questions/323131/setting-timezone-from-terminal
* https://www.cyberciti.biz/faq/unix-linux-check-if-port-is-in-use-command/
* https://superuser.com/questions/260925/how-can-i-make-chown-work-recursively
