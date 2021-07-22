import cv2  # Not actually necessary if you just want to create an image.
import numpy as np
from picamera.array import PiRGBArray
from picamera import PiCamera
import time
from pythonosc.udp_client import SimpleUDPClient

def numpy_flat(a):
    return np.array(a).flatten().tolist()
    #return list(np.array(a).flat)


ip = "192.168.1.100"
# ip = "192.168.0.182"
client = SimpleUDPClient(ip, 9000)  # Create client

fps = 2
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
xmin = 70 #oberseite
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

print(height, width)

client.send_message("/resolution", [height, width])
# Center coordinates
center_coordinates = (int(width * 0.5), int(height * 0.5))

def apply_thresh(img):
    img_not = cv2.bitwise_not(img)
    (thresh, im_bw) = cv2.threshold(img_not, 128, 255, cv2.THRESH_BINARY | cv2.THRESH_OTSU)
    #print(thresh)
    im_bw = cv2.threshold(img_not, 190, 255, cv2.THRESH_BINARY)[1]
    return im_bw

camera = PiCamera()
camera.resolution = (resX, resY)
#camera.zoom = (0.25, 0.25, 1.0, 1.0)

camera.framerate = fps
rawCapture = PiRGBArray(camera, size=(resX, resY))

display_window = cv2.namedWindow("Faces")

time.sleep(1)

for frame in camera.capture_continuous(rawCapture, format="bgr", use_video_port=True):

    
    key = cv2.waitKey(1)
    #print(key)
    rawCapture.truncate(0)

    image = frame.array
    flipped = cv2.flip(image, -1) # flip both axis (-1)   

    crop_img = flipped[xmin:xmax, ymin:ymax]
    gray = cv2.cvtColor(crop_img,cv2.COLOR_BGR2GRAY)
    new_pic = apply_thresh(gray)
    
    contours, hierarchy = cv2.findContours(new_pic, 
    cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)

    for contour in contours:
        if(len(contour) > 15):
            #print(contour)
            client.send_message("/contour", numpy_flat(contour))
    
    
    client.send_message("/finished", 1)
    
    cv2.drawContours(crop_img, contours, -1, (0, 255, 0), 3)
    cv2.imshow("Faces", crop_img)




