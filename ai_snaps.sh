#! /usr/bin/python3 -u

import argparse
import subprocess
import tflite_runtime.interpreter as tflite
import numpy as np
from PIL import Image
import time
import shutil
import os
import re
import glob
from picamera2 import *
from sense_hat import SenseHat
from datetime import datetime

def hat_or(hat, other):
  try:
    hat()
  except:
    other()

try:
	cam = Picamera2()
	cam.still_configuration.enable_lores()
	config = cam.create_still_configuration(lores={"size": (224, 224)}, display="lores")
	cam.configure(config)
	cam.start_preview(Preview.NULL)
	cam.start()
except:
	print("no camera detected")
	cam = None

argparser = argparse.ArgumentParser(description="Run a Model on a set of images or a camera feed and generate predictions.")
argparser.add_argument("--model", metavar="M", help="the name of the model to use.")
args = argparser.parse_args()

try: 
	hat = SenseHat()
	print("hat found")
	hat.set_rotation(90)
	hat.show_message("?")
except:
	print("No sense hat detected")

if args.model is None:
	print("Which model would you like to run?")
	for mod in os.listdir("models"):
		print(f"{mod}")
	model = input()
else:
	model =  args.model

try:
	print("showing model")
	hat.show_message(model)
except:
	print("no model")
	pass

modelfile = f"models/{model}/model.tflite"
if os.path.isfile(f"models/{model}/model_unquant.tflite"):
	modelfile = f"models/{model}/model_unquant.tflite"

interpreter = tflite.Interpreter(modelfile)
interpreter.allocate_tensors()

inputs = interpreter.get_input_details()[0];
outputs = interpreter.get_output_details()[0];
width  = inputs["shape"][2]
height = inputs["shape"][1]
dtype = inputs["dtype"]
scale, zero = outputs['quantization']
print(f"Predicting with model:  {model}\n  * size: ({width}x{height})\n  * type: {dtype}\n  * scale: ({scale},{zero})")

labels=[]
with open(f"models/{model}/labels.txt", "r") as f:
	labels = [line.strip() for line in f.readlines()]

# labels_plus will be <bin> <label> at least, and maybe <icon> as well
labels_plus = list(map(lambda l: re.split("(?<=\d)\s+|\s+(?=\[)", l), labels))

while True:
	event = hat.stick.wait_for_event()
	if (event.direction == "middle" and event.action == "pressed"):
		exit()
	if (event.action != "pressed"):
		continue
	hat_or(lambda: hat.clear(), lambda:print("predicting..."))
	img_path= "/home/pi/stem_club/captures/camera-feed.jpg"
	cam.capture_file(img_path)                               # grab and save file

	img = Image.open(img_path).convert('RGB').resize((width, height))
	
	# we need another dimension
	input_data = np.expand_dims(img, axis=0)
	# TODO: hard coding the std for float32 models - but seems to work for now
	if (dtype == np.float32):
		input_data = (np.float32(input_data) - 127.5) / 127.5

	# lets get to it
	interpreter.set_tensor(inputs["index"], input_data)

	interpreter.invoke()

	output_data = interpreter.get_tensor(outputs["index"]).squeeze()
	if (scale > 0): # TODO: this line scales and converts to percentage, so we need an else.  Might be better to do percentage in the display line
		output_data = (scale*100) * (output_data - zero)
	else:
		output_data = 100 * output_data

	ordered_indexes = np.flip(output_data.argsort())
	best_index = ordered_indexes[0]

	bin   = labels_plus[best_index][0]                        if len(labels_plus[best_index]) > 0 else None
	label = labels_plus[best_index][1]                        if len(labels_plus[best_index]) > 1 else None
	img   = labels_plus[best_index][2].strip("][").split(",") if len(labels_plus[best_index]) > 2 else None
	
	colour=[0,0,255]
	# display on sense_hat
	try:
		if img:
			this_img = list(map(lambda i: colour if (i == "1") else [0,0,0], img))
			hat.set_pixels(this_img[:64])
		else: 
			hat.show_message(str(best_index), 0.1, [255,255,255], [0,0,0])
	except:
		print("no hat found at display time")

	# log if needed
	log_as_file = "/home/pi/stem_club/logs/" + model + "/" + label+"/" + datetime.now().strftime("%Y-%m-%d_%H_%M_%S")+".png" if not label.endswith("*") else None
	if (log_as_file):
		os.makedirs(os.path.dirname(log_as_file), exist_ok=True)
		shutil.copy(img_path, log_as_file)

	print(f"  * {img_path} = {label} %0.0f%%" % output_data[best_index])
