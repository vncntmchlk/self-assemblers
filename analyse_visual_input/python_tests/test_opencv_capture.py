from picamera.array import PiRGBArray
from picamera import PiCamera
import cv2
import time

def apply_thresh(img):
    img_not = cv2.bitwise_not(img)
    (thresh, im_bw) = cv2.threshold(img_not, 128, 255, cv2.THRESH_BINARY | cv2.THRESH_OTSU)
    print(thresh)
    im_bw = cv2.threshold(img_not, 200, 1, cv2.THRESH_BINARY)[1]
    return im_bw

camera = PiCamera()
camera.resolution = (304, 304)
#camera.zoom = (0.25, 0.25, 1.0, 1.0)

camera.framerate = 30
rawCapture = PiRGBArray(camera, size=(304, 304))

pictures = []

display_window = cv2.namedWindow("Faces")

time.sleep(1)

for frame in camera.capture_continuous(rawCapture, format="bgr", use_video_port=True):

    
    key = cv2.waitKey(1)
    print(key)
    rawCapture.truncate(0)


    if key == 32:
        image = frame.array
        #FACE DETECTION STUFF
        gray = cv2.cvtColor(image,cv2.COLOR_BGR2GRAY)
        #faces = face_cascade.detectMultiScale(gray, 1.1, 5)
        #DISPLAY TO WINDOW
        #cv2.imshow("Faces", image)
        crop_img = gray[100:240, 30:300]
        pictures.insert(0, crop_img)
        if(len(pictures) > 1):
            im_bw1 = apply_thresh(pictures[0])
            im_bw2 = apply_thresh(pictures[1])
            overlap = cv2.multiply(im_bw1, im_bw2)
            cv2.imshow("Faces", overlap * 255)
            pictures.pop()
