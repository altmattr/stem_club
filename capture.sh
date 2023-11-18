#!/bin/sh
echo "saving images to ~/stem_club/captures/"
echo "Any existing images not saved from the folder will be overwritten"
export LIBCAMERA_LOG_LEVELS=*:4
libcamera-still -n -t 0 --timelapse 1000 -o /home/pi/stem_club/captures/img%04d.jpg
echo "Rotating captures... Please wait"
for f in /home/pi/stem_club/captures/*.jpg; do convert "$f" -rotate 270 "/home/pi/stem_club/captures/${f%.jpg}.jpg"; done