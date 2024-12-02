# zombie.py
import os
import time

pid = os.fork()
if pid > 0:

    time.sleep(60)
else:
   
    os._exit(0)
