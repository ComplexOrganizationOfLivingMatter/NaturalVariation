function [labelledImage] = smoothObject(labelledImage,pixelLocations, numCell)
%SMOOTHOBJECT Summary of this function goes here
%   Detailed explanation goes here
    cellShape = alphaShape(pixelLocations);
    pc = criticalAlpha(cellShape,'one-region');
    cellShape.Alpha = pc;
    
%     figure
%     for numPoint = 1:size(pixelLocations, 1)
%         plot3(pixelLocations(numPoint, 1), pixelLocations(numPoint, 2), pixelLocations(numPoint, 3), '*')
%         
%         hold on;
%     end
%     plot(cellShape)
    
    [qx,qy,qz]=ind2sub(size(labelledImage),find(labelledImage == 0));
    actualCell = zeros(size(labelledImage));
    if numCell == -1
        lumenImage = 1;
        numCell = 1;
    else
        lumenImage = 0;
    end
    
    try
        tf = inShape(cellShape,qx,qy,qz);
        inCellIndices = sub2ind(size(labelledImage), qx(tf), qy(tf), qz(tf));
        actualCell(inCellIndices) = 1;
        actualCell(labelledImage == numCell) = 1;
%         actualCell = imdilate(actualCell, strel('sphere', 2));
        filledCell = imfill(double(actualCell),  4, 'holes');
%         filledCell = imerode(filledCell, strel('sphere', 2));
        filledCell = double(filledCell);
        if lumenImage
            filledCellOpen = imopen(filledCell, strel('sphere', 2));
        else
            filledCellOpen = filledCell;
        end
        labelledImage(filledCellOpen>0) = numCell;
        
%         coordZ = 25;
%         figure; imshow(actualCell(:, :, coordZ))
%         hold on;
%         coordinatesActualZ = find(pixelLocations(:, 3) == coordZ);
%         for numPoint = coordinatesActualZ
%             plot(pixelLocations(numPoint, 2), pixelLocations(numPoint, 1), 'r*');
%         end
        %labelledImage(filledCell) = numCell;
    catch ex
        ex.rethrow();
    end
end

