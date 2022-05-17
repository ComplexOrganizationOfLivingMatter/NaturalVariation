function [normFirstQuartilePosition, normSecondQuartilePosition, normThirdQuartilePosition, normFourthQuartilePosition] = getCellSpatialStatistics(labelledImage, cells3dFeatures, variable)
    
    % Position
    variableArray = [];
    firstQuartilePosArray = [];
    secondQuartilePosArray = [];
    thirdQuartilePosArray = [];
    fourthQuartilePosArray = [];

    cystCentroids = regionprops3(labelledImage, 'Centroid');
    minCystCentroids = min(cystCentroids.Centroid(:, 3));
    maxCystCentroids = max(cystCentroids.Centroid(:, 3));
    
    % Quartile splitting
    firstQuantile = quantile(cells3dFeatures(:, variable).Variables, 0.25);
    secondQuantile = quantile(cells3dFeatures(:, variable).Variables, 0.5);
    thirdQuantile = quantile(cells3dFeatures(:, variable).Variables, 0.75);
        
    for cellIx = 1:size(cells3dFeatures, 1)
        cellID = cells3dFeatures.ID_Cell(cellIx);
        cellID = cellID{1};
        cellID = strsplit(cellID, '_');
        cellID = cellID{2};
        cellID = str2num(cellID);
        
        centroidPos = regionprops3(labelledImage == cellID, 'Centroid');
        centroidPos = centroidPos.Centroid;
        centroidPos = centroidPos(3);
        
        variableValue = cells3dFeatures(cellIx, variable).Variables;
        
        if variableValue<=firstQuantile
            firstQuartilePosArray = [firstQuartilePosArray, centroidPos];
        elseif (firstQuantile<variableValue) && (variableValue<=secondQuantile)
            secondQuartilePosArray = [secondQuartilePosArray, centroidPos];
        elseif (secondQuantile<variableValue) && (variableValue<=thirdQuantile)
            thirdQuartilePosArray = [thirdQuartilePosArray, centroidPos];
        elseif thirdQuantile<variableValue
            fourthQuartilePosArray = [fourthQuartilePosArray, centroidPos];
        end
        
        variableArray = [variableArray, variableValue];
    end
    
    normFirstQuartilePosition = median((firstQuartilePosArray-minCystCentroids)./(maxCystCentroids-minCystCentroids));
    normSecondQuartilePosition = median((secondQuartilePosArray-minCystCentroids)./(maxCystCentroids-minCystCentroids));
    normThirdQuartilePosition = median((thirdQuartilePosArray-minCystCentroids)./(maxCystCentroids-minCystCentroids));
    normFourthQuartilePosition = median((fourthQuartilePosArray-minCystCentroids)./(maxCystCentroids-minCystCentroids));
    
    
end