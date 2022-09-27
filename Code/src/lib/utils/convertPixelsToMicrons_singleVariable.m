function variableData = convertPixelsToMicrons_singleVariable(variableData, variableType, pixelScale)
    %UNTITLED Summary of this function goes here
    %   Detailed explanation goes here
    
    if strcmp(variableType, 'volume')
        variableData = variableData*pixelScale^3;
    elseif strcmp(variableType, 'area')
        variableData = variableData*pixelScale^2;
    elseif strcmp(variableType, 'length')
        variableData = variableData*pixelScale;
    elseif strcmp(variableType, 'height')
        variableData = variableData*pixelScale;

end
