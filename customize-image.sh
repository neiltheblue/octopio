#!/bin/bash

# arguments: $RELEASE $LINUXFAMILY $BOARD $BUILD_DESKTOP
#
# This is the image customization script

# NOTE: It is copied to /tmp directory inside the image
# and executed there inside chroot environment
# so don't reference any files that are not already installed

# NOTE: If you want to transfer files between chroot and host
# userpatches/overlay directory on host is bind-mounted to /tmp/overlay in chroot

RELEASE=$1
LINUXFAMILY=$2
BOARD=$3
BUILD_DESKTOP=$4

pass=$(perl -e 'print crypt($ARGV[0], "password")' "orange")
useradd -m -p $pass -G tty,dialout pi
cd /home/pi
apt-get -y update
apt-get -y install python-pip python-dev python-setuptools python-virtualenv git libyaml-dev build-essential
su - pi -c 'git clone https://github.com/foosel/OctoPrint.git'
cd OctoPrint
su  pi -c 'python -m virtualenv venv'
su  pi -c './venv/bin/pip install pip --upgrade'
su  pi -c './venv/bin/python setup.py install'
su  pi -c 'mkdir /home/pi/.octoprint'
cp scripts/octoprint.init /etc/init.d/octoprint
echo "BASEDIR=/home/pi/.octoprint" >> /etc/init.d/octoprint
echo "DAEMON=/home/pi/OctoPrint/venv/bin/octoprint" >> /etc/init.d/octoprint
echo "CONFIGFILE=/home/pi/.octoprint/config.yaml" >> /etc/init.d/octoprint
chmod +x /etc/init.d/octoprint
cp scripts/octoprint.default /etc/default/octoprint
update-rc.d octoprint defaults
