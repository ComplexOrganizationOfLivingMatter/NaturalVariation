function [normzPosMinArray, zPosMinArray, normVariableDataArray, variableDataArray, xyPosArray, normXYPosArray, zPosCentroidArray, polarDistArray, polarDistrArray] = getCellSpatialData(labelledImage, data, cellIDArray, variable, pixelScale)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % getCellSpatialData
    % Function that joins cell's variable info with cell's Z and XY Position
    % Current use of this function is to get polar coordinates and
    % the variable value of each cell
    % THIS FUNCTION IS INTENDED TO BE LAUNCHED USING THE HOMONIMOUS _UI FILE!
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % inputs:
    % labelledImage: labels
    % data: column of values of the chosen variable
    % cellIDArray: IDs of all cells
    % variable: Name of the variable e.g. "cell_height"
    % pixelScale: pixelScale for pixelToMicron Conversion

	%Initialize variables    
    variableDataArray = [];
    normVariableDataArray = [];
    zPosArray = [];
    normZPosArray = [];
    xyPosArray = [];
    zPosCentroid = [];
    polarDistArray = [];
    polarDistrArray = [];
    
    %Get cyst centroid, min centroid Zpos and max centroid Zpos
    cystCentroids = regionprops3(labelledImage, 'Centroid');
    minCystCentroids = min(cystCentroids.Centroid(:, 3));
    maxCystCentroids = max(cystCentroids.Centroid(:, 3));
    
    %Get centroid of each cells
    cystCentroid = regionprops3(labelledImage>0, 'Centroid');
    xyCentroid = [cystCentroid.Centroid(1), cystCentroid.Centroid(2)];
    zCentroid = [cystCentroid.Centroid(3)];

	%xy position of the centroid of each cell
    xydots = [cystCentroids.Centroid(:, 1),cystCentroids.Centroid(:, 2)];
    
    %get distance (xy-plane) to cyst centroid
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
        
        %polar distance (i.e. radius)
        polarDist = pdist2([xyCentroid(1), xyCentroid(2), zCentroid], [centroidPos(1), centroidPos(2), centroidPos(3)]);
        
        %polar distribution (i.e. theta)
        polarDistr = atan((centroidZPos-zCentroid)/pdist2(xyCentroid, xyPos));
        
        %get variable data
        variableValue = data(cellIx);
        
        %add to list
        variableDataArray = [variableDataArray, variableValue];
        zPosArray = [zPosArray, centroidZPos];
        xyPosArray = [xyPosArray, pdist2(xyCentroid, xyPos)];
        
        polarDistArray = [polarDistArray, polarDist];
        polarDistrArray = [polarDistrArray, polarDistr];

    end
    
    %Norm variable data between min and max value
    normVariableDataArray = (variableDataArray-min(variableDataArray))./(max(variableDataArray)-min(variableDataArray));
    %Norm Zpos data between min and max value
    normzPosMinArray = (zPosArray-min(zPosArray))./(max(zPosArray)-min(zPosArray));
    %norm Zpos data referred to the cyst centroid
    zPosCentroidArray = zPosArray-zCentroid;
    %Norm Zpos data referred to the min Zpos
    zPosMinArray = zPosArray-min(zPosArray);
    %Norm XYPos data referred to the min/max centroid distance
    normXYPosArray = (xyPosArray-min(centroidDistances))./(max(centroidDistances)-min(centroidDistances));
    
    %Norm polar distance referred to the max polar distance
    polarDistArray = polarDistArray/max(polarDistArray);
    
    %pixels to microns
    zPosCentroidArray = convertPixelsToMicrons_singleVariable(zPosCentroidArray, 'height', pixelScale);
    zPosMinArray = convertPixelsToMicrons_singleVariable(zPosMinArray, 'height', pixelScale);
    xyPosArray = convertPixelsToMicrons_singleVariable(xyPosArray, 'height', pixelScale);
end
