#! /usr/bin/python3

import random
import time
from sense_hat import SenseHat

hat = SenseHat()
hat.set_rotation(90)
hat.clear()

print("for use with sense hat")

game_over = False
last_input = 0
match = 6
player = 1
fill = 0
score = 0
next = int(random.randint(1,6))
countdown = 1
drop = 1
white = [255,255,255]
black = [0,0,0]
red = [255,0,0]
green = [0,255,0]
orange = [255,165,0]
brown = [101,73,46]
purple = [41,37,62]
yellow = [255,255,0]

last_time = time.time()
while not game_over:
    # grab oldest move and discard rest
    events = hat.stick.get_events()
    if ((len(events) > 0)                and 
        (events[0].action == "pressed")  and
        ((events[0].timestamp - last_input) > 0.25)
       ):
      print(events[0])
      direction = events[0].direction
      if (direction == "up"):
        player = max(player - 1, 0)
      if (direction == "down"):
        player = min(player + 1, 7)
    
    # show player
    for col in range(0,8):
      if player == col:
        if (fill == 0):
          hat.set_pixel(col, 7, white)
        if (fill == 1):
          hat.set_pixel(col, 7, green)
        if (fill == 2):
          hat.set_pixel(col, 7, orange)
        if (fill == 3):
          hat.set_pixel(col, 7, red)
      else:
        hat.set_pixel(col, 7, black)
    
    # show next
    for col in range(0,8):
      if next == col:
        hat.set_pixel(col, 0, orange)
      else:
        hat.set_pixel(col, 0, black)

    # show the walls
    for row in range(0,7):
       hat.set_pixel(0, row, purple)
       hat.set_pixel(7, row, purple)
    hat.set_pixel(0,7, black)
    hat.set_pixel(7,7, black)
    # show the match
    hat.set_pixel(0, match, yellow)

    # things to do one per second 
    if (time.time() - last_time > drop):
      last_time = time.time()
      print(countdown)
      
      # drop all current bombs
      for row in range(6, 0, -1):
        for col in range(1,7):
          if (hat.get_pixel(col, row) != black):
            if (row == 6):
              if (col == player):
                fill = fill + 1
                if (fill > 3):
                  game_over = True
              else:
                  game_over = True
            hat.set_pixel(col, row+1, white)
            hat.set_pixel(col, row, black)
      # drop the match
      match = min(match + 1, 6)

      # if the player is on the edge, dump some bombs
      if ((player == 0 or player == 7) and (fill > 0)):
        fill = fill - 1
        score = score + 1
        # if the drop is on the left, send the match up two
        if (player == 0):
          match = match - 2
          if (match <= 0):
            score = score + 5
            match = 6

      # drop next bomb
      if (countdown == 0):
        print("next: " + str(next))
        hat.set_pixel(next, 1, white)
        next = int(random.randint(1,6))
        countdown = 4

      countdown = countdown - 1
     
# game is over, show score and exit
hat.clear()
for i in range(0,3):
  hat.show_message(str(score))
