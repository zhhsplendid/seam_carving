function seam = verticalSeam( energyMap )
    %Dynamical programming
    row = size(energyMap, 1);
    col = size(energyMap, 2);
    
    cumulativeMinEnergy = zeros(row, col);
    
    %initial
    for c = 1:col
        cumulativeMinEnergy(1, c) = energyMap(1, c); 
    end
    
    %cumulativeMinEnergy --- CME(r, c) = energyMap(r, c) + min( CME(r - 1, c), CME(r - 1, c - 1), CME(r - 1, c + 1) )
    for r = 2:row
        for c = 1:col
            cumulativeMinEnergy(r, c) = cumulativeMinEnergy(r - 1, c);
            if c - 1 > 0;
                cumulativeMinEnergy(r, c) = min(cumulativeMinEnergy(r, c), cumulativeMinEnergy(r - 1, c - 1));
            end
            if c + 1 <= col
                cumulativeMinEnergy(r, c) = min(cumulativeMinEnergy(r, c), cumulativeMinEnergy(r - 1, c + 1));
            end
            cumulativeMinEnergy(r, c) = cumulativeMinEnergy(r, c) + energyMap(r, c);
        end
    end
  
    minValue = cumulativeMinEnergy(row, 1);
    minPos = 1;
    for c = 2:col
        if cumulativeMinEnergy(row, c) < minValue;
            minValue = cumulativeMinEnergy(row, c);
            minPos = c;
        end
    end
    
    seam = zeros(row, 1);
    seam(row) = minPos;
    for r = (row - 1):-1:1
        minPos = seam(r+1);
        minValue = cumulativeMinEnergy(r, minPos);
        if seam(r+1) - 1 > 0 && cumulativeMinEnergy(r, seam(r+1) - 1) < minValue
            minPos = seam(r+1) - 1;
            minValue = cumulativeMinEnergy(r, minPos);
        end
        
        if seam(r+1) + 1 <= col && cumulativeMinEnergy(r, seam(r+1) + 1) < minValue
            minPos = seam(r+1) + 1;
            minValue = cumulativeMinEnergy(r, minPos);
        end
        seam(r) = minPos;
    end
end

