function [normFirstQuartilePosition, normSecondQuartilePosition, normThirdQuartilePosition, normFourthQuartilePosition] = getCellSpatialStatistics(labelledImage, data, cellIDArray, variable)
    
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
    firstQuantile = quantile(data, 0.25);
    secondQuantile = quantile(data, 0.5);
    thirdQuantile = quantile(data, 0.75);
        
    for cellIx = 1:size(data, 1)
        cellID = cellIDArray(cellIx);
        cellID = cellID{1};
        cellID = strsplit(cellID, '_');
        cellID = cellID{2};
        cellID = str2num(cellID);
        
        centroidPos = regionprops3(labelledImage == cellID, 'Centroid');
        centroidPos = centroidPos.Centroid;
        centroidPos = centroidPos(3);
        
        variableValue = data(cellIx);
        
        if strcmp(variable, "scutoids")
            if variableValue==1
                firstQuartilePosArray = [firstQuartilePosArray, centroidPos];
                secondQuartilePosArray = [secondQuartilePosArray, centroidPos];
                thirdQuartilePosArray = [thirdQuartilePosArray, centroidPos];
                fourthQuartilePosArray = [fourthQuartilePosArray, centroidPos];
            end
        else

            if variableValue<=firstQuantile
                firstQuartilePosArray = [firstQuartilePosArray, centroidPos];
            elseif (firstQuantile<variableValue) && (variableValue<=secondQuantile)
                secondQuartilePosArray = [secondQuartilePosArray, centroidPos];
            elseif (secondQuantile<variableValue) && (variableValue<=thirdQuantile)
                thirdQuartilePosArray = [thirdQuartilePosArray, centroidPos];
            elseif thirdQuantile<variableValue
                fourthQuartilePosArray = [fourthQuartilePosArray, centroidPos];
            end
        end
        
        variableArray = [variableArray, variableValue];
    end
    
    normFirstQuartilePosition = median((firstQuartilePosArray-minCystCentroids)./(maxCystCentroids-minCystCentroids));
    normSecondQuartilePosition = median((secondQuartilePosArray-minCystCentroids)./(maxCystCentroids-minCystCentroids));
    normThirdQuartilePosition = median((thirdQuartilePosArray-minCystCentroids)./(maxCystCentroids-minCystCentroids));
    normFourthQuartilePosition = median((fourthQuartilePosArray-minCystCentroids)./(maxCystCentroids-minCystCentroids));
    
    
end
