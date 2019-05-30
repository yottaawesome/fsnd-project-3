# FSND Project 3: Deploying to Linux

This is the final project for Udacity's Full Stack Developer Nanodegree. This project sees the deployment of [Project 2: Digital Bookshelf](https://github.com/yottaawesome/fsnd-project-2) to a live, configured, and secured server.

## Application URL

[Digital Bookshelf is live](https://vasiliosmagriplis.com/#/). I used one of my parked domains in order to enable SSL as I was uncomfortable having information passed around in plaintext over the Web. Once grading is complete, I will revoke the certificates, take down the server, and host this application in a subdomain for an existing server I have running.

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

## Summary of changes to Digital Bookshelf

A number of changes to the Digital Bookshelf application were necessary to prepare it for deployment. All of these improvements have been been backported to the [Project 2 repository](https://github.com/yottaawesome/fsnd-project-2).

* Added `psycopg2-binary` to `requirements.txt` to enable SQLAlchemy to use PostgreSQL.
* Created a new module `cfg` to hold configuration information located in `secret.cfg.json`, such as absolute paths to `secret.*` files, the server session key, and the database connection string.
* Refactored the existing codebase (mainly the `dal` and `app`) modules to use the new `cfg` module for configuration data and to remove relative file paths that were causing issues.
* Refactored `main.py` to export the `flask` app (required for the WSGI script), remove dynamic session key generation, and not run in debug server mode unless it is directly invoked.

## Detailed list of actions and changes

The order this list is in is not the order I took these actions in due to the fact I often discovered issues after the logical sequence of steps were undertaken, and sometimes some experimentation was required. I've nonetheless ordered this list in a logical sequence for future reference.

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
  * Double-check port 1012 is enabled in UFW: `sudo ufw status`.
  * Open port 1012 in Amazon networking tab.
  * Open `sshd_config`: `sudo vim /etc/ssh/sshd_config`.
  * Change `# Port 22` to `Port 1012`.
  * Restart SSHD: `service sshd restart`.
  * Connect as `ubuntu` to confirm change is nominal.
* Installed fail2ban: `sudo apt install fail2ban`.
* Created user grader.
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
* Configured PostgreSQL user:
  * Start PSQL: `sudo -u postgres psql`.
  * Create user: `create user bookshelfuser with encrypted password '<password>';`.
  * Connect to bookshelf DB: `\connect bookshelf`.
  * Grant privileges to user:
    * `grant all privileges on database bookshelf to bookshelfuser;`
    * `grant all privileges on all tables in schema public to bookshelfuser;`
    * `grant all privileges on all functions in schema public to bookshelfuser;`
* Installed `mod-wsgi` for Python 3: `sudo apt-get install libapache2-mod-wsgi-py3`.
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

### SSH

* https://linuxize.com/post/how-to-set-up-ssh-keys-on-ubuntu-1804/
* https://mediatemple.net/community/products/dv/204643810/how-do-i-disable-ssh-login-for-the-root-user
* https://askubuntu.com/questions/1962/how-can-multiple-private-keys-be-used-with-ssh
* https://superuser.com/questions/215504/permissions-on-private-key-in-ssh-folder
* https://www.cyberciti.biz/tips/setup-ssh-to-run-on-a-non-standard-port.html
* https://au.godaddy.com/help/changing-the-ssh-port-for-your-linux-server-7306

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

### SSL

* https://certbot.eff.org/lets-encrypt/ubuntubionic-apache.html
* https://www.ssllabs.com/ssltest/analyze.html

### Postgres, SQLite, and SQLAlchemy

* https://wiki.postgresql.org/wiki/Apt
* https://suhas.org/sqlalchemy-tutorial/
* https://stackoverflow.com/questions/19260067/sqlalchemy-engine-absolute-path-url-in-windows
* https://www.digitalocean.com/community/tutorials/how-to-secure-postgresql-on-an-ubuntu-vps

### Miscellaneous

* https://blender.stackexchange.com/questions/31964/problem-with-paths-in-my-script-relative-to-local-python-file
* https://stackoverflow.com/questions/50335676/sudo-privileges-within-python-virtualenv
* https://askubuntu.com/questions/323131/setting-timezone-from-terminal
