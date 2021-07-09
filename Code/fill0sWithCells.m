function [labelMask] = fill0sWithCells(labelMask, img3dComplete, invalidRegion)
%FILL0SWITHCELLS Fill the empty space belonging to the gland with cells
%   LimeSeg output may have created artificial spaces between cells that we
%   know they don't exist. Therefore, we will fill these spaces (0s within the
%   gland, not outside) with the ID of the cell closest to each space.

    missingRegions = labelMask == 0 & invalidRegion == 0;
    labelMask(missingRegions) = img3dComplete(missingRegions);

    missingRegions = labelMask == 0 & invalidRegion == 0;
    edgePixels = find(missingRegions);
    if isempty(edgePixels) == 0
        [xEdge, yEdge, zEdge] = ind2sub(size(labelMask), edgePixels);
        pixelsIndices = find((double(imdilate(missingRegions, strel('sphere', 4))).*double(labelMask))>0);
        [x, y, z] = ind2sub(size(labelMask), pixelsIndices);

        %% Splitting calculation to perform it in batches
        numPartitions = 100;
        indices = cell(numPartitions, 1);
        distances = cell(numPartitions, 1);
        partialPxs = floor(length(x)/numPartitions);
        if partialPxs ~= 0
            for nPart = 1 : numPartitions
                subIndCoord = (1 + (nPart-1) * partialPxs) : (nPart * partialPxs);
                if nPart == numPartitions
                    subIndCoord = (1 + (nPart-1) * partialPxs) : length(x);
                end
                [distances{nPart}, indices_nPart] = pdist2([x(subIndCoord), y(subIndCoord), z(subIndCoord)], [xEdge, yEdge, zEdge], 'euclidean', 'Smallest', 1);
                indices{nPart} = subIndCoord(indices_nPart);
            end
            distances_all = vertcat(distances{:});
            indices_all = vertcat(indices{:});
        else
            [distances_all, indices_all] = pdist2([x, y, z], [xEdge, yEdge, zEdge], 'euclidean', 'Smallest', 1);
        end
        
        
        if size(distances_all,1)==1
            indices_Partitions = indices_all;
            for numEdgePixel = 1:length(indices_Partitions)
                labelMask(edgePixels(numEdgePixel)) = labelMask(pixelsIndices(indices_Partitions(numEdgePixel)));
            end
        else
            [~, indices_Partitions] = min(distances_all);
            for numEdgePixel = 1:length(indices_Partitions)
                labelMask(edgePixels(numEdgePixel)) = labelMask(pixelsIndices(indices_all(indices_Partitions(numEdgePixel), numEdgePixel)));
            end
        end
    end
    %figure; paint3D(labelMask);
end

