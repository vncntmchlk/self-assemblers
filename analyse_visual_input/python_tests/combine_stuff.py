import cv2

def apply_thresh(img):
    img_not = cv2.bitwise_not(img)
    (thresh, im_bw) = cv2.threshold(img_not, 128, 255, cv2.THRESH_BINARY | cv2.THRESH_OTSU)
    print(thresh)
    im_bw = cv2.threshold(img_not, thresh, 1, cv2.THRESH_BINARY)[1]
    return im_bw

img1 = cv2.imread('foo.jpg', cv2.IMREAD_GRAYSCALE)
img2 = cv2.imread('foo2.jpg', cv2.IMREAD_GRAYSCALE)
    
im_bw1 = apply_thresh(img1)
im_bw2 = apply_thresh(img2)

overlap = cv2.multiply(im_bw1, im_bw2)
#print(np.where(overlap>0))
#print(overlap)
cv2.imwrite('d.png', overlap * 255)
