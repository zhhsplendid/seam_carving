function output = energyFunctionSecDeri(xDerivative, yDerivative)
    filter = [-1, 0, 1];
    xSecDeri = imfilter(xDerivative, filter, 'same', 'circular');
    ySecDeri = imfilter(yDerivative, filter', 'same', 'circular');
    output = abs(xSecDeri) + abs(ySecDeri);
end

