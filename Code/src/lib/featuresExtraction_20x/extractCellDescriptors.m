function [cells3dFeatures] = extractCellDescriptors(labelledImage, validCells)
%EXTRACT3DDESCRIPTORS Summary of this function goes here
%   Detailed explanation goes here
cells3dFeatures=[];

for indexCell = 1:length(validCells)
    actualImg = bwlabeln(labelledImage==validCells(indexCell));
    oneCell3dFeatures = regionprops3(actualImg, 'PrincipalAxisLength', 'Volume', 'Centroid');
    if size(oneCell3dFeatures, 1) > 0
    indMax = 1;
        if size(oneCell3dFeatures, 1) > 1
            [~,indMax] = max(oneCell3dFeatures.Volume);
            oneCell3dFeatures = oneCell3dFeatures(indMax,:);
        end
        cells3dFeatures = [cells3dFeatures; oneCell3dFeatures];
    end
end
columnIDs = table('Size', size([validCells(:)]), 'VariableTypes', {'string'});
columnIDs.Properties.VariableNames = {'ID_Cell'};
columnIDs.ID_Cell = arrayfun(@(x) strcat('cell_', num2str(x)), [validCells(:)], 'UniformOutput', false);
cells3dFeatures = horzcat(columnIDs, cells3dFeatures);
end

