import cv2  # Not actually necessary if you just want to create an image.
import numpy as np
from picamera.array import PiRGBArray
from picamera import PiCamera
import time
from pythonosc.udp_client import SimpleUDPClient

ip = "192.168.178.28"
# ip = "192.168.0.182"
client = SimpleUDPClient(ip, 9000)  # Create client

fps = 20
# adjust according to parts (may not need high fps for most parts)
#fast, small res, 24+ fps possible
# resX = 416
# resY = 368 
# xmin = 32
# xmax = resX - 110
# ymin = 18
# ymax = resY - 16

# mid res 20 fps
resX = 480
resY = 432
xmin = 50 #oberseite
xmax = resX - 120 #unterseite
ymin = 18 # links
ymax = resY - 16 # rechts

#high res, 20 fps, cpu hot
# resX = 544
# resY = 480 
# xmin = 40
# xmax = resX - 140
# ymin = 24
# ymax = resY - 20

height = xmax - xmin
width = ymax - ymin
blank_image = np.zeros((height,width,3), np.uint8)
print(height, width)

client.send_message("/resolution", [height, width])
# Center coordinates
center_coordinates = (int(width * 0.5), int(height * 0.5))
# circle parameters
#radius = 150
color = (1, 1, 1)
thickness = 2 # px
    
circle = cv2.circle(blank_image, center_coordinates, 70, color, thickness)
circle = cv2.circle(circle, center_coordinates, 90, color, thickness)
circle = cv2.circle(circle, center_coordinates, 110, color, thickness)
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
    im_bw = cv2.threshold(img_not, 220, 1, cv2.THRESH_BINARY)[1]
    return im_bw

camera = PiCamera()
camera.resolution = (resX, resY)
#camera.zoom = (0.25, 0.25, 1.0, 1.0)

camera.framerate = fps
rawCapture = PiRGBArray(camera, size=(resX, resY))

pictures = []

display_window = cv2.namedWindow("Faces")

time.sleep(1)

for frame in camera.capture_continuous(rawCapture, format="bgr", use_video_port=True):

    
    key = cv2.waitKey(1)
    #print(key)
    rawCapture.truncate(0)


    #if key == 32:
    image = frame.array
    flipped = cv2.flip(image, -1) # flip both axis (-1) 
    #FACE DETECTION STUFF
    gray = cv2.cvtColor(flipped,cv2.COLOR_BGR2GRAY)
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


