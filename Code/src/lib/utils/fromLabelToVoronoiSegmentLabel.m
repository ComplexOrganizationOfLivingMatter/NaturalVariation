function voronoiSegmentLabel=fromLabelToVoronoiSegmentLabel(labels)
    mask = labels>0;
    [apicalLayer,basalLayer,lateralLayer,lumenImage] = getApicalBasalLateralAndLumenFromCyst(labels, '');

    uniqueLabels = unique(labels);

    segmentSeedMatrix = zeros(size(labels));

    for cellIx = 2:length(uniqueLabels)
        cellId = uniqueLabels(cellIx);
        auxApicalLayer = apicalLayer==cellId;
        auxBasalLayer = basalLayer==cellId;
        
        centroid = regionprops3(labels==cellId, 'centroid');
        centroid = centroid.Centroid;
        centroid = mean(centroid,  1);
        apicalCentroid = regionprops3(auxApicalLayer, 'centroid');
        apicalCentroid = mean(apicalCentroid.Centroid,1);
        basalCentroid = regionprops3(auxBasalLayer, 'centroid');
        basalCentroid = mean(basalCentroid.Centroid,1);
        ypoints = [round(linspace(apicalCentroid(1), centroid(1), 5)), round(linspace(centroid(1), basalCentroid(1), 5));];
        xpoints = [round(linspace(apicalCentroid(2), centroid(2), 5)), round(linspace(centroid(2), basalCentroid(2), 5));];
        zpoints = [round(linspace(apicalCentroid(3), centroid(3), 5)), round(linspace(centroid(3), basalCentroid(3), 5));];
        
        for ix = linspace(1,10,10)
            segmentSeedMatrix(xpoints(ix),ypoints(ix),zpoints(ix))=cellId;
        end
    end
    
    voronoiSegmentLabel = VoronoizateCells(mask, segmentSeedMatrix);
end
