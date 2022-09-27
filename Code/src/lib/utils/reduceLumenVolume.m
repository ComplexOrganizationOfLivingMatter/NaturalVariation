function [voronoiCyst] = reduceLumenVolume(labelledImage)

    %Get binary version of labelled image 
    binaryLabelledImage = imbinarize(labelledImage);
    
    %fill hollow tissue
    fullCyst = imfill(binaryLabelledImage, 'holes');
    
    %Dilate 2 px
    se = strel('disk',2);
    dilatedBinaryLabelledImage = imdilate(binaryLabelledImage, se);
    
    %Multiply dilated x fullCyst to keep dilated inner wall and discard the
    %outer one
    dilatedInnerWall = dilatedBinaryLabelledImage.*fullCyst;
    
    %Get the pixels we'd like to fill
    idsToFill = find(dilatedInnerWall==1 & labelledImage==0);
    [row, col, z] = ind2sub(size(dilatedInnerWall),idsToFill);
    labelPerId = zeros(size(idsToFill));

    voronoiCyst=labelledImage.*dilatedInnerWall;

    perimCells=bwperim(voronoiCyst>0);
    
    idsPerim = find(perimCells==1);
    [rowPer, colPer, zPer] = ind2sub(size(dilatedInnerWall),idsPerim);
    labelsPerimIds = voronoiCyst(perimCells);
    
    parfor nId = 1:length(idsToFill)
        distCoord = pdist2([col(nId),row(nId), z(nId)],[colPer,rowPer, zPer]);
        [~,idSeedMin]=min(distCoord);
        labelPerId(nId) = labelsPerimIds(idSeedMin);
    end
    
    voronoiCyst(idsToFill)=labelPerId;
    
end
