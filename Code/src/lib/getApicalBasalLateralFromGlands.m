function [apicalLayer,basalLayer,lateralLayer,lumenSkeleton] = getApicalBasalLateralFromGlands(labelledImage,lumenImage,path2saveLayers)
    basalLayer = zeros(size(labelledImage));
    apicalLayer = zeros(size(labelledImage));
    lateralLayer = zeros(size(labelledImage));
    
    cystFilled = imfill(labelledImage>0 | lumenImage>0,'holes');
    perimCystFilled = bwperim(cystFilled);
    
    labelledImageNoGaps = VoronoizateCells(cystFilled-(lumenImage>0),labelledImage);

    basalLayer(perimCystFilled) = labelledImage(perimCystFilled);
    
    apicalBasalLayer = bwperim(cystFilled-(lumenImage>0));
    apicalLayer(apicalBasalLayer) = labelledImageNoGaps(apicalBasalLayer);
    
    apicalLayer(perimCystFilled)=0;
    
    totalCells = unique(labelledImage(:))';
    totalCells(totalCells==0)=[];
    for nCell = totalCells
        perimLateralCell = bwperim(labelledImageNoGaps==nCell);
        lateralLayer(perimLateralCell)=nCell;
    end
    
    lateralLayer(basalLayer>0 | apicalLayer>0) = 0; 
    labelledImage = labelledImageNoGaps;
        
    if max(labelledImage(labelledImage>0))<256
        apicalLayer=uint8(apicalLayer);
        basalLayer=uint8(basalLayer);
        labelledImage=uint8(labelledImage);
        lateralLayer=uint8(lateralLayer);
    else
        apicalLayer=uint16(apicalLayer);
        basalLayer=uint16(basalLayer);
        labelledImage=uint16(labelledImage);
        lateralLayer=uint16(lateralLayer);
    end
    
    thresholdMinBranches = 100;
    lumenSkeleton = bwskel(lumenImage,'MinBranchLength',thresholdMinBranches);
    
    a = imdilate(lumenSkeleton,strel('sphere',4));
    lumenSkeleton = bwskel(a,'MinBranchLength',thresholdMinBranches);
    a2 = imdilate(lumenSkeleton,strel('sphere',4));
    lumenSkeleton = bwskel(a2,'MinBranchLength',thresholdMinBranches);
    a3 = imdilate(lumenSkeleton,strel('sphere',4));
    clearvars a a2 a3

    save(path2saveLayers,'apicalLayer','basalLayer','lateralLayer','lumenImage','labelledImage','lumenSkeleton','-v7.3')
end