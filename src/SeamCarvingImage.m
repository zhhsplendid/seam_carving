classdef SeamCarvingImage
    %This class reads a image and performs seam carving functions
    
    properties
        ENERGY_FUNCTION_OPTION = 1;
        
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
                output = uint8(zeros(iszie(1), isize(2) - 1));
                for i = 1:isize(1)
                    output(i, 1:end) = [image(i, 1:seam(i)-1), image(i, seam(i)+1:end)];
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
                output = uint8(zeros(iszie(1) - 1, isize(2)));
                for i = 1:isize(2)
                    output(1:end, i) = [image(1:seam(i)-1, i), image(seam(i)+1:end, i)];
                end
            end
        end
        
        function output = reduceWidth(obj, numPixels)
            
            changedImage = SeamCarvingImage(obj.image);
           
            for i = 1:numPixels
                seam = verticalSeam(changedImage.energyMap);
                changedImage.image = changedImage.removeVerticalSeam(changedImage.image, seam);
                changedImage = changedImage.init();
                
            end
            output = changedImage.image;
        end
        
        function output = reduceHeight(obj, numPixels)
            changedImage = SeamCarvingImage(obj.image);
           
            for i = 1:numPixels
                seam = horizontalSeam(changedImage.energyMap);
                changedImage.image = changedImage.removeHorizontalSeam(changedImage.image, seam);
                changedImage = changedImage.init();
                
            end
            output = changedImage.image;
        end
    end
    
end

