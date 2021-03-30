function [apicalLayer,basalLayer,lateralLayer] = getApicalBasalLateralFromGlands(labelledImage,lumenImage)
    basalLayer = zeros(size(labelledImage));
    apicalLayer = zeros(size(labelledImage));
    lateralLayer = zeros(size(labelledImage));
    
    cystFilled = imfill(labelledImage>0 | lumenImage>0,'holes');
    perimCystFilled = bwperim(cystFilled);
    basalLayer(perimCystFilled) = labelledImage(perimCystFilled);
    
    apicalBasalLayer = bwperim(cystFilled-(lumenImage>0));
    apicalLayer(apicalBasalLayer) = labelledImage(apicalBasalLayer);
    apicalLayer(perimCystFilled)=0;
    
    totalCells = unique(labelledImage(:))';
    totalCells(totalCells==0)=[];
    for nCell = totalCells
        perimLateralCell = bwperim(labelledImage==nCell);
        lateralLayer(perimLateralCell)=nCell;
    end
    
    lateralLayer(basalLayer>0 | apicalLayer>0) = 0; 
        
end