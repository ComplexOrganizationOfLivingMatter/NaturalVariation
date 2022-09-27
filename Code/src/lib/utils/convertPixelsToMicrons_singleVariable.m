function variableData = convertPixelsToMicrons_singleVariable(variableData, variableType, pixelScale)
    %Convert pixels to microns specifying data, type of variable and pixel scale
    
    if strcmp(variableType, 'volume')
        variableData = variableData*pixelScale^3;
    elseif strcmp(variableType, 'area')
        variableData = variableData*pixelScale^2;
    elseif strcmp(variableType, 'length')
        variableData = variableData*pixelScale;
    elseif strcmp(variableType, 'height')
        variableData = variableData*pixelScale;

end
