#!/bin/bash
export LOG_FILE="/tmp/cloud-init_log.txt"
echo [`date +%F`][`date +%T`] Cloud-init script initiated >>"${LOG_FILE}"
###
#
#  This script takes the necessary steps to enable a linux AMI (e.g. Ubuntu) for Chef to be installed later via Knife.  It has the following responsibilities:
# 1. general update of system
# 2. User 'opscode' creation
# 3. Instead of SSH Password based Authentication, use the AWS PEM "key file" file for authentication
# 4. Enable sudo privileges for 'opscode' user.
#
#  The associated knife command usage would be similar to:
#      knife bootstrap $NODE_IP --sudo -x <ssh-user-id> -i <path to (AWS).pem file> -N "<your node name>""
#      when prompted, enter sudo passcode for <ssh-user-id>
###

###
# Log commands executed to /var/log/
set -x
###

### 
# Bring system up to date
apt-get -y update
# apt-get -y upgrade
echo [`date +%F`][`date +%T`] apt-get complete >>"${LOG_FILE}"
### 

###
# Create opscode user and set password
export TARGET_UID="opscode"
useradd -m -s /bin/bash -p '$6$Ka3r1lxR$75GM7Cc2g86KafLQC3T4Tbb.YxAHXcgbpL9BDs.nETQSiabnrsGeKfk6DCuzQAGcm0YpTJkQs44moHJM..AqB/' "${TARGET_UID}"
echo [`date +%F`][`date +%T`] opscode user created >>"${LOG_FILE}"
###

###
# In this version, you need not modify the sshd_config file.  However, you do need to know the location of where the AWS Key File is located, so you can copy it to opscode user
if [ -d "/home/bitnami" ]
then
  export SOURCE_UID="bitnami"
else
  if [ -d "/home/ec2user" ] 
  then
    export SOURCE_UID="ec2user"
  else
    export SOURCE_UID="ubuntu"
  fi
fi
export SOURCE_SSH_DIR="/home/${SOURCE_UID}/.ssh"
export TARGET_SSH_DIR="/home/${TARGET_UID}/.ssh"
mkdir -p "${TARGET_SSH_DIR}"
export AWS_SOURCE_KEY_FILE="${SOURCE_SSH_DIR}/authorized_keys"
export AWS_TARGET_KEY_FILE="${TARGET_SSH_DIR}/authorized_keys"
# TO DO: Consider changing cp to ln -s
cp "${AWS_SOURCE_KEY_FILE}" "${AWS_TARGET_KEY_FILE}" 
chown -R "${TARGET_UID}" "${TARGET_SSH_DIR}"
chgrp -R "${TARGET_UID}" "${TARGET_SSH_DIR}"
echo [`date +%F`][`date +%T`] opscode pem keyfile in place >>"${LOG_FILE}"
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
echo [`date +%F`][`date +%T`] opscode authorized in sudoers file >>"${LOG_FILE}"
###
echo [`date +%F`][`date +%T`] Cloud-init script completed >>"${LOG_FILE}"
###n"
