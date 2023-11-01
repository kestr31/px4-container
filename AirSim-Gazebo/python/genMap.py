import os
import time
from pykeyboard import PyKeyboard

k = PyKeyboard()
os.system('xdotool search --name "ForestDeploy" | xargs xdotool windowactivate')
k.press_key('G')
time.sleep(3)
k.release_key('G')