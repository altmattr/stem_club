from sense_hat import SenseHat
from signal import pause
import subprocess
import time
import os
import signal
import shutil
import sh_utils

hat = SenseHat()
hat.clear()
hat.set_rotation(90)
page = 0
modes = [
          ("focus",            "K", lambda: killable_script(["/home/pi/stem_club/focus.sh"], cwd="/home/pi"))
        , ("happy",            "H", lambda: killable_script(["/home/pi/stem_club/happy_snap.sh"], cwd="/home/pi/stem_club/happy_snaps", sleep=False))
        , ("stream",           "S", lambda: killable_script(["/home/pi/stem_club/stream.sh"], progress=True))
        , ("disk",             "D", lambda: killable_script(["/home/pi/stem_club/disk_used.sh"]))
        , ("network details",  "N", lambda: killable_script(["/home/pi/stem_club/report_ssid.sh"], cwd="/home/pi/stem_club"))
        , ("refresh_ssid",     "R", lambda: killable_script(["/home/pi/stem_club/new_ssid.sh"], cwd="/home/pi/stem_club"))
        , ("join_local",       "B", lambda: killable_script(["/home/pi/stem_club/base_mode.sh"], cwd="/home/pi/stem_club"))
        , ("force hotspot",    "F", lambda: killable_script(["/home/pi/stem_club/field_mode.sh"], cwd="/home/pi/stem_club"))
        , ("training_capture", "T", lambda: killable_script(["/home/pi/stem_club/capture.sh"], progress=True))
        , ("image_net",        "s", lambda: killable_script(["python3", "-u", "/home/pi/stem_club/picam2_predict.sh", "--model", "0", "--source", "1"], cwd="/home/pi/stem_club"))
        , ("covered?",         "c", lambda: killable_script(["python3", "-u", "/home/pi/stem_club/picam2_predict.sh", "--model", "5", "--source", "1"], cwd="/home/pi/stem_club"))
        , ("zero one",         "z", lambda: killable_script(["python3", "-u", "/home/pi/stem_club/picam2_predict.sh", "--model", "7", "--source", "1"], cwd="/home/pi/stem_club"))
        , ("numbers?",         "n", lambda: killable_script(["python3", "-u", "/home/pi/stem_club/picam2_predict.sh", "--model", "8", "--source", "1"], cwd="/home/pi/stem_club"))
        , ("glasses?",         "g", lambda: killable_script(["python3", "-u", "/home/pi/stem_club/picam2_predict.sh", "--model", "9", "--source", "1"], cwd="/home/pi/stem_club"))
        ]
ps = None

print("hat initialised")

def menu():
    global page
    while True:
        # show the mode we are in
        hat.show_letter(modes[page][1])
        # show an indication of running short of disk space (less than 10MB)
        if (shutil.disk_usage("/").free < 10**7):
            hat.set_pixel(0,0,[255,0,0])
            hat.set_pixel(0,7,[255,0,0])
            hat.set_pixel(7,0,[255,0,0])
            hat.set_pixel(7,7,[255,0,0])
        event = hat.stick.wait_for_event()
        if (event.action != "pressed"):
            continue
        elif (event.direction == "down"):
            print("moving right " + str(page))
            page = (page + 1)% len(modes)
        elif (event.direction == "up"):
            print("moving left " + str(page))
            page = (page - 1)% len(modes)
        elif (event.direction == "middle"):
            print("pushing in " + str(page))
            modes[page][2]()

def killable_script(script, progress=False, cwd=None, sleep=True):
        ps = subprocess.Popen(script, cwd=cwd, preexec_fn=os.setsid)
        hat.clear()
        loops = 0
        while ps.poll() == None:
            # print the visualistaion of where we are up to
            loops = loops + 1
            if progress:
              sh_utils.pixels_of_num(loops)
            # wait a sec
            if sleep: 
              time.sleep(1)
            # check if we were interrupted
            for evt in hat.stick.get_events():
                if (evt.direction == "middle" and evt.action == "pressed"):
                    print("got one to kill")
                    print(ps.pid) 
                    os.killpg(os.getpgid(ps.pid), signal.SIGTERM)
                    print("process killed")
                    ps = None
                    return
        ps = None
        return

        
menu()
