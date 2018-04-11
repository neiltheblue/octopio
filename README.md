# Octopio

Octoprint for the Orange Pi Zero - octoprint on a dirt cheap board, using on [Armbian](https://www.armbian.com/)!

#### TODO
+ Automate webcam support
+ Support Orange Pi Zero 2+


# Burn image

This build process is pretty simple but slow, you can find a prebuild image [here](https://www.dropbox.com/s/66o0hm0vbigvwdd/Octopio_5.41_Orangepizero_Debian_jessie_default_3.4.113.img?dl=0):

To burn the image with linux use:

```
sudo dd if=<image> of=<dev> conv=sync status=progress
```
  
where **\<image>** is the image name and **\<dev>** is the sd card device name e.g. /dev/sdd (Note: no partition number /dev/sdd1).

# Configure Octopio

How to get it working...

## Boot image

Once you have the sd card ready, just pop it in the board and power up. If booting for the first time it may be better to connected to this to the USB port on a PC.

### Serial connection

I find this the best way to connect to the new device.

Power the device with a USB lead connected to the PC, with a quality cable using a powered USB port. Once booted there should be a new serial device available.

#### Linux

On linux I see this as */dev/ttyACM0*. To connect to login to the device you can use minicom:

```
sudo apt install minicom

minicom -b 115200 -D /dev/ttyACM0
```

or gtkterm

```
sudo apt install gtkterm
gtkterm --port /dev/ttyACM0 --speed 115200
```

#### Windows

[I don't use windows so this is from memory]

On windows you can install [Putty](https://www.chiark.greenend.org.uk/~sgtatham/putty/latest.html).
Then in the connection windows select serial connection and choose the new COM port. To find the COM port number you can look in the hardware manager or just try them in order i.e. COM0, COM1, COM2..etc

### Remote connection

If you want to connect via the network with a DHCP server available, just pop in the RJ45 network connection. The find the IP address with one of these options.

#### Arp

For linux run this command to find the name and ip address of the device:

```
arp && arp -n
```

#### Angry IP scanner

Install Angry IP scanner from [here](http://angryip.org/). 

Run Angry IP Scanner and enter the range for you network e.g. 192.168.1.0-192.168.1.255 and run a scan. 

When it is ready you should see an entry for *orangepizero*. Note the ip address and connect with:

```
ssh root@<ip address>
```

### Login

Once you have a serial or remote connection, you can login as **pi**, default password is **orange**.

The root for octoprint is user/pass **root**/**1234**. On first login you will be promted to change the password and create a new user. 

## Update network

The OrangePIZero is great as it has buit in wi-fi, to connect to you network using the UI enter:

```
sudo nmtui-connect
```

or for the command line, better with a serial connection use:

```
sudo nmcli device wifi connect <sid-name> password <wireless-password>
```

For any other easy network setup, such as setting a static ip address use:

```
sudo nmtui
```

## Connect

To acces Octoprint using a web browser connect to:

```
http://<ip_address>:5000
```

# Image build process

If you would like to build or customise the image. First check out the armbian repostory:

```
git clone https://github.com/armbian/build
```

Then copy *customize-image.sh* to *armbian/build/userpatches/customize-image.sh*.

If using vagrant then run this to start and enter the vagrant environment:

```
cd armbian/build
vagrant up
vagrant ssh
```

Then to build the image run:

```
cd armbian
./compile.sh BRANCH=default BOARD=orangepizero KERNEL_ONLY=no RELEASE=jessie KERNEL_CONFIGURE=no BUILD_DESKTOP=no PROGRESS_DISPLAY=plain
```

# Automated build

This script will automate the process if you have [VirtualBox](https://www.virtualbox.org/) and [Vagrant](https://www.vagrantup.com/). It will also require this plugin:

```
vagrant plugin install vagrant-disksize
```

build:

```
sudo apt install virtualbox vagrant
./build_octopio.sh
```
