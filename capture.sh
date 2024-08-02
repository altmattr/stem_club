#!/bin/bash
echo "saving images to ~/stem_club/captures/"

export LIBCAMERA_LOG_LEVELS=*:4
echo "Any existing images in the captures folder will be overwritten, do you wish to continue? (Type the number associated with your choice)"
select yn in "Yes" "No"; do
	case $yn in
		Yes ) rpicam-still -n -t 0 -v 1 --exposure sport --timelapse 1000 -o /home/pi/stem_club/captures/img%04d.jpg; break;;
		No ) exit;;
	esac
done
