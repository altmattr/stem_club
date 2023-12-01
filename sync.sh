#! /usr/bin/bash
SN=$(tr -d '\0' < /sys/firmware/devicetree/base/serial-number)
echo $SN
ssh-keyscan 104.248.111.111 >> ~/.ssh/known_hosts
sed -e '/ssh-keyscan/ s/^#*/#/' -i /home/pi/stem_club/sync.sh
sshpass -p "mqpi" rsync -avz --mkpath logs/ datakeeper@104.248.111.111:logs/$SN/
