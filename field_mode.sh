#!/bin/bash

connection=`nmcli -t -f NAME con | head -n 1`
echo "current connection is $connection"

echo "if successful, new ssid will be..."
nmcli  -f  802-11-wireless.ssid connection show "WiFiAP"

if [ "$connection" != "WiFiAP" ]; then
	sudo nmcli connection down "$connection"
	sudo mcli connection up "WiFiAP"
fi

./report_ssid.sh
