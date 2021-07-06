import cv2
import numpy as np

img1 = cv2.imread('bw_image1.jpg')
img2 = cv2.imread('bw_image2.jpg')
#img1_not = cv2.bitwise_not(img1)
#img2_not = cv2.bitwise_not(img2)

# overlap = img1_not * img2_not
overlap = cv2.multiply(img1, img2)
#print(np.where(overlap>0))
print(overlap)
cv2.imwrite('c.png', overlap * 255)

#print(overlap)


# #our target area (the black background)
# dst = np.zeros((100,100),dtype=np.int)
# src1 = dst.copy() 
# src2 = dst.copy()
# src1[50:,50:] = 1 #fake of first translated image (row/col 50-end)
# src2[:70,:70] = 1 #fake of second translated image (row/col 0-70)
# 
# overlap = src1+src2 #sum of both *element-wise*
# 
# cv2.imwrite('a.png', src1*255) #opencv likes it's grey images span from 0-255
# cv2.imwrite('b.png', src2*255) #...
# cv2.imwrite('c.png', overlap*127) #here vals 0-2, *127 gives (almost) 255 again
# 
# np.where(overlap==2) #gives you a mask with all pixels that have value 2