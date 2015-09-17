function [output] = reduceHeight(im, numPixels)
    scImage = SeamCarvingImage(im);
    output = scImage.reduceHeight(numPixels);
end

