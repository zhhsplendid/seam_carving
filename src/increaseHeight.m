function [output] = increaseHeight(im, numPixels)
    scImage = SeamCarvingImage(im);
    output = scImage.increaseHeight(im, numPixels);
end

