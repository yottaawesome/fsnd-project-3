# FSND Project 3: Deploying to Linux

The final project for Udacity's Full Stack Developer Nanodegree.

## SSH

`ssh grader@13.236.68.94`

## Changes

* Disabled SSH root login.
  * Edit global SSHD config file: `sudo vim /etc/ssh/sshd_config`
  * Edit `PermitRootLogin` setting to be `PermitRootLogin no`
* Installed fail2ban: `sudo apt install fail2ban`.
* Created user grader. 
  * Create user: `adduser grader`
  * Add grader to `sudo` group: `usermod -aG sudo grader`
  * Login as grader: `su - grader`
  * Generate keypair for grader: `ssh-keygen -t rsa -b 4096 -C "grader@grader.com"`.
  * Copy `id_rsa` locally and then `rm -rf ~/.ssh/id_rsa`
  * Rename `id_rsa.pub` to `authorized_keys`: `sudo mv ~/.ssh/id_rsa.pub ~/.ssh/authorized_keys`
  * Confirm `.ssh` has right permissions: `sudo chmod 700 ~/.ssh`
  * Confirm `authorized_keys` has right permissions: `sudo chmod 644 ~/.ssh/authorized_keys`
* Enabled UFW:
  * Enabled SSH: `sudo ufw allow ssh`.
  * Enabled HTTP: `sudo ufw allow http`.
  * Enabled HTTPS: `sudo ufw allow https`.
  * Enabled NTP: `sudo ufw allow ntp`.
  * Disabled incoming traffic by default: `sudo ufw default deny incoming`.
  * Enabled outgoing traffic by default: `sudo ufw default allow outgoing`.
  * Enable UFW: `sudo ufw enable`.
* Installed Apache2: `sudo apt install apache2`.
* Installed PostgreSQL:
  * Install certificates: `sudo apt-get install curl ca-certificates`.
  * Add key: `curl https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -`.
  * Create `/etc/apt/sources.list.d/pgdg.list`: `sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'`.
  * Update packages: `sudo apt-get update`.
  * Install PostgreSQL: `sudo apt-get install postgresql-11`.
  * Verify with `sudo -u postgres psql`.
* Configured PostgreSQL user:
  * Start PSQL: `sudo -u postgres psql`
  * Create user: `create user bookshelfuser with encrypted password '<password>';`
  * Connect to bookshelf DB: `\connect bookshelf`
  * Add privileges:
    * `grant all privileges on database bookshelf to bookshelfuser;`
    * `grant all privileges on all tables in schema public to bookshelfuser;`
    * `grant all privileges on all functions in schema public to bookshelfuser;`
* Install `mod-wsgi` for Python 3: `sudo apt-get install libapache2-mod-wsgi-py3`.
* Prepare web application:
  * Create web app directory: `var/www/bookshelf`.
  * Add [`bookshelf.conf`](https://github.com/yottaawesome/fsnd-project-3/blob/master/src/apache-wsgi/bookshelf.conf) to `/etc/apache2/sites-available`.
  * Add [`bookshelf.wsgi`](https://github.com/yottaawesome/fsnd-project-3/blob/master/src/apache-wsgi/bookshelf.wsgi) to `/usr/local/www/wsgi-scripts`.
  * Disable `default` site: `sudo a2dissite 000-default.conf`.
  * Enable `bookshelf` app: `sudo a2ensite bookshelf.conf`.
  * Restart Apache2: `sudo systemctl restart apache2`.
  
## Potential improvements

* Use [`mod_wsgi-express`](https://pypi.org/project/mod_wsgi/) instead of having to configure `mod_wsgi` and Apache2 the traditional way.
* Run `mod_wsgi` as a daemon using a different account, so that if that account gets mapped to a PostgreSQL user, that account can only read one database, which minimises damage if the process ever gets compromised.
* Containerize the app with Docker, and use Apache2 or nginx on the server as a reverse proxy to the hosted container. I regard this to be the ideal setup.

## Resources used

* https://linuxize.com/post/how-to-create-a-sudo-user-on-ubuntu/
* https://linuxize.com/post/how-to-add-and-delete-users-on-ubuntu-18-04/
* https://www.digitalocean.com/community/tutorials/how-to-create-a-sudo-user-on-ubuntu-quickstart
* https://linuxize.com/post/how-to-set-up-ssh-keys-on-ubuntu-1804/
* https://mediatemple.net/community/products/dv/204643810/how-do-i-disable-ssh-login-for-the-root-user
* https://askubuntu.com/questions/1962/how-can-multiple-private-keys-be-used-with-ssh
* https://linuxhint.com/ufw_list_rules/
* https://www.cyberciti.biz/tips/setup-ssh-to-run-on-a-non-standard-port.html
* https://www.digitalocean.com/community/tutorials/how-to-set-up-a-firewall-with-ufw-on-ubuntu-18-04
* https://superuser.com/questions/215504/permissions-on-private-key-in-ssh-folder
* https://wiki.postgresql.org/wiki/Apt
