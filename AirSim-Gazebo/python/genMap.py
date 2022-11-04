import os
from pykeyboard import PyKeyboard

k = PyKeyboard()
os.system('xdotool search --name "ForestDeploy" | xargs xdotool windowactivate')
k.press_key('G')