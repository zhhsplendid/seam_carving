%For question 2
function Part2(sectionVector)
    
    im1 = imread('../input_images/im1.jpg');
    im2 = imread('../input_images/im2.jpg');
    im3 = imread('../input_images/im3.jpg');
    im4 = imread('../input_images/im4.jpg');
    im5 = imread('../input_images/im5.jpg');
    
    for i = sectionVector
        if i == 1
            standardOutputReduceHeight(im1, 100, '../output_images/2.1/im1_rh_100');
            standardOutputReduceWidth(im2, 100, '../output_images/2.1/im2_rw_100');
            
        elseif i == 2
            c1 = SeamCarvingImage(im1);

            [seamH, cumulativeMinEnergyH] = horizontalSeam( c1.energyMap );
            [seamV, cumulativeMinEnergyV] = verticalSeam( c1.energyMap );
            
            imagesc(c1.energyMap);
            title('im1.jpg, Energy of Pixels');
            input('input anything to continue');
            
            imagesc(cumulativeMinEnergyH);
            title('im1.jpg, Horizontal Cumulative Energy');
            input('input anything to continue');
            
            imagesc(cumulativeMinEnergyV);
            title('im1.jpg, Vertical Cumulative Energy');
            input('input anything to continue');
        elseif i == 3
            %2.3
            c1 = SeamCarvingImage(im1);

            [seamH, cumulativeMinEnergyH] = horizontalSeam( c1.energyMap );
            [seamV, cumulativeMinEnergyV] = verticalSeam( c1.energyMap );
            
            row = size(im1, 1);
            col = size(im1, 2);
            changedImage = im1;
            for r = 1:row
                changedImage(r, seamV(r), 1) = 255;
                changedImage(r, seamV(r), 2) = 0;
                changedImage(r, seamV(r), 3) = 0;
            end

            for c = 1:col
                changedImage(seamH(c), c, 1) = 255;
                changedImage(seamH(c), c, 2) = 0;
                changedImage(seamH(c), c, 3) = 0;
            end
            imwrite(changedImage, '../output_images/2.3/im1_first_HV_seam.jpg');
        elseif i == 4
            c1 = SeamCarvingImage(im2);
            c1.ENERGY_FUNCTION_OPTION = 1;
            c1.init();
            imgDiffEng = c1.reduceWidth(100);
            imwrite(imgDiffEng, '../output_images/2.4/im2_rw_diff_energy_1.jpg');

            c1.ENERGY_FUNCTION_OPTION = 3;
            c1.init();
            imgDiffEng = c1.reduceWidth(100);
            imwrite(imgDiffEng, '../output_images/2.4/im2_rw_diff_energy_2.jpg');
        elseif i == 5
            standardOutputReduceHeight(im1, 50, '../output_images/2.5/im1_rh_50');
            standardOutputReduceHeight(im2, 50, '../output_images/2.5/im2_rh_50');
            standardOutputReduceWidth(im3, 200, '../output_images/2.5/im3_rw_200');
            standardOutputReduceWidth(im4, 300, '../output_images/2.5/im4_rw_300');
            standardOutputReduceWidth(im5, 75, '../output_images/2.5/im5_rw_75');
            
        else
            ['No this section']
        end
        
    end

end
