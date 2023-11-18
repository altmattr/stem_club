#! /usr/bin/python3 -u

import argparse
import subprocess
import tflite_runtime.interpreter as tflite
import numpy as np
from PIL import Image
import time
import shutil
import os
import glob
from picamera2 import *
from libcamera import Transform
from sense_hat import SenseHat
from datetime import datetime

# Leaving this line here just in case it's useful later, but this is totally useless at the moment
#HATSTAT = subprocess.call(["tr", "-d \'\\0\' < /proc/device-tree/hat/product"], stdout=subprocess.DEVNULL, stderr=subprocess.STDOUT)

# Setting log levels for picamera2 and libcamera to get rid of a hell of a lot of pesky messages, plus saving time between inferences
Picamera2.set_logging(Picamera2.CRITICAL)
os.environ["LIBCAMERA_LOG_LEVELS"] = "4"


try:
	cam = Picamera2()
	cam.still_configuration.enable_lores()
	config = cam.create_still_configuration(lores={"size": (224, 224)}, display="lores")
	cam.configure(config)
	cam.start_preview(Preview.NULL)
except:
	print("no camera detected")
	cam = None

def feed(lst_globs):
	if lst_globs == "":
		while True:
			cam.still_configuration.enable_lores()
			config = cam.create_still_configuration(lores={"size": (224, 224)}, display="lores")
			cam.configure(config)
			cam.start_and_capture_file("captures/camera-feed.jpg")
			yield "captures/camera-feed.jpg"
	else:
		for img_glob in sources[src_i][1]:
			for img_path in glob.glob(img_glob):
				yield img_path

argparser = argparse.ArgumentParser(description="Run a Model on a set of images or a camera feed and generate predictions.")
argparser.add_argument("--model", metavar="M", type=int, help="the index of the model to use.")
argparser.add_argument("--source", metavar="S", type=int, help="the index of the source to use.")
argparser.add_argument("--dir", metavar="d", help="define the model directory directly")
args = argparser.parse_args()

models = [("Stem Club", "models/stem_club"),
		("MobileNet V1 224","models/mobilenet_v1_1.0_224_quant"),
		("MobileNet V1 128","models/mobilenet_v1_0.25_128_quant"),
		("MobileNet V3 224 float", "models/mobilenet_v3_224_float"),
		("Inception V4", "models/inception_v4_quant"),
		("Custom: Is the camera covered (quant)?", "models/covered_quant"),
		("Custom: Is the camera covered (float)?", "models/covered_float"),
		("Custom: Numbers 0 or 1", "models/Zero_One_Model01"),
		("Custom: Numbers 0 to 5", "models/Zero_Five_Model03"),
		("Custom: Glasses or not glasses?", "models/glasses_or_not")
		]

sources = [("Example Images",["images/224x224/*",
							"images/room.jpg", 
							"images/239x215/*", 
							"images/128x128/*",
							"images/imagenet_examples/*",
							"images/faces/*"
							]),
		("Camera","")
		]

try: 
	hat = SenseHat()
	hat.show_message("?")
except:
	print("No sense hat detected")

if args.model is None:
	print("Which model would you like to run?")
	for i, mod in enumerate(models):
		print(f"({i}) {mod[0]}")
	model_i = int(input())
else:
	model_i = args.model

if args.source is None:
	print("Which source would you like predict from?")
	for i, src in enumerate(sources):
		print(f"({i}) {src[0]}")
	src_i = int(input())
else:
	src_i = args.source

try:
	hat.show_letter(str(model_i), [255,255,255], [0,0,0])
except:
	pass

interpreter = tflite.Interpreter(models[model_i][1]+"/model.tflite")
interpreter.allocate_tensors()

inputs = interpreter.get_input_details()[0];
outputs = interpreter.get_output_details()[0];
width  = inputs["shape"][2]
height = inputs["shape"][1]
dtype = inputs["dtype"]
scale, zero = outputs['quantization']
print(f"Predicting with model:  {models[model_i][0]}\n  * size: ({width}x{height})\n  * type: {dtype}\n  * scale: ({scale},{zero})")

lables=[]
with open(models[model_i][1]+"/labels.txt", "r") as f:
	labels = [line.strip() for line in f.readlines()]

icons=[]
try:
	with open(models[model_i][1]+"/icons.txt", "r") as f:
		icons = [line.strip() for line in f.readlines()]
except:
	print("no icon file found")

print(f"Predicting from source: {sources[src_i][0]}")

try:
	hat.clear()
except:
	pass

for img_path in feed(sources[src_i][1]):
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

	# display on sense_hat
	try:
		hat.show_message(str(best_index), 0.1, [255,255,255], [0,0,0])
	except:
		pass

	# log if needed
	log_as_file = "/home/pi/stem_club/logs/" + models[model_i][1] + "/" + labels[best_index].strip("*")+"/" + datetime.now().strftime("%Y-%m-%d:%H:%M:%S")+".png" if labels[best_index].endswith("*")  else None
	if (log_as_file):
		os.makedirs(os.path.dirname(log_as_file), exist_ok=True)
		shutil.copy(img_path, log_as_file)

	print(f"  * {img_path} = {labels[best_index]} %0.0f%%" % output_data[best_index])