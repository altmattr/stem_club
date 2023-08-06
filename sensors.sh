#! /usr/bin/python3

from sense_hat import SenseHat
import logging
import time

logging.basicConfig(
        format='%(asctime)s %(levelname)-8s %(message)s',
        level=logging.INFO,
        datefmt='%Y-%m-%d %H:%M:%S')

hat = SenseHat()
hat.color.gain = 60
hat.color.integration_cycles = 64

while True:
  red, green, blue, clear = hat.colour.colour
  logging.info("pressure = %f", hat.get_pressure())
  logging.info("temperature = %f", hat.get_temperature())
  logging.info("humidity = %f", hat.get_humidity())
  logging.info("light = %f", clear)
  logging.info("red = %f", red)
  logging.info("green = %f", green)
  logging.info("blue = %f", blue)

  time.sleep(1)
