function [rg, cellOutlierId] = tagCellOutliers(rg, labelledImage)
    

    uniqueCells = unique(labelledImage);
    uniqueCells(uniqueCells==0 | uniqueCells==1) = [];
    brokenCells = [];
    cellsVolume = [];
    cellsId = [];
    for i=1:length(uniqueCells)
        singleCell = bwlabeln(labelledImage==uniqueCells(i));
        singleCellVolume = regionprops3(singleCell, 'Volume');
        if length(singleCellVolume.Volume)>1
            brokenCells = [brokenCells, uniqueCells(i)];
        end
        cellsVolume = [cellsVolume, singleCellVolume.Volume(1)];
        cellsId = [cellsId, uniqueCells(i)];
    end
    
    cellOutlier = isoutlier(cellsVolume);
    cellOutlierId = cellsId(cellOutlier); 
     
    
    for i=1:length(cellOutlierId)
        actualImg = bwlabeln(labelledImage==cellOutlierId(i));
        centroid = regionprops3(actualImg, 'Centroid');
        if size(centroid.Centroid, 1)>1
            warning('%s label identifies more than one cell\n', cells(indexCell));
            for centroidIndex = 1:size(centroid.Centroid, 1)
                rgSlice = rg(:, :, round(centroid.Centroid(centroidIndex, 3)));
                rgSlice = insertText(rgSlice, [round(centroid.Centroid(centroidIndex, 1)), round(centroid.Centroid(centroidIndex, 2))], num2str(cells(indexCell)), 'TextColor', 'black', 'FontSize', 6, 'AnchorPoint', 'Center');
                rg(:, :, round(centroid.Centroid(centroidIndex, 3))) = rgSlice(:, :, 1);
            end
        else
            rgSlice = rg(:, :, round(centroid.Centroid(3)));
            rgSlice = insertText(rgSlice/255, [round(centroid.Centroid(1)), round(centroid.Centroid(2))], num2str(cellOutlierId(i)), 'TextColor', 'black', 'FontSize', 6, 'AnchorPoint', 'Center');
            rg(:, :, round(centroid.Centroid(3))) = rgSlice(:, :, 1)*255;
        end
    end
    
end