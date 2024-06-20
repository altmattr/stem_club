#! /usr/bin/python3

import random
import time
from sense_hat import SenseHat

hat = SenseHat()
hat.set_rotation(90)
hat.clear()

white = [255,255,255]
black = [0,0,0]
red = [255,0,0]
green = [0,255,0]
orange = [255,165,0]
brown = [101,73,46]
purple = [41,37,62]
yellow = [255,255,0]

print("for use with sense hat")

level  = [
    list("########"),
    list("#  +S ##"),
    list("# #+# ##"),
    list("#   b ##"),
    list("#+bb ###"),
    list("#  #####"),
    list("########"),
    list("########")]
(px, py) = (4,1)
player_left = " "
box_left = " "

game_over = False
last_input = 0
last_frame = 0

while not game_over:
    # grab oldest move and discard rest
    events = hat.stick.get_events()
    if ((len(events) > 0)                and 
        (events[0].action == "pressed")  and
        ((events[0].timestamp - last_input) > 0.25)
       ):
      last_input = events[0].timestamp
      print(events[0])
      direction = events[0].direction
      if (direction == "right"): # up
        (ontox, ontoy) = (px, py-1)
        (intox, intoy) = (ontox, ontoy-1)
      if (direction == "left"): # down
        (ontox, ontoy) = (px, py+1)
        (intox, intoy) = (ontox, ontoy+1)
      if (direction == "up"): # left
        (ontox, ontoy) = (px-1, py)
        (intox, intoy) = (ontox-1, ontoy)
      if (direction == "down"): # right
        (ontox, ontoy) = (px+1, py)
        (intox, intoy) = (ontox+1, ontoy)

      print(px, py)
      print(ontox, ontoy)
      print(intox, intoy)
      print(level[ontoy][ontox])
      
      if (ontox >= 0 and ontox < 8 and ontoy >= 0 and ontoy < 8 and (level[ontoy][ontox] == " " or level[ontoy][ontox] == "+")):
        # move to that space
        level[py][px] = player_left
        px = ontox
        py = ontoy
        player_left = level[py][px]
        level[py][px] = "S"

      if (ontox >= 0 and ontox < 8 and ontoy >= 0 and ontoy < 8 and level[ontoy][ontox] == "b"):
        # look at into space to see if the box (and me) can move
        if (intox >= 0 and intox < 8 and intoy >= 0 and intoy < 8 and (level[intoy][intox] == " " or level[intoy][intox] == "+")):
          # move onto that box and move the box into the space
          level[py][px] = player_left
          px = ontox
          py = ontoy
          player_left = box_left
          level[py][px] = "S"
          box_left = level[intoy][intox]
          level[intoy][intox] = "b"


    if (time.time() - last_frame > 1):
        hat.clear()
        # draw the frame ,but not too much
        y = 0
        for row in level:
            x = 0
            for col in row:
                if (col == "#"):
                    hat.set_pixel(x,y, white)
                if (col == "S"):
                    hat.set_pixel(x,y, purple)
                if (col == "+"):
                    hat.set_pixel(x,y, brown)
                if (col == "b"):
                    hat.set_pixel(x,y, red)
                x = x + 1
            y = y + 1
        last_frame = time.time()
