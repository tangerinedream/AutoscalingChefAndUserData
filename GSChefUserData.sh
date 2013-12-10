#!/bin/bash
###
# Log commands executed to /var/log/
set -x

### 
# Bring system up to date
apt-get -y update
# apt-get -y upgrade

####
# Create opscode user and set password
useradd -m -s /bin/bash -p '$6$Ka3r1lxR$75GM7Cc2g86KafLQC3T4Tbb.YxAHXcgbpL9BDs.nETQSiabnrsGeKfk6DCuzQAGcm0YpTJkQs44moHJM..AqB/' opscode

###
# Edit sshd_config to allow for password based authentication
# Backup the original file first
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.orig
# In /etc/ssh/sshd_config, change "PasswordAuthentication no" to yes, when it exists in column 1.
/bin/sed 's/^PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config >/tmp/sshd_config
# maintain file ownership and perms
cat /tmp/sshd_config >/etc/ssh/sshd_config
rm -f /tmp/sshd_config

###
# Edit /etc/sudoers.  Allow opscode to execute sudo based commands 
# Backup the original file first
cp /etc/sudoers /etc/sudoers.orig
#
(
cat <<EOF

opscode ALL=(ALL:ALL) ALL
EOF
) >> /etc/sudoers

###
# Restart ssh service to apply changes
service ssh stop
service ssh start
