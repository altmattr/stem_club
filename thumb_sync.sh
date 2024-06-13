#!/bin/bash

mkdir /media/thumb
sudo chown -R pi /media/thumb
drive=`lsblk | grep -m 1 -o "sd[a|b|c]"`
echo $drive
sudo mount -o rw,uid=pi /dev/$drive /media/thumb
mkdir /media/thumb/happy_snaps
mkdir /media/thumb/captures
mv /home/pi/stem_club/happy_snaps/* /media/thumb/happy_snaps/.
mv /home/pi/stem_club/captures/* /media/thumb/captures/.
sudo umount /media/thumb
