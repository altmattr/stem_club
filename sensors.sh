#! /usr/bin/python3

from sense_hat import SenseHat
import logging
from logging.handlers import TimedRotatingFileHandler
import time

logging.basicConfig(
        format='%(asctime)s,%(levelname)s,%(message)s',
        level=logging.INFO,
        datefmt='%Y-%m-%d %H:%M:%S',
        handlers=[logging.StreamHandler(),
                  logging.handlers.TimedRotatingFileHandler("/home/pi/stem_club/logs/sensor", when="m", interval=10)
	         ])

hat = SenseHat()
hat.set_rotation(90)
hat.set_imu_config(True, True, True)
hat.color.gain = 60
hat.color.integration_cycles = 64

while True:
  red, green, blue, clear = hat.colour.colour
  orientation = hat.get_orientation_degrees()
  logging.info("pressure,%f", hat.get_pressure())
  logging.info("temperature via humidity,%f", hat.get_temperature_from_humidity())
  logging.info("temperature via pressure,%f", hat.get_temperature_from_pressure())
  logging.info("temperature,%f", hat.get_temperature())
  logging.info("humidity,%f", hat.get_humidity())
  logging.info("light,%f", clear)
  logging.info("red,%f", red)
  logging.info("green,%f", green)
  logging.info("blue,%f", blue)
  logging.info("pitch,%f", orientation["pitch"])
  logging.info("roll,%f", orientation["roll"])
  logging.info("yaw,%f", orientation["yaw"])

  time.sleep(1)
