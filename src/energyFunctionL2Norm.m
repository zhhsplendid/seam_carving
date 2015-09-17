function [output] = energyFunctionL2Norm(xDerivative, yDerivative)
    %L2 norm: output(i) = sqrt(xDerivative(i)^2 + yDerivative(i)^2)
    output = sqrt(xDerivative .* xDerivative + yDerivative .* yDerivative);
end


