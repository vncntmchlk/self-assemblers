import cv2  # Not actually necessary if you just want to create an image.
import numpy as np
from picamera.array import PiRGBArray
from picamera import PiCamera
import time
from pythonosc.udp_client import SimpleUDPClient
from pythonosc import dispatcher
from pythonosc import osc_server
import socket

def get_ip():
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    try:
        # doesn't even have to be reachable
        s.connect(('10.255.255.255', 1))
        IP = s.getsockname()[0]
    except Exception:
        IP = '127.0.0.1'
    finally:
        s.close()
    return IP

def numpy_flat(a):
    return np.array(a).flatten().tolist()
    #return list(np.array(a).flat)

ip = "192.168.1.101"
# ip = "192.168.0.182"
#ip = "192.168.178.28"
client = SimpleUDPClient(ip, 9000)  # Create client
myIP = get_ip()
myPort = 9001

resX = 480
resY = 432
xmin = 90 #oberseite
xmax = resX - 120 #unterseite
ymin = 24 # links
ymax = resY - 16 # rechts
# resX = 160
# resY = 128
# xmin = 24 #oberseite
# xmax = resX - 20 #unterseite
# ymin = 8 # links
# ymax = resY - 0 # rechts

height = xmax - xmin
width = ymax - ymin
blank_image = np.zeros((height,width,3), np.uint8)
print(height, width)

# Center coordinates
center_coordinates = (int(width * 0.5), int(height * 0.5))


# circle parameters
#radius = 150
color = (1, 1, 1)
thickness = 2 # px
    
# left side circles
left_center = (int(center_coordinates[0] * 0.5), center_coordinates[1])
circle = cv2.circle(blank_image, left_center, 40, color, thickness)
circle = cv2.circle(circle, left_center, 60, color, thickness)
circle = cv2.circle(circle, left_center, 80, color, thickness)

# right side circles
right_center = (int(center_coordinates[0] * 1.5), center_coordinates[1])
circle = cv2.circle(circle, right_center, 40, color, thickness)
circle = cv2.circle(circle, right_center, 60, color, thickness)
circle = cv2.circle(circle, right_center, 80, color, thickness)
circle = cv2.cvtColor(circle,cv2.COLOR_BGR2GRAY)

client.send_message("/resolution", [height, width, left_center[0], left_center[1], right_center[0], right_center[1]])

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
    im_bw = cv2.threshold(img_not, 190, 1, cv2.THRESH_BINARY)[1]
    return im_bw

camera = PiCamera()
fps = 20
camera.framerate = fps
camera.resolution = (resX, resY)
rawCapture = PiRGBArray(camera, size=(resX, resY))

time.sleep(1)

dispatcher = dispatcher.Dispatcher()

def getContour(address, *args):
    new_pic = takePic() * 255
    contours, hierarchy = cv2.findContours(new_pic,cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_NONE)
    #cv2.drawContours(crop_img, contours, -1, (0, 255, 0), 3)
    #cv2.imwrite('result.jpg',crop_img)
    for contour in contours:
        if(len(contour) > 15):
            #print(contour)
            client.send_message("/contour", numpy_flat(contour))
    client.send_message("/finished", 1)
    
def takePic():
    #with rawCapture as stream:
    key = cv2.waitKey(1)
    rawCapture.truncate(0)
    camera.capture(rawCapture, format='bgr', use_video_port=True)
    image = rawCapture.array
    flipped = cv2.flip(image, -1) # flip both axis (-1)
    crop_img = flipped[xmin:xmax, ymin:ymax]
    gray = cv2.cvtColor(crop_img,cv2.COLOR_BGR2GRAY)
    new_pic = apply_thresh(gray)
    return new_pic


circleOn = 0
    
    
import threading

e = threading.Event()

def startVideo(e):
    print('start camera capture ..')
    while not e.isSet():
        #print("video .. ")
        new_pic = takePic()
        overlap = cv2.multiply(circle, new_pic) * 255
        crop_left = overlap[:, 0:center_coordinates[0]]# 0:center_coordinates[0]
        crop_right = overlap[:, center_coordinates[0]:width]
        keypoints_left = detector.detect(crop_left)
        keypoints_right = detector.detect(crop_right)
        points_left = [item for sublist in keypoints_left for item in sublist.pt]
        client.send_message("/points_left", points_left)
        points_right = [item for sublist in keypoints_right for item in sublist.pt]
        client.send_message("/points_right", points_right)
#         print(overlap)
        cv2.imshow("Faces", overlap)
        time.sleep(0.001)
#        print(points_left)    

def circleOnOff(address, *args):
    circleOn = args[0]
    if circleOn:
        e.clear()
        t = threading.Thread(target=startVideo, args=(e,))
        t.start()
        #t.join()
    else:
        e.set()

dispatcher.map("/takePic", getContour)
dispatcher.map("/circles", circleOnOff)

server = osc_server.ThreadingOSCUDPServer((myIP, myPort), dispatcher)
print("Serving on {}".format(server.server_address))
server.serve_forever()
