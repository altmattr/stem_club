#!/bin/python3

from sense_hat import SenseHat
import sys

print(sys.argv[1])
hat = SenseHat()
hat.show_message(sys.argv[1])
