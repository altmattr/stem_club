#! /opt/homebrew/bin/python3.12
##! /usr/bin/python3

import random
import time
# from sense_hat import SenseHat

import sys

print(sys.version_info)

# hat = SenseHat()
# hat.set_rotation(90)
# hat.clear()

white = [60,60,60]
black = [0,0,0]
red = [255,0,0]
green = [0,255,0]
orange = [255,165,0]
brown = [101,73,46]
purple = [41,37,62]
yellow = [255,255,0]

print("for use with sense hat")

levels = list(map(lambda g: list(map(lambda l: list(l), g.split("\n"))),
                 open("sokoban.txt", "r").read().split("\n\n")
                 )
             )
print(levels[0])
curr_level = 0

def find_p(level):
  py = 0
  for row in level:
    px = 0
    for col in row:
      if (col == "p"):
        return (px, py)
      px = px + 1
    py = py + 1

def init():
  global level, px, py, under_player, under_box, game_over, last_input, last_frame
  level = levels[curr_level]
  (px, py) = find_p(level)
  under_player = " "
  under_box = " "
  game_over = False
  last_input = 0
  last_frame = 0

def inframe(x,y):
  return (x >=0 and x < 8 and y >=0 and y < 8)
  
init()
while not game_over:
    # grab oldest move and discard rest
    # events = hat.stick.get_events()
    # if ((len(events) > 0)                and 
    #     (events[0].action == "pressed")  and
    #     ((events[0].timestamp - last_input) > 0.25)
    #    ):
    #   last_input = events[0].timestamp
    #   direction = events[0].direction
      for row in level:
        print("".join(row))

      direction = input()

      (dx, dy) = (0, 0)
      match direction:
        case "right" | "u": (dx, dy) = (0, -1)
        case "left"  | "d": (dx, dy) = (0,  1)
        case "up"    | "l": (dx, dy) = (-1, 0)
        case "down"  | "r": (dx, dy) = (1,  0)
              
      if (inframe(px + dx, py + dy) and (level[py + dy][px + dx] == " " or level[py + dy][px + dx] == "+")):
        print("moving onto blank space")
        # move to that space
        level[py][px] = under_player
        px = px + dx
        py = py + dy
        under_player = level[py][px]
        under_box = " "
        level[py][px] = "p"
      elif (inframe(px + dx, py + dy) and level[py + dy][px + dx] == "b"):
        print("moving onto box")
        # look at into space to see if the box (and me) can move
        if (inframe(px + 2*dx, py + 2*dy) and (level[py + 2*dy][px + 2*dx] == " " or level[py + 2*dy][px + 2*dx] == "+")):
          # move onto that box and move the box into the space
          level[py][px] = under_player
          px = px + dx # update player position
          py = py + dy
          under_player = under_box
          level[py][px] = "p"
          under_box = level[py+dy][px+dx]
          level[py+dy][px+dx] = "b"

      targets = sum([x.count("+") for x in level + [under_player]])
      if (targets == 0):
        time.sleep(2)
        # hat.clear(green)
        print("game won")
        time.sleep(2)
        curr_level = (curr_level + 1)% len(levels)
        init()


    # if (time.time() - last_frame > 1): # redrawing every one second
    #     # show on sense hat
    #     hat.clear()
    #     y = 0
    #     for row in level:
    #         x = 0
    #         for col in row:
    #             if (col == "#"):
    #                 hat.set_pixel(x,y, white)
    #             if (col == "S"):
    #                 hat.set_pixel(x,y, purple)
    #             if (col == "+"):
    #                 hat.set_pixel(x,y, brown)
    #             if (col == "b"):
    #                 hat.set_pixel(x,y, red)
    #             x = x + 1
    #         y = y + 1
    #     last_frame = time.time()
