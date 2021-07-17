from picamera import PiCamera
from time import sleep

camera = PiCamera()
camera.zoom = (0, 0, 1.0, 1.0)
camera.start_preview()
sleep(15)
camera.stop_preview()