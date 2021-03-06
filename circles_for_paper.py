import cv2  # Not actually necessary if you just want to create an image.
import numpy as np
 
scaling = 3
 
resX = 480 * scaling
resY = 432 * scaling
xmin = 90 #oberseite
xmax = resX - 120 #unterseite
ymin = 24 # links
ymax = resY - 16 # rechts

height = xmax - xmin
width = ymax - ymin
blank_image = np.ones((height,width,3), np.uint8) * 255
print(height, width)

# Center coordinates
center_coordinates = (int(width * 0.5), int(height * 0.5))

# circle parameters
#radius = 150
color = (0, 0, 0)
thickness = 2 * scaling # px
    
# left side circles
left_center = (int(center_coordinates[0] * 0.5), center_coordinates[1])
circle = cv2.circle(blank_image, left_center, 40 * scaling, color, thickness)
circle = cv2.circle(circle, left_center, 60 * scaling, color, thickness)
circle = cv2.circle(circle, left_center, 80 * scaling, color, thickness)

# right side circles
right_center = (int(center_coordinates[0] * 1.5), center_coordinates[1])
circle = cv2.circle(circle, right_center, 40 * scaling, color, thickness)
circle = cv2.circle(circle, right_center, 60 * scaling, color, thickness)
circle = cv2.circle(circle, right_center, 80 * scaling, color, thickness)
#circle = cv2.cvtColor(circle,cv2.COLOR_BGR2GRAY)

cv2.imwrite("test.jpg", circle)
