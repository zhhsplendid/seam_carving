%Script for debug
img = imread('../input_images/avg_img.jpg');
c = SeamCarvingImage(img);
iimg = c.increaseWidth(img, 20);
imshow(iimg);