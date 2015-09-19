classdef SeamCarvingImage
    %This class reads a image and performs seam carving functions
    
    properties
        ENERGY_FUNCTION_OPTION = 1;
        FRACTION_ENLARGE_SETP = 0.5;
        INF = 2^27;
        
        image;
        grayImage;
        doubleGrayImage;
        xDerivative;
        yDerivative;
        energyMap;
        
  
    end
    
    methods
        %constructor, just read image file
        function obj = SeamCarvingImage(input_image)
            obj.image = input_image;
            obj = obj.init();
        end
        
        function obj = init(obj)
            obj.grayImage = obj.convertGray();
            obj.doubleGrayImage = double(obj.grayImage);
            obj.xDerivative = obj.xDerivativeFilter();
            obj.yDerivative = obj.yDerivativeFilter();
            obj.energyMap = obj.energyFunction(obj.ENERGY_FUNCTION_OPTION);
            
        end
        
        %check whether obj.image is gray scale, and then convert.
        function grayImage = convertGray(obj)
            isize = size(obj.image); 
            %if obj.image is RGB image, isize should be [*, *, 3].
            %if obj.image is gray image, isize should be [*, *].
     
            if size(isize, 2) == 3 % 3 channels ==> RGB image
                grayImage = rgb2gray(obj.image);
            else % ==> gray image
                grayImage = obj.image;
            end
        end
        
        %Perform horizontal filter [-1, 1]
        function xDerivative = xDerivativeFilter(obj)
            filter = [-1, 1];
            xDerivative = imfilter(obj.doubleGrayImage, filter, 'same', 'circular'); 
        end
        
        %Perform vertical filter [-1, 1]'
        function yDerivative = yDerivativeFilter(obj)
            filter = [-1, 1]';
            yDerivative = imfilter(obj.doubleGrayImage, filter, 'same', 'circular'); 
        end
        
        %Choose a energy function
        function energyMap = energyFunction(obj, option)
            if option == 1
                energyMap = energyFunctionL1Norm(obj.xDerivative, obj.yDerivative);
            elseif option == 2
                energyMap = energyFunctionL2Norm(obj.xDerivative, obj.yDerivative);
            elseif option == 3
                energyMap = energyFunctionSecDeri(obj.xDerivative, obj.yDerivative);
            else
                %default L1 norm
                energyMap = energyFunctionL1Norm(obj.xDerivative, obj.yDerivative);
            end
        end
        %For test and debug
        function showVerticalSeam(obj)
            seam = verticalSeam(obj.energyMap);
            row = size(obj.image, 1);
            showImg = obj.image;
            for r = 1:row
                showImg(r, seam(r), 1) = 255;
            end
            imshow(showImg);
        end
        %For test and debug
        function showHorizontalSeam(obj)
            seam = horizontalSeam(obj.energyMap);
            col = size(obj.image, 2);
            showImg = obj.image;
            for c = 1:col
                showImg(seam(c), c, 1) = 255;
            end
            imshow(showImg);
        end
        
        function output = removeVerticalSeam(obj, image, seam)
            isize = size(image);
            if size(isize, 2) == 3 % RGB image
                output = uint8(zeros(isize(1), isize(2) - 1, 3));
                for i = 1:isize(1)
                    output(i, 1:seam(i)-1, 1:3) = image(i, 1:seam(i)-1, 1:3);
                    output(i, seam(i):end, 1:3) = image(i, seam(i)+1:end, 1:3);
                end
            else % gray image
                output = uint8(zeros(isize(1), isize(2) - 1));
                for i = 1:isize(1)
                    output(i, 1:seam(i)-1) = image(i, 1:seam(i)-1);
                    output(i, seam(i):end) = image(i, seam(i)+1:end);
                end
            end
        end
        
        function output = removeHorizontalSeam(obj, image, seam)
            isize = size(image);
            if size(isize, 2) == 3 % RGB image
                output = uint8(zeros(isize(1) - 1, isize(2), 3));
                for i = 1:isize(2)
                    output(1:seam(i)-1, i, 1:3) = image(1:seam(i)-1, i, 1:3);
                    output(seam(i):end, i, 1:3) = image(seam(i)+1:end, i, 1:3);
                end
            else % gray image
                output = uint8(zeros(isize(1) - 1, isize(2)));
                for i = 1:isize(2)
                    output(1:seam(i)-1, i) = image(1:seam(i)-1, i);
                    output(seam(i):end, i) = image(seam(i)+1:end, i);
                end
            end
        end
        
        function output = reduceWidth(obj, numPixels)
            
            changedImage = SeamCarvingImage(obj.image);
            changedImage.ENERGY_FUNCTION_OPTION = obj.ENERGY_FUNCTION_OPTION;
            for i = 1:numPixels
                seam = verticalSeam(changedImage.energyMap);
                changedImage.image = changedImage.removeVerticalSeam(changedImage.image, seam);
                changedImage = changedImage.init();
                
            end
            output = changedImage.image;
        end
        
        function output = reduceHeight(obj, numPixels)
            changedImage = SeamCarvingImage(obj.image);
            changedImage.ENERGY_FUNCTION_OPTION = obj.ENERGY_FUNCTION_OPTION;
            for i = 1:numPixels
                seam = horizontalSeam(changedImage.energyMap);
                changedImage.image = changedImage.removeHorizontalSeam(changedImage.image, seam);
                changedImage = changedImage.init();
                
            end
            output = changedImage.image;
        end
        
        function output = increaseHeight(obj, image, numPixels)
            row = size(image, 1);
            %Seam Carving paper section 4.4, since enlarging all seams equals scaling.
            %So we need to enlarge image several step, each step doesn't
            %more than a fraction of image size.
            piexlStep = int32(row * obj.FRACTION_ENLARGE_SETP);
            if numPixels > piexlStep;
                stepImage = obj.increaseHeightStep(image, piexlStep);
                output = obj.increaseHeight(stepImage, numPixels - piexlStep);
            else
                output = obj.increaseHeightStep(image, numPixels);
            end
        end
        
        function output = increaseWidth(obj, image, numPixels)
            col = size(image, 2);
            %Seam Carving paper section 4.4, since enlarging all seams equals scaling.
            %So we need to enlarge image several step, each step doesn't
            %more than a fraction of image size.
            piexlStep = int32(col * obj.FRACTION_ENLARGE_SETP);
            if numPixels > piexlStep;
                stepImage = obj.increaseWidthStep(image, piexlStep);
                output = obj.increaseWidth(stepImage, numPixels - piexlStep);
            else
                output = obj.increaseWidthStep(image, numPixels);
            end
        end
        
        function output = increaseHeightStep(obj, image, numPixels)
            %First choose numPixels seams for removal
            %Second dupicate piexls of those seams by avarage of top/bottom
            kseams = obj.chooseKHorizontalSeams(image, numPixels);

            row = size(image, 1);
            col = size(image, 2);
            
            image = double(image);
            isize = size(image);
            if size(isize, 2) == 3 %color image
                output = zeros(row + numPixels, col, 3);
                for c = 1:col
                    %colVector = image(1:end, c, 1:3);
                    rpos = 1;
                    for r = 1:row
                        if kseams(r, c) == 1
                            if r - 1 > 0
                                output(rpos, c, 1:3) = (image(r, c, 1:3) + image(r - 1, c, 1:3))/2;
                            else
                                output(rpos, c, 1:3) = image(r, c, 1:3);
                            end
                            
                            if r + 1 <= row
                                output(rpos + 1, c, 1:3) = (image(r, c, 1:3) + image(r + 1, c, 1:3))/2;
                            else
                                output(rpos + 1, c, 1:3) = image(r, c, 1:3);
                            end
                            rpos = rpos + 2;
                        else
                            output(rpos, c, 1:3) = image(r, c, 1:3);
                            rpos = rpos + 1;
                        end
                    end
                end
            else %gray image
                output = zeros(row + numPixels, col);
                for c = 1:col
                    %colVector = image(1:end, c);
                    rpos = 1;
                    for r = 1:row
                        if kseams(r, c) == 1
                            if r - 1 > 0
                                output(rpos, c) = (image(r, c) + image(r - 1, c))/2;
                            else
                                output(rpos, c) = image(r, c);
                            end
                            
                            if r + 1 <= row
                                output(rpos + 1, c) = (image(r, c) + image(r + 1, c))/2;
                            else
                                output(rpos + 1, c) = image(r, c);
                            end
                            rpos = rpos + 2;
                        else
                            output(rpos, c) = image(r, c);
                            rpos = rpos + 1;
                        end
                    end
                end
            end
            
            output = uint8(output);
        end
        
        function [kseams, changedImage] = chooseKHorizontalSeams(obj, image, k)
            row = size(image, 1);
            col = size(image, 2);
            kseams = zeros(row, col); %mark 1 if the piexl is chosen as piexl in k seams.
            
            changedImage = SeamCarvingImage(image);
           
            for i = 1:k
                seam = horizontalSeam(changedImage.energyMap);
                for c = 1:col
                    pos = seam(c);
                    colSum = sum(kseams(1:pos, c));
                    while pos - colSum < seam(c)
                        %pos = pos + seam(c) - (pos - solSum)
                        pos = seam(c) + colSum;
                        colSum = sum(kseams(1:pos, c));
                    end
                    kseams(pos, c) = 1;
                end
                changedImage.image = changedImage.removeHorizontalSeam(changedImage.image, seam);
                changedImage = changedImage.init(); 
            end
        end
            
        function output = increaseWidthStep(obj, image, numPixels)
            %First choose numPixels seams for removal
            %Second dupicate piexls of those seams by avarage of left/right
            kseams = obj.chooseKVerticalSeams(image, numPixels);
            
            row = size(image, 1);
            col = size(image, 2);
            
            image = double(image);
            isize = size(image);
            if size(isize, 2) == 3 %color image
                output = zeros(row, col + numPixels, 3);
                for r = 1:row
                    
                    cpos = 1;
                    for c = 1:col
                        if kseams(r, c) == 1
                            if c - 1 > 0
                                output(r, cpos, 1:3) = (image(r, c, 1:3) + image(r, c - 1, 1:3))/2;
                            else
                                output(r, cpos, 1:3) = image(r, c, 1:3);
                            end
                            
                            if c + 1 <= col
                                output(r, cpos + 1, 1:3) = (image(r, c, 1:3) + image(r, c + 1, 1:3))/2;
                            else
                                output(r, cpos + 1, 1:3) = image(r, c, 1:3);
                            end
                            cpos = cpos + 2;
                        else
                            output(r, cpos, 1:3) = image(r, c, 1:3);
                            cpos = cpos + 1;
                        end
                    end
                end
            else %gray image
                output = zeros(row, col + numPixels);
                
                for r = 1:row
                    cpos = 1;
                    for c = 1:col
                        if kseams(r, c) == 1
                            if c - 1 > 0
                                output(r, cpos) = (image(r, c) + image(r, c - 1))/2;
                            else
                                output(r, cpos) = image(r, c);
                            end
                            
                            if c + 1 <= col
                                output(r, cpos + 1) = (image(r, c) + image(r, c + 1))/2;
                            else
                                output(r, cpos + 1) = image(r, c);
                            end
                            cpos = cpos + 2;
                        else
                            output(r, cpos) = image(r, c);
                            cpos = cpos + 1;
                        end
                    end
                end
            end
            
            output = uint8(output);
        end
        
        function [kseams, changedImage] = chooseKVerticalSeams(obj, image, k)
            row = size(image, 1);
            col = size(image, 2);
            kseams = zeros(row, col); %mark 1 if the piexl is chosen as piexl in k seams.
            
            changedImage = SeamCarvingImage(image);
            
            for i = 1:k
                seam = verticalSeam(changedImage.energyMap);
                for r = 1:row
                    pos = seam(r);
                    colSum = sum(kseams(r, 1:pos));
                    while pos - colSum < seam(r)
                        %pos = pos + seam(c) - (pos - solSum)
                        pos = seam(r) + colSum;
                        colSum = sum(kseams(r, 1:pos));
                    end
                    kseams(r, pos) = 1;
                end
                changedImage.image = changedImage.removeVerticalSeam(changedImage.image, seam);
                changedImage = changedImage.init(); 
            end
        end
        
        function output = removeObject(obj)
            
            imshow(obj.image);
            handle = impoly;
            polygon = wait(handle);
            
            objectWidth = max(polygon(1:end, 1)) - min(polygon(1:end, 1)) + 1;
            objectHeight = max(polygon(1:end, 2)) - min(polygon(1:end, 2)) + 1;
            
            esize = size(obj.energyMap);
            removeMask = zeros(esize);
            for r = 1:esize(1)
                for c = 1:esize(2)
                    if inpolygon(c, r, polygon(1:end, 1), polygon(1:end, 2));
                        removeMask(r, c) = 1;
                    end
                end
            end
            
            if objectWidth <= objectHeight
                output = obj.removeObjectByReducingWidth(removeMask);
            else
                output = obj.removeObjectByReducingHeight(removeMask);
            end
        end
        
        function output = removeObjectByReducingHeight(obj, removeMask)
            changedImage = SeamCarvingImage(obj.image);
           
            while sum(sum(removeMask)) ~= 0
                changedImage.energyMap = changedImage.energyMap - obj.INF * removeMask;
                seam = horizontalSeam(changedImage.energyMap);
                changedImage.image = changedImage.removeHorizontalSeam(changedImage.image, seam);
                changedImage = changedImage.init();
                
                rsize = size(removeMask);
            
                for i = 1:rsize(2)
                    removeMask(1:seam(i)-1, i) = removeMask(1:seam(i)-1, i);
                    removeMask(seam(i):end-1, i) = removeMask(seam(i)+1:end, i);
                end
                removeMask = removeMask(1:end - 1, 1:end);
            end
            output = changedImage.image;
        end
        
        function output = removeObjectByReducingWidth(obj, removeMask)
            changedImage = SeamCarvingImage(obj.image);
           
            while sum(sum(removeMask)) ~= 0
                changedImage.energyMap = changedImage.energyMap - obj.INF * removeMask;
                seam = verticalSeam(changedImage.energyMap);
                changedImage.image = changedImage.removeVerticalSeam(changedImage.image, seam);
                changedImage = changedImage.init();
                
                rsize = size(removeMask);
            
                for i = 1:rsize(1)
                    removeMask(i, 1:seam(i)-1) = removeMask(i, 1:seam(i)-1);
                    removeMask(i, seam(i):end-1) = removeMask(i, seam(i)+1:end);
                end
                removeMask = removeMask(1:end, 1:end-1);
            end
            output = changedImage.image;
        end
    end
    
end

