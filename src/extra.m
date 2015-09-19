%Script for debug
function extra()
    
    img = imread('../input_images/im2.jpg');
    c = SeamCarvingImage(img);
    
    iimg = c.increaseWidth(img, 100);
    imwrite(iimg, '../output_images/increasePixels/im2_iw_100_seam.jpg');
    imwrite(imresize(img, size(img, 1), size(img, 2)+100), '../output_images/increasePixels/im2_iw_100_resize.jpg')
    
    rimg = c.removeObject();
    imshow(rimg);
    imwrite(rimg, '../output_images/removeObject/im2_ro.jpg');
    
end