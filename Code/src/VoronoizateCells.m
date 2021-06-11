function [voronoiCyst] = VoronoizateCells(binaryMask,imgCells)

    voronoiCyst=imgCells.*binaryMask;

    perimCells=bwperim(voronoiCyst>0);
    
    %Get bounded valid pixels
    idsToFill = find(binaryMask==1 & imgCells==0);
    [row, col, z] = ind2sub(size(binaryMask),idsToFill);
    labelPerId = zeros(size(idsToFill));
    
    idsPerim = find(perimCells==1);
    [rowPer, colPer, zPer] = ind2sub(size(binaryMask),idsPerim);
    labelsPerimIds = voronoiCyst(perimCells);
    
    %From valid pixels get closest seed (add this value)
    %tic
%     disp('generating 3D Voronoi')
    parfor nId = 1:length(idsToFill)
        distCoord = pdist2([col(nId),row(nId), z(nId)],[colPer,rowPer, zPer]);
        [~,idSeedMin]=min(distCoord);
        labelPerId(nId) = labelsPerimIds(idSeedMin);
    end
    %toc
    voronoiCyst(idsToFill)=labelPerId;
end

