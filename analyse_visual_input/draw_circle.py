import cv2  # Not actually necessary if you just want to create an image.
import numpy as np
from picamera.array import PiRGBArray
from picamera import PiCamera
import time
from pythonosc.udp_client import SimpleUDPClient

client = SimpleUDPClient("192.168.178.28", 9000)  # Create client
xmin = 120
xmax = 304
ymin = 0
ymax = 280

height = xmax - xmin
width = ymax - ymin
blank_image = np.zeros((height,width,3), np.uint8)
print(height, width)
# Center coordinates
center_coordinates = (int(width * 0.5), int(height * 0.5))
 
# Radius of circle
radius = 50
  
# Blue color in BGR
color = (1, 1, 1)
  
# Line thickness of 2 px
thickness = 2
  
# Using cv2.circle() method
# Draw a circle with blue line borders of thickness of 2 px
circle = cv2.circle(blank_image, center_coordinates, radius, color, thickness)
circle = cv2.cvtColor(circle,cv2.COLOR_BGR2GRAY)

params = cv2.SimpleBlobDetector_Params()
params.blobColor = 255
params.filterByArea = True
params.minArea = 1
params.maxArea = 200
params.filterByCircularity = False
params.filterByConvexity = False
params.filterByInertia = False

ver = (cv2.__version__).split('.')
if int(ver[0]) < 3 :
    detector = cv2.SimpleBlobDetector(params)
else : 
    detector = cv2.SimpleBlobDetector_create(params)

def apply_thresh(img):
    img_not = cv2.bitwise_not(img)
    (thresh, im_bw) = cv2.threshold(img_not, 128, 255, cv2.THRESH_BINARY | cv2.THRESH_OTSU)
    #print(thresh)
    im_bw = cv2.threshold(img_not, 200, 1, cv2.THRESH_BINARY)[1]
    return im_bw

camera = PiCamera()
camera.resolution = (304, 304)
#camera.zoom = (0.25, 0.25, 1.0, 1.0)

camera.framerate = 20
rawCapture = PiRGBArray(camera, size=(304, 304))

pictures = []

display_window = cv2.namedWindow("Faces")

time.sleep(1)

for frame in camera.capture_continuous(rawCapture, format="bgr", use_video_port=True):

    
    key = cv2.waitKey(1)
    #print(key)
    rawCapture.truncate(0)


    #if key == 32:
    image = frame.array
    #FACE DETECTION STUFF
    gray = cv2.cvtColor(image,cv2.COLOR_BGR2GRAY)
    #faces = face_cascade.detectMultiScale(gray, 1.1, 5)
    #DISPLAY TO WINDOW
    #cv2.imshow("Faces", image)
    crop_img = gray[xmin:xmax, ymin:ymax]
    new_pic = apply_thresh(crop_img)
        
    overlap = cv2.multiply(circle, new_pic) * 255
    keypoints = detector.detect(overlap)
    
    im_with_keypoints = cv2.drawKeypoints(crop_img, keypoints, np.array([]), (0,0,255), cv2.DRAW_MATCHES_FLAGS_DRAW_RICH_KEYPOINTS) #overlap
    #print([item for sublist in keypoints for item in sublist.pt])
    #if keypoints:
    points_flat = [item for sublist in keypoints for item in sublist.pt]
    client.send_message("/points", points_flat)   # Send float message

    cv2.imshow("Faces", im_with_keypoints)

