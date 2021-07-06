import cv2  # Not actually necessary if you just want to create an image.
import numpy as np

img = cv2.imread("testi.jpg", cv2.IMREAD_GRAYSCALE)
        

params = cv2.SimpleBlobDetector_Params()
print(params.getDefaultName())
ver = (cv2.__version__).split('.')
if int(ver[0]) < 3 :
    detector = cv2.SimpleBlobDetector(params)
else : 
    detector = cv2.SimpleBlobDetector_create(params)

#detector.empty() # <- now works
keypoints = detector.detect(img) # <- now works