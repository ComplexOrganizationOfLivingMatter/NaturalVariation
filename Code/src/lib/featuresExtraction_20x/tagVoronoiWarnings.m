function [binaryHollowTissue] = tagVoronoiWarnings(binaryHollowTissue, lumenImage, croppedStardistImgRelabel, labelledImage, warningCyst)
    
    
    if ~isempty(warningCyst{3})
        %Get the cells that are making trouble
        cells = str2num(warningCyst{3});

        for indexCell = 1:length(cells)
            actualImg = bwlabeln(labelledImage==cells(indexCell));
            centroid = regionprops3(actualImg, 'Centroid');
            if size(centroid.Centroid, 1)>1
                warning('%s label identifies more than one cell\n', cells(indexCell));
                for centroidIndex = 1:size(centroid.Centroid, 1)
                    binaryHollowTissueSlice = binaryHollowTissue(:, :, round(centroid.Centroid(centroidIndex, 3)));
                    binaryHollowTissueSlice = insertText(binaryHollowTissueSlice, [round(centroid.Centroid(centroidIndex, 1)), round(centroid.Centroid(centroidIndex, 2))], num2str(cells(indexCell)), 'TextColor', 'black', 'FontSize', 6, 'AnchorPoint', 'Center');
                    binaryHollowTissue(:, :, round(centroid.Centroid(centroidIndex, 3))) = binaryHollowTissueSlice(:, :, 1);
                end
            else
                binaryHollowTissueSlice = binaryHollowTissue(:, :, round(centroid.Centroid(3)));
                binaryHollowTissueSlice = insertText(binaryHollowTissueSlice, [round(centroid.Centroid(1)), round(centroid.Centroid(2))], num2str(cells(indexCell)), 'TextColor', 'black', 'FontSize', 6, 'AnchorPoint', 'Center');
                binaryHollowTissue(:, :, round(centroid.Centroid(3))) = binaryHollowTissueSlice(:, :, 1);
            end
        end
    end
end