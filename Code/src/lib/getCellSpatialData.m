function [normzPosArray, zPosArray, normVariableDataArray, variableDataArray] = getCellSpatialData(labelledImage, data, cellIDArray, variable, pixelScale)
    
    % Position
    variableDataArray = [];
    normVariableDataArray = [];
    zPosArray = [];
    normZPosArray = [];
    cystCentroids = regionprops3(labelledImage, 'Centroid');
    minCystCentroids = min(cystCentroids.Centroid(:, 3));
    maxCystCentroids = max(cystCentroids.Centroid(:, 3));
        
    for cellIx = 1:size(data, 1)
        % get cell id
        cellID = cellIDArray(cellIx);
        cellID = cellID{1};
        cellID = strsplit(cellID, '_');
        cellID = cellID{2};
        cellID = str2num(cellID);
        
        % get centroids
        centroidPos = regionprops3(labelledImage == cellID, 'Centroid');
        centroidPos = centroidPos.Centroid;
        centroidPos = centroidPos(3);
        
        variableValue = data(cellIx);
        
        variableDataArray = [variableDataArray, variableValue];
        zPosArray = [zPosArray, centroidPos];
    end
    
    normVariableDataArray = (variableDataArray-min(variableDataArray))./(max(variableDataArray)-min(variableDataArray));
    normzPosArray = (zPosArray-min(zPosArray))./(max(zPosArray)-min(zPosArray));
    zPosArray = zPosArray-min(zPosArray);

    zPosArray = convertPixelsToMicrons_singleVariable(zPosArray, 'height', pixelScale);
    
end