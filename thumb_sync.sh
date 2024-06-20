#!/bin/bash

sudo chown -R pi /mnt/transfer
drive=sda1
echo $drive
sudo mount -o rw,uid=pi /dev/$drive /mnt/transfer
mkdir /mnt/transfer/happy_snaps
mkdir /mnt/transfer/captures
mv /home/pi/stem_club/happy_snaps/* /mnt/transfer/happy_snaps/.
mv /home/pi/stem_club/captures/* /mnt/transfer/captures/.
sudo umount /mnt/transfer
echo "Transfer complete, drive unmounted"