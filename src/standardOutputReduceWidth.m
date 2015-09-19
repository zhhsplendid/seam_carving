function standardOutputReduceWidth(im, numPixels, outputPrefix)
    scImage = SeamCarvingImage(im);
    [kseams, changedImage] = scImage.chooseKVerticalSeams(im, numPixels);
    output = changedImage.image;
    osize = size(im);
    imwrite(im, [outputPrefix, '_original.jpg']);
    imwrite(output, [outputPrefix, '_seam_reduce.jpg'])
    imwrite(imresize(im, [osize(1), osize(2) - numPixels]),[outputPrefix, '_resize.jpg']);
   
    if size(osize, 2) == 3 % color image
        for r = 1:osize(1)
            for c = 1:osize(2)
                if kseams(r, c) == 1
                    im(r, c, 1) = 255;
                    im(r, c, 2) = 0;
                    im(r, c, 3) = 0;
                end
            end
        end
    else% gray image
        for r = 1:osize(1)
            for c = 1:osize(2)
                if kseams(r, c) == 1
                    im(r, c) = 255;
                end
            end
        end
    end
        
    imwrite(im, [outputPrefix, '_seams.jpg']);
end