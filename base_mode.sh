#! /usr/bin/python3

import re
import os
import time

print("bringing down access point")
os.system("sudo nmcli connection down 'WiFiAP'")
time.sleep(3)

file = open("/home/pi/stem_club/networks.conf", "r")
lines = file.readlines()
print(f"found {lines}  possible candidate networks")

for line in lines:
  match = re.search("^(.*):(.*)$", line)
  if match:
      print(f"trying network {match.group(1)}")
      success = os.system(f"sudo nmcli device wifi connect '{match.group(1)}' password '{match.group(2)}'")
      if success == 0:
          print(f"connected to {match.group(1)}")
          os.system("/home/pi/stem_club/report_ssid.sh")
          exit(0)
      else:
          print(f"failed connection to {match.group(1)}")
  else:
      print(f"there is an error in the network file, see line:\n    {line}")
# we made it to the bottom which means we failed, put the hotspot back up
os.system("sudo nmcli connection up 'WiFiAP'")
os.system("/home/pi/stem_club/report_ssid.sh")
exit(-1)
