#! /usr/bin/bash
SN=$(cat /sys/firmware/devicetree/base/serial-number)
echo $SN
sshpass -p "mqpi" rsync -avz --mkpath logs/ datakeeper@10.0.2.175:logs/$SN/
