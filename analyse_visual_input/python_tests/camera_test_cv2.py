import cv2  
from picamera.array import PiRGBArray
from picamera import PiCamera
import time

xmin = 20
xmax = 250
ymin = 0
ymax = 295

camera = PiCamera()
res = (144, 128) # (544, 480)

camera.resolution = res

#camera.zoom = (0.25, 0.25, 1.0, 1.0)

camera.framerate = 20
rawCapture = PiRGBArray(camera, size=res)

display_window = cv2.namedWindow("Faces")

time.sleep(1)

for frame in camera.capture_continuous(rawCapture, format="bgr", use_video_port=True):
    key = cv2.waitKey(1)
    rawCapture.truncate(0)
    image = frame.array
    #crop_img = image[xmin:xmax, ymin:ymax]

    cv2.imshow("Faces", image)


