function fromLabelToVoronoiSegmentLabel_bulk(labelsPath, savePath)

    labelsDir = dir(strcat(labelsPath, '*.mat'));

    for labelIx = 1:size(labelsDir, 1)
%         [label, imgInfo] = readStackTif(strcat(labelsPath, labelsDir(labelIx).name));
        load(strcat(labelsPath, labelsDir(labelIx).name));
        label = labelledImage;
        name = strsplit(labelsDir(labelIx).name, '.mat');
        disp(name{1})
        try
            voronoiLabel = fromLabelToVoronoiSegmentLabel(label);
            writeStackTif(voronoiLabel, strcat(savePath, name{1}, '_segmentVoronoi.tif'));
        catch
            warning('error');
        end
    end
end
    
    