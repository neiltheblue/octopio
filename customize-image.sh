#!/bin/bash

# arguments: $RELEASE $LINUXFAMILY $BOARD $BUILD_DESKTOP
#
# This is the image customization script

# NOTE: It is copied to /tmp directory inside the image
# and executed there inside chroot environment
# so don't reference any files that are not already installed

# NOTE: If you want to transfer files between chroot and host
# userpatches/overlay directory on host is bind-mounted to /tmp/overlay in chroot

echo "### Starting octopio ###"

RELEASE=$1
LINUXFAMILY=$2
BOARD=$3
BUILD_DESKTOP=$4

# set user
useradd -m -G tty,dialout,sudo,video --shell /bin/bash pi
echo -e 'orange\norange\n' | passwd pi
echo "pi ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/010_pi-nopasswd
echo "pi ALL=NOPASSWD: /sbin/service" > /etc/sudoers.d/octoprint-service
echo "pi ALL=NOPASSWD: /sbin/shutdown" > /etc/sudoers.d/octoprint-shutdown
chmod 440 /etc/sudoers.d/*

# set host
echo 'octopio' > /etc/hostname
chmod a+r /etc/hostname

# install octoprint
cd /home/pi
apt-get -y update
apt-get -y install python-pip python-dev python-setuptools python-virtualenv git libyaml-dev build-essential
su - pi -c 'git clone https://github.com/foosel/OctoPrint.git'
cd OctoPrint
su  pi -c 'python -m virtualenv venv'
su  pi -c './venv/bin/pip install pip --upgrade'
su  pi -c './venv/bin/python setup.py install'
su  pi -c 'mkdir /home/pi/.octoprint'

# configure install
cat << EOF >> /home/pi/.octoprint/config.yaml
server:
  commands:
    serverRestartCommand: sudo service octoprint restart
    systemRestartCommand: sudo shutdown -r now
    systemShutdownCommand: sudo shutdown -h now
webcam:
  stream: http://<server.IP>:8080/?action=stream
  snapshot: http://127.0.0.1:8080/?action=snapshot
  ffmpeg: /usr/bin/avconv

EOF
chown  pi:pi /home/pi/.octoprint/config.yaml

# install startup scripts
cp scripts/octoprint.init /etc/init.d/octoprint
chmod +x /etc/init.d/octoprint
sudo cp scripts/octoprint.default /etc/default/octoprint
echo "BASEDIR=/home/pi/.octoprint" >> /etc/default/octoprint
echo "DAEMON=/home/pi/OctoPrint/venv/bin/octoprint" >> /etc/default/octoprint
echo "CONFIGFILE=/home/pi/.octoprint/config.yaml" >> /etc/default/octoprint
update-rc.d octoprint defaults

# build webcam support
cd /home/pi
apt-get -y install subversion libjpeg62-turbo-dev imagemagick libav-tools libv4l-dev cmake
su - pi -c 'git clone https://github.com/jacksonliam/mjpg-streamer.git'
cd mjpg-streamer/mjpg-streamer-experimental
su  pi -c 'export LD_LIBRARY_PATH=. && make'
mkdir /home/pi/scripts
cp /tmp/overlay/webcamDaemon /home/pi/scripts/webcamDaemon
chown pi:pi /home/pi/scripts/webcamDaemon
chmod +x /home/pi/scripts/webcamDaemon
cp /tmp/overlay/webcam /etc/init.d/webcam
chmod +x /etc/init.d/webcam
update-rc.d webcam defaults
cp /tmp/overlay/webcam.txt /home/pi/webcam.txt
chown pi:pi /home/pi/webcam.txt

# clean
apt-get clean
