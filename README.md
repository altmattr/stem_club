# stem_club

This repository is set up assuming that you're using a raspberry pi with a sense hat attached. 

To get it up and running, ```git clone``` this repository, then ```sudo chmod +x stem_club/setup.sh```, ```cd stem_club/``` and ```sudo ./setup.sh```.

After rebooting the pi, you should see the menu show up on the sense hat once the system has rebooted. 

TODO: adjust instructions so it clones into home dir, not a sub-dir

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

### `./capture.sh`

Capture an image through the camera once every second.  They will all get stored in the `captures` directory.

### `./happy_snaps.sh`

Puts the pi into camera mode - only works when a SenseHat is attached.  The SensHat will show a very rough indication of what will be captured.  Pressing "up" will capture an image.  Pressing "in" will end camera mode.

### `./log.sh`

Start logging sensor data and any _notable things_ seen in the camera.  A notable thing is determined by the _model_ that is setup in the stem_club prediction model area.
