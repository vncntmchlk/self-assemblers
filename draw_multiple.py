import cv2  # Not actually necessary if you just want to create an image.
import numpy as np

height = 140
width = 270
blank_image = np.zeros((height,width,3), np.uint8)
center_coordinates = (int(width * 0.5), int(height * 0.5))
 
def draw_circle(img, radius):
    color = (255, 255, 255) # spaeter (1, 1, 1)
    thickness = 2  
    img = cv2.circle(img, center_coordinates, radius, color, thickness)
    img = cv2.cvtColor(img,cv2.COLOR_BGR2GRAY)
 
#blank_image =
#draw_circle(blank_image, 50)
for r in [20, 30, 40, 50]:
    draw_circle(blank_image, r)

cv2.imwrite("test.jpg", blank_image)
