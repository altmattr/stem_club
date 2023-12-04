#! /usr/bin/python3

import os
from picamera2 import *
import cv2
from sense_hat import SenseHat
import math

os.environ["LIBCAMERA_LOG_LEVELS"] = "4"

cam = Picamera2()
cam.preview_configuration.enable_lores()
config = cam.create_preview_configuration(lores={"size": (640, 480), "format": "BGR888"})
cam.configure(config)

try:
    hat = SenseHat()
except:
    pass

print("a script to help focussing with only the sense hat interface")

cam.start(show_preview=False)
while True:
    bgr = cam.capture_array("lores")
    gray = cv2.cvtColor(bgr, cv2.COLOR_BGR2GRAY)
    h = len(gray)
    w = len(gray[0])
    hs = h//8
    ws = w//8
    for x in range(8):
        for y in range(8):
            sub = gray[y*hs:(y+1)*hs, x*ws:(x+1)*ws]
            v = cv2.Laplacian(sub, cv2.CV_64F).var()
            i = max(min(math.floor(v/4), 255), 0)
            try:
                hat.set_pixel(x,y,[i, i, i])
            except:
                pass
