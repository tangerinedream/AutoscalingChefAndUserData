#!/bin/bash
###
#
#  This script takes the necessary steps to enable a linux AMI (e.g. Ubuntu) for Chef to be installed later via Knife.  It has the following responsibilities:
#	1. general update of system
#	2. User 'opscode' creation
#	3. Instead of SSH Password based Authentication, use the AWS PEM "key file" file for authentication
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
# In this version, you need not modify the sshd_config file.  However, you do need to know the location of where the AWS Key File is located, so you can copy it to opscode user
export SOURCE_UID="ubuntu""
export SOURCE_SSH_DIR="~${SOURCE_UID}/.ssh"
export TARGET_SSH_DIR="~${TARGET_UID}/.ssh"
mkdir -p "${TARGET_SSH_DIR}"
export AWS_SOURCE_KEY_FILE="${SOURCE_SSH_DIR}/authorized_keys"
export AWS_TARGET_KEY_FILE="${TARGET_SSH_DIR}/authorized_keys"
cp "${AWS_SOURCE_KEY_FILE}" "${AWS_TARGET_KEY_FILE}" 
chown -R "${TARGET_UID}" "${TARGET_SSH_DIR}"
chgrp -R "${TARGET_UID}" "${TARGET_SSH_DIR}"
###

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
