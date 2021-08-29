import cv2  
#import numpy as np
from picamera.array import PiRGBArray
from picamera import PiCamera
#import time

resX = 480
resY = 432
xmin = 90 #oberseite
xmax = resX - 120 #unterseite
ymin = 24 # links
ymax = resY - 16 # rechts

camera = PiCamera()
camera.resolution = (resX, resY)

rawCapture = PiRGBArray(camera, size=(resX, resY))

def takePic():#
    #with rawCapture as stream:
    key = cv2.waitKey(1)
    rawCapture.truncate(0)
    camera.capture(rawCapture, format='bgr', use_video_port=True)
    image = rawCapture.array
    flipped = cv2.flip(image, -1) # flip both axis (-1)
    crop_img = flipped[xmin:xmax, ymin:ymax]
    #gray = cv2.cvtColor(crop_img,cv2.COLOR_BGR2GRAY)
    #new_pic = apply_thresh(gray)
    return crop_img

pic = takePic()


height = xmax - xmin
width = ymax - ymin

# Center coordinates
center_coordinates = (int(width * 0.5), int(height * 0.5))

# circle parameters
#radius = 150
color = (200, 0, 0)
thickness = 2 # px
    
# left side circles
left_center = (int(center_coordinates[0] * 0.5), center_coordinates[1])
circle = cv2.circle(pic, left_center, 40, color, thickness)
circle = cv2.circle(circle, left_center, 60, color, thickness)
circle = cv2.circle(circle, left_center, 80, color, thickness)

# right side circles
right_center = (int(center_coordinates[0] * 1.5), center_coordinates[1])
circle = cv2.circle(circle, right_center, 40, color, thickness)
circle = cv2.circle(circle, right_center, 60, color, thickness)
circle = cv2.circle(circle, right_center, 80, color, thickness)
#circle = cv2.cvtColor(circle,cv2.COLOR_BGR2GRAY)

cv2.imwrite("why.jpg", circle)

print("fertig")
