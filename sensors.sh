#! /usr/bin/python3

from sense_hat import SenseHat
import logging
from logging.handlers import TimedRotatingFileHandler
import time

logging.basicConfig(
        format='%(asctime)s,%(levelname)s,%(message)s',
        level=logging.INFO,
        datefmt='%Y-%m-%d %H:%M:%S')
logger = logging.getLogger("sensor log")
logger.addHandler(TimedRotatingFileHandler("/home/pi/stem_club/logs/sensor",
                                            when="m",
					    interval=10))

hat = SenseHat()
hat.set_rotation(90)
hat.set_imu_config(True, True, True)
hat.color.gain = 60
hat.color.integration_cycles = 64

while True:
  red, green, blue, clear = hat.colour.colour
  orientation = hat.get_orientation_degrees()
  logger.info("pressure,%f", hat.get_pressure())
  logger.info("temperature via humidity,%f", hat.get_temperature_from_humidity())
  logger.info("temperature via pressure,%f", hat.get_temperature_from_pressure())
  logger.info("temperature,%f", hat.get_temperature())
  logger.info("humidity,%f", hat.get_humidity())
  logger.info("light,%f", clear)
  logger.info("red,%f", red)
  logger.info("green,%f", green)
  logger.info("blue,%f", blue)
  logger.info("pitch,%f", orientation["pitch"])
  logger.info("roll,%f", orientation["roll"])
  logger.info("yaw,%f", orientation["yaw"])

  time.sleep(1)
