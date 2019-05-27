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
  * Enable UFW: `sudo ufw enable`
 * Installed Apache2: `sudo apt install apache2`.
 * Installed PostgreSQL:
  * `sudo apt-get install curl ca-certificates`
  * `curl https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -`
  * `sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'`
  * `sudo apt-get update`
  * `sudo apt-get install postgresql-11`
  * Verify with `sudo -u postgres psql`
  
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
