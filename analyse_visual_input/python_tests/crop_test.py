import cv2
img = cv2.imread("foo.jpg")
y = 50
x = 50
h = 50
w = 50
crop_img = img[y:y+h, x:x+w]
cv2.imshow("cropped", crop_img)