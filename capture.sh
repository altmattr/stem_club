#!/bin/sh
echo "saving images to ~/captures/"
raspistill -tl 1000 -t 0 -rot 90 -o /home/pi/stem_club/captures/img%04d.jpg