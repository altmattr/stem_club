# stem_club

This repository is set up assuming that you're using a raspberry pi with a sense hat attached. 

To get it up and running, ```git clone``` this repository, then ```sudo chmod +x stem_club/setup.sh```, ```cd stem_club/``` and ```sudo ./setup.sh```.

After rebooting the pi, you should see the menu show up on the sense hat once the system has rebooted. 


## Using

The pi boots up into "field mode".  In field mode the device is broadcasting a WiFi access point "stem_club".  Connect to this access point and you can talk to the pi.

NB: You can't talk to the web when on this access point!

Once connected, you can talk to the pi with

`ssh pi@mqpi.lan`

and providing the password

`mqpi`

Once in, you can see a set of shell scripts you can run to do interesting things

## Connect to file

Use the same login details in Cyberduck to see the files.

# Commands

### `./capture.sh`

Capture an image through the camera once every second.  They will all get stored in the `captures` directory.

### `./clear.sh`

deletes all data from captures, logs, and happy_snaps. I.e. clears as much space as possible.

### `./disk_used.sh`

tells you what percentage of the disk you have filled up

TODO: only works with sense hat

### `./field_mode.sh`

Will put the pi into "field mode".  In field mode the pi will advertise its own wireless network.  You can connect to the pi on that network (password "piisgood") and ssh in with `ssh pi@mqpi.local`.  This allows in-the-field control from a laptop.

### `./base_mode.sh`

Will attempt to connect to a WiFi network.  Will look in `networks.conf` for networks that might work.  If nothing works, the device goes back into field mode, this may take a while

### `./focus.sh`

Will help the user focus a lense that requires manual focus using just the sense hat.  We recommend using streaming (see `stream.sh`) if a laptop is available.

### `./happy_snaps.sh`

Puts the pi into camera mode - only works when a SenseHat is attached.  The SensHat will show a very rough indication of what will be captured.  Pressing "up" will capture an image.  Pressing "in" will end camera mode.

### `./hat_text.sh`

A helper for printing text to the sense hat.  Not needed to be used by users.

### `./log.sh`

Start logging sensor data and any _notable things_ seen in the camera.  A notable thing is determined by the _model_ that is setup in the stem_club prediction model area.

### `./report_ssid.sh`

Primarily for sense hat users, whill tell the user (via the sense hat) what network the pi is currently connected to and the IP address it has on that network.

# Configurations

### `networks.conf`

A file to hold SSID's and passwords for base mode.  Each line in checked in turn when attempting to go into base mode, the first that works is used.
