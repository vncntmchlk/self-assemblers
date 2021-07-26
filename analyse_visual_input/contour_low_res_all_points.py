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

#ip = "192.168.1.100"
# ip = "192.168.0.182"
ip = "192.168.178.28"
client = SimpleUDPClient(ip, 9000)  # Create client
myIP = get_ip()
myPort = 9001

resX = 480
resY = 432
xmin = 70 #oberseite
xmax = resX - 120 #unterseite
ymin = 18 # links
ymax = resY - 16 # rechts
# resX = 160
# resY = 128
# xmin = 24 #oberseite
# xmax = resX - 20 #unterseite
# ymin = 8 # links
# ymax = resY - 0 # rechts

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
rawCapture = PiRGBArray(camera, size=(resX, resY))

time.sleep(1)

dispatcher = dispatcher.Dispatcher()

def takePic(address, *args):
    with PiRGBArray(camera) as stream:
        camera.capture(stream, format='bgr')
        image = stream.array
        flipped = cv2.flip(image, -1) # flip both axis (-1)
        crop_img = flipped[xmin:xmax, ymin:ymax]
        gray = cv2.cvtColor(crop_img,cv2.COLOR_BGR2GRAY)
        new_pic = apply_thresh(gray)
        print("aa")
        contours, hierarchy = cv2.findContours(new_pic,cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_NONE)
        cv2.drawContours(crop_img, contours, -1, (0, 255, 0), 3)
        cv2.imwrite('result.jpg',crop_img)
        for contour in contours:
            if(len(contour) > 15):
                #print(contour)
                client.send_message("/contour", numpy_flat(contour))
        client.send_message("/finished", 1)


dispatcher.map("/takePic", takePic)

server = osc_server.ThreadingOSCUDPServer((myIP, myPort), dispatcher)
print("Serving on {}".format(server.server_address))
server.serve_forever()

# while 1:
#     with PiRGBArray(camera) as stream:
#         camera.capture(stream, format='bgr')
#         # At this point the image is available as stream.array
#         image = stream.array
#         flipped = cv2.flip(image, -1) # flip both axis (-1)
#         crop_img = flipped[xmin:xmax, ymin:ymax]
#         gray = cv2.cvtColor(crop_img,cv2.COLOR_BGR2GRAY)
#         new_pic = apply_thresh(gray)
#         print("aa")
#         contours, hierarchy = cv2.findContours(new_pic,cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_NONE)
#         cv2.drawContours(crop_img, contours, -1, (0, 255, 0), 3)
#         cv2.imwrite('result.jpg',crop_img)
#         time.sleep(1)
#         for contour in contours:
#             if(len(contour) > 15):
#                 #print(contour)
#                 client.send_message("/contour", numpy_flat(contour))
#         
#         
#         client.send_message("/finished", 1)

