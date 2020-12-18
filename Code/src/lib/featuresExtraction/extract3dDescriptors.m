function [cells3dFeatures] = extract3dDescriptors(labelledImage, validCells)
%EXTRACT3DDESCRIPTORS Summary of this function goes here
%   Detailed explanation goes here
cells3dFeatures=[];
for indexCell= 1: max(labelledImage(:))   
    oneCell3dFeatures = regionprops3(labelledImage==indexCell, 'PrincipalAxisLength', 'Volume', 'ConvexVolume', 'Solidity', 'SurfaceArea', 'EquivDiameter');
    if size(oneCell3dFeatures, 1) > 0
        indMax = 1;
        if size(oneCell3dFeatures, 1) > 1
            [~,indMax] = max(oneCell3dFeatures.Volume);
            oneCell3dFeatures = oneCell3dFeatures(indMax,:);
        end
        actualImg = bwlabeln(labelledImage==indexCell);
        [x, y, z] = ind2sub(size(labelledImage), find(actualImg==indMax));
        [~, convexVolume] = convhull(x, y, z);
        oneCell3dFeatures.ConvexVolume = convexVolume;
        oneCell3dFeatures.Solidity = sum(actualImg(:)==indMax) / convexVolume;
        aspectRatio = max(oneCell3dFeatures.PrincipalAxisLength,[],2) ./ min(oneCell3dFeatures.PrincipalAxisLength,[],2);
        sphereArea = 4 * pi .* ((oneCell3dFeatures.EquivDiameter) ./ 2) .^ 2;
        sphericity = sphereArea ./ oneCell3dFeatures.SurfaceArea;
        normalizedVolume = oneCell3dFeatures.Volume;
        irregularityShapeIndex = sqrt(oneCell3dFeatures.SurfaceArea)./(oneCell3dFeatures.SurfaceArea.^(1/3));
        cells3dFeatures = [cells3dFeatures; horzcat(oneCell3dFeatures, table(aspectRatio, sphericity, normalizedVolume,irregularityShapeIndex))];
    else
        badOneCell = cells3dFeatures(end, :);
       	badOneCell.PrincipalAxisLength(1,1:3) = -1;
        badOneCell.Volume = -1;
        badOneCell.aspectRatio = -1;
        badOneCell.ConvexVolume = -1;
        badOneCell.EquivDiameter = -1;
        badOneCell.Solidity = -1;
        badOneCell.normalizedVolume = -1;
        badOneCell.sphericity = -1;
        badOneCell.SurfaceArea = -1;
        badOneCell.Volume = -1;
        badOneCell.IrregularityShapeIndex =-1;
        cells3dFeatures = [cells3dFeatures; badOneCell];
    end
end
cells3dFeatures.normalizedVolume = arrayfun(@(x) x/mean(cells3dFeatures.Volume), cells3dFeatures.normalizedVolume);

columnIDs = table('Size', size(validCells), 'VariableTypes', {'string'});
columnIDs.Properties.VariableNames = {'ID_Cell'};
columnIDs.ID_Cell = arrayfun(@(x) strcat('cell_', num2str(x)), validCells, 'UniformOutput', false);
cells3dFeatures = horzcat(columnIDs, cells3dFeatures(validCells,:));
end

