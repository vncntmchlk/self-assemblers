from picamera import PiCamera
from time import sleep

camera = PiCamera()
camera.zoom = (0.25, 0.25, 1.0, 1.0)
camera.start_preview()
sleep(5)
camera.stop_preview()