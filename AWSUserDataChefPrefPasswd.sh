#!/bin/bash
###
#
#  This script takes the necessary steps to enable a linux AMI (e.g. Ubuntu) for Chef to be installed later via Knife.  It has the following responsibilities:
#	1. general update of system
#	2. User 'opscode' creation
#	3. Enablement of SSH Password based Authentication (requires ssh service to be restarted).
#	4. Enable sudo privileges for 'opscode' user.
#
###

###
# Log commands executed to /var/log/
set -x
###

### 
# Bring system up to date
apt-get -y update
# apt-get -y upgrade
### 

###
# Create opscode user and set password
export TARGET_UID="opscode"
useradd -m -s /bin/bash -p '$6$Ka3r1lxR$75GM7Cc2g86KafLQC3T4Tbb.YxAHXcgbpL9BDs.nETQSiabnrsGeKfk6DCuzQAGcm0YpTJkQs44moHJM..AqB/' "${TARGET_UID}"
###

###
# Edit sshd_config to allow for password based authentication
# Backup the original file first
export SSH_HOME="/etc/ssh"
export SED="/bin/sed""
cp "${SSH_HOME}/sshd_config" "${SSH_HOME}/sshd_config.orig"
# In /etc/ssh/sshd_config, change "PasswordAuthentication no" to yes, when it exists in column 1.
"${SED}" 's/^PasswordAuthentication no/PasswordAuthentication yes/g' "${SSH_HOME}/sshd_config" >/tmp/sshd_config
# maintain file ownership and perms
cat /tmp/sshd_config >"${SSH_HOME}/sshd_config"
rm -f /tmp/sshd_config
###

###
# Edit /etc/sudoers.  Allow opscode to execute sudo based commands 
# Backup the original file first
export SUDOERS_FILE="/etc/sudoers"
cp "${SUDOERS_FILE}" "${SUDOERS_FILE}.orig"
#
(
cat <<EOF

opscode ALL=(ALL:ALL) ALL
EOF
) >> "${SUDOERS_FILE}"
###

###
# Restart ssh service to apply changes
# For some reason, service ssh restart is not effective.
service ssh stop
service ssh start
###
