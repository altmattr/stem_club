#!/bin/bash

set -e
set -x

case $(uname -m) in
  aarch64) echo "Cannot install on 64 bit OS due to missing legacy camera support"; exit;;
esac

#sudo apt-get update
#sudo apt-get install -y vim
#sudo apt-get install -y vlc
#sudo apt-get install -y git
#sudo apt-get install -y python3-pip
#sudo apt-get install -y sense-hat
#sudo apt-get install -y libopenjp2-7-dev
#sudo apt-get install -y libatlas-base-dev
#sudo apt-get install -y python3-opencv
#sudo apt-get install -y network-manager dnsmasq
#sudo apt-get install -y sshpass

#sudo systemctl disable dnsmasq
#sudo systemctl enable NetworkManager
#sudo systemctl start NetworkManager

python -m pip install tflite-runtime
python -m pip install Pillow
python -m pip install picamera
python -m pip install numpy

# adjustments to kernel/os options
echo "\n"                     | sudo tee -a /boot/config.txt
echo "enable_uart=1\n"        | sudo tee -a /boot/config.txt
echo "dtoverlay=disable-bt\n" | sudo tee -a /boot/config.txt # needed to get uart on gpio on some pis I think
echo "start_x=1\n"            | sudo tee -a /boot/config.txt # needed to enable the camera

# enable ssh on next boot
sudo touch /boot/ssh

# ensure scripts are executable
chmod a+x *.sh

# TODO: consider `systemctl link` here
# services
sudo cp services/interface.service /lib/systemd/system/
sudo systemctl enable interface.service

sudo cp services/sensors.service /lib/systemd/system/
sudo systemctl enable sensors.service

# setup wifi access point

echo "\n" | sudo tee -a /etc/dhcpcd.conf
echo "denyinterfaces wlan0\n" | sudo tee -a /etc/dhcpcd.conf

APNAME="WiFiAP"
SSID="stem_club"
KEY="piisgood"

IFNAME=wlan0
sudo nmcli connection add type wifi ifname $IFNAME con-name $APNAME ssid $SSID
sudo nmcli connection modify $APNAME 802-11-wireless.mode ap
sudo nmcli connection modify $APNAME 802-11-wireless.band bg
sudo nmcli connection modify $APNAME ipv4.method shared
sudo nmcli connection modify $APNAME ipv4.addresses 10.0.2.100/24
# Set security
sudo nmcli connection modify $APNAME 802-11-wireless-security.key-mgmt wpa-psk
sudo nmcli connection modify $APNAME 802-11-wireless-security.psk "$KEY"
sudo nmcli connection modify $APNAME 802-11-wireless-security.group ccmp
sudo nmcli connection modify $APNAME 802-11-wireless-security.pairwise ccmp
# Disable WPS
sudo nmcli connection modify $APNAME 802-11-wireless-security.wps-method 1

sudo nmcli connection up $APNAME

# reboot
sudo reboot now
