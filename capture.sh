#!/bin/sh
echo "saving images to ~/stem_club/captures/"
echo "Any existing images not saved from the folder will be overwritten"
export LIBCAMERA_LOG_LEVELS=*:4
rpicam-still -n -t 0 --shutter 2500 --timelapse 1000 -o /home/pi/stem_club/captures/img%04d.jpg
