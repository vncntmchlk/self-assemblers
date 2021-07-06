import cv2
im_gray = cv2.imread('foo.jpg', cv2.IMREAD_GRAYSCALE)
im_gray_not = cv2.bitwise_not(im_gray)
(thresh, im_bw) = cv2.threshold(im_gray_not, 128, 255, cv2.THRESH_BINARY | cv2.THRESH_OTSU)

#thresh = 127
im_bw = cv2.threshold(im_gray_not, thresh, 1, cv2.THRESH_BINARY)[1]
print(im_bw)
cv2.imwrite('bw_image2.jpg', im_bw)
