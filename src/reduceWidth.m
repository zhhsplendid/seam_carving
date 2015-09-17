function [output] = reduceWidth(im, numPixels)
    scImage = SeamCarvingImage(im);
    output = scImage.reduceWidth(numPixels);
end

