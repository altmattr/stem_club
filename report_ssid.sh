#!/bin/bash

connection=`nmcli -t -f NAME con | head -n 1`
SSID=`grep -oP "ssid=\K.*"`
./hat_text.sh "$connection"
#./hat_text.sh "$SSID"

if [ "$connection" = "WiFiAP" ]; then
  ./hat_text.sh "$SSID"
fi
./hat_text.sh "$(hostname -I | awk '{print $1}')"
