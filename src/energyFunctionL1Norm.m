function [output] = energyFunctionL1Norm(xDerivative, yDerivative)
    %L1 norm: output(i) = |xDerivative(i)| + |yDerivative(i)|
    output = abs(xDerivative) + abs(yDerivative);
end

