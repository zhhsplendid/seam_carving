function seam = horizontalSeam( energyMap )
    %Dynamical programming
    row = size(energyMap, 1);
    col = size(energyMap, 2);
    
    cumulativeMinEnergy = zeros(row, col);
    
    %initial
    for r = 1:row
        cumulativeMinEnergy(r, 1) = energyMap(r, 1); 
    end
    
    %cumulativeMinEnergy --- CME(r, c) = energyMap(r, c) + min( CME(r, c - 1), CME(r - 1, c - 1), CME(r + 1, c - 1) )
    for c = 2:col
        for r = 1:row
            cumulativeMinEnergy(r, c) = cumulativeMinEnergy(r, c - 1);
            if r - 1 > 0;
                cumulativeMinEnergy(r, c) = min(cumulativeMinEnergy(r, c), cumulativeMinEnergy(r - 1, c - 1));
            end
            if r + 1 <= row
                cumulativeMinEnergy(r, c) = min(cumulativeMinEnergy(r, c), cumulativeMinEnergy(r + 1, c - 1));
            end
            cumulativeMinEnergy(r, c) = cumulativeMinEnergy(r, c) + energyMap(r, c);
        end
    end
  
    minValue = cumulativeMinEnergy(row, 1);
    minPos = 1;
    for r = 2:row
        if cumulativeMinEnergy(r, col) < minValue;
            minValue = cumulativeMinEnergy(r, col);
            minPos = r;
        end
    end
    
    seam = zeros(1, col);
    seam(col) = minPos;
    for c = (col - 1):-1:1
        minPos = seam(c+1);
        minValue = cumulativeMinEnergy(minPos, c);
        if seam(c+1) - 1 > 0 && cumulativeMinEnergy(seam(c+1) - 1, c) < minValue
            minPos = seam(c+1) - 1;
            minValue = cumulativeMinEnergy(minPos, c);
        end
        
        if seam(c+1) + 1 <= row && cumulativeMinEnergy(seam(c+1) + 1, c) < minValue
            minPos = seam(c+1) + 1;
            minValue = cumulativeMinEnergy(minPos, c);
        end
        seam(c) = minPos;
    end
end

