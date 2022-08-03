function [normzPosMinArray, zPosMinArray, normVariableDataArray, variableDataArray, xyPosArray, normXYPosArray, zPosCentroidArray] = getCellSpatialData(labelledImage, data, cellIDArray, variable, pixelScale)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % getCellSpatialData
    % Function that joins cell's variable info with cell's Z and XY Position
    % THIS FUNCTION IS INTENDED TO BE LAUNCHED USING THE HOMONIMOUS _UI FILE!
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % inputs:
    % labelledImage: labels
    % data: column of values of the chosen variable
    % cellIDArray: IDs of all cells
    % variable: Name of the variable e.g. "cell_height"
    % pixelScale: pixelScale for pixelToMicron Conversion
    
    % Initialize variables
    variableDataArray = [];
    normVariableDataArray = [];
    zPosArray = [];
    normZPosArray = [];
    xyPosArray = [];
    zPosCentroid = [];
    
    % get all centroids to calculate min and max of Z Position
    cystCentroids = regionprops3(labelledImage, 'Centroid');
    minCystCentroids = min(cystCentroids.Centroid(:, 3));
    maxCystCentroids = max(cystCentroids.Centroid(:, 3));
    
    % get cyst centroid (both XY and Z)
    cystCentroid = regionprops3(labelledImage>0, 'Centroid');
    xyCentroid = [cystCentroid.Centroid(1), cystCentroid.Centroid(2)];
    zCentroid = [cystCentroid.Centroid(3)];

    % get all XY centroids position
    xydots = [cystCentroids.Centroid(:, 1),cystCentroids.Centroid(:, 2)];
    
    centroidDistances = pdist2(xyCentroid, xydots);
            
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
        centroidZPos = centroidPos(3);
        xyPos = [centroidPos(1), centroidPos(2)];
        
        variableValue = data(cellIx);
        
        % append variable value, Z position and XY Position
        variableDataArray = [variableDataArray, variableValue];
        zPosArray = [zPosArray, centroidZPos];
        xyPosArray = [xyPosArray, pdist2(xyCentroid, xyPos)];
    end
    % Normalize variable data
    normVariableDataArray = (variableDataArray-min(variableDataArray))./(max(variableDataArray)-min(variableDataArray));
    % Normalize Z Position taking lowest centroid as the base of the cyst (floor)
    normzPosMinArray = (zPosArray-min(zPosArray))./(max(zPosArray)-min(zPosArray));
    % Z distance to the cystZCentroid
    zPosCentroidArray = zPosArray-zCentroid;
    % Z distance to the lowest centroid
    zPosMinArray = zPosArray-min(zPosArray);
    % XY Distance to the XY Cyst Centroid Position
    normXYPosArray = (xyPosArray-min(centroidDistances))./(max(centroidDistances)-min(centroidDistances));

    % Convert to microns
    zPosCentroidArray = convertPixelsToMicrons_singleVariable(zPosCentroidArray, 'height', pixelScale);
    zPosMinArray = convertPixelsToMicrons_singleVariable(zPosMinArray, 'height', pixelScale);
    xyPosArray = convertPixelsToMicrons_singleVariable(xyPosArray, 'height', pixelScale);
end
