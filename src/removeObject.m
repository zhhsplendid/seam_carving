function [ output] = removeObject( input_img )
    c = SeamCarvingImage(input_img);
    output = c.removeObject();
end

