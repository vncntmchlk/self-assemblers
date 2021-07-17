import cv2  # Not actually necessary if you just want to create an image.
import numpy as np

height = 140
width = 270
blank_image = np.zeros((height,width,3), np.uint8)
center_coordinates = (int(width * 0.5), int(height * 0.5))
 
def draw_line(img, start_point, end_point):
    color = (255, 255, 255) # spaeter (1, 1, 1)
    thickness = 2  
    img = cv2.line(img, start_point, end_point, color, thickness)
    img = cv2.cvtColor(img,cv2.COLOR_BGR2GRAY)

line_coords = [
    [(0,100),(50,120)],
    [(60,120),(100,10)],
    [(20,0),(50,20)]
]

for pts in line_coords:
    print(pts)
    draw_line(blank_image, pts[0], pts[1])

cv2.imwrite("test.jpg", blank_image)
