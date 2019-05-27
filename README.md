# fsnd-project-3
The final project for Udacity's Full Stack Developer Nanodegree.

## Changes

* Disabled SSH root login.
  * `sudo vim /etc/ssh/sshd_config`
  * Edit `PermitRootLogin no`
* Created grader. 
  * `adduser grader`
  * `usermod -aG sudo grader`
  * `su - grader`
  * Generated keypair for grader: `ssh-keygen -t rsa -b 4096 -C "grader@grader.com"`.
  * Copy `id_rsa` locally and then `rm -rf ~/.ssh/id_rsa`
  * `sudo mv ~/.ssh/id_rsa.pub ~/.ssh/authorized_keys`
  * `sudo chmod 700 ~/.ssh`
  * `sudo chmod 644 ~/.ssh/authorized_keys`
* Enabled UFW:
  * Enabled SSH: `sudo ufw allow ssh`.
  * Enabled HTTP: `sudo ufw allow http`.
  * Enabled HTTPS: `sudo ufw allow https`.
  * Enabled NTP: `sudo ufw allow ntp`.
  * Disabled incoming traffic by default: `sudo ufw default deny incoming`.
  * Enabled outgoing traffic by default: `sudo ufw default allow outgoing`.
  
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
