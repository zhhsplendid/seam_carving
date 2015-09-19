function [output] = increaseWidth(im, numPixels)
    scImage = SeamCarvingImage(im);
    output = scImage.increaseWidth(im, numPixels);
end

