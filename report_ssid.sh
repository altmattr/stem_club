#!/bin/bash

connection=`nmcli -t -f NAME con | head -n 1`
SSID=`sudo grep -oP "ssid=\K.*" /etc/NetworkManager/system-connections/WiFiAP.nmconnection`
./hat_text.sh "$connection"
#./hat_text.sh "$SSID"

if [ "$connection" = "WiFiAP" ]; then
  ./hat_text.sh "$SSID"
fi
./hat_text.sh "$(hostname -I | awk '{print $1}')"
