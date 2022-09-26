function [apicalLayer,basalLayer,lateralLayer,lumenImage] = getApicalBasalLateralAndLumenFromPlantSeg(labelledImage,path2saveLayers)
    basalLayer = zeros(size(labelledImage));
    apicalLayer = zeros(size(labelledImage));
    lateralLayer = zeros(size(labelledImage));
    
    %calculate outlayer label and delete it
    volLabels = table2array(regionprops3(labelledImage,'Volume'));
    medVol = median(volLabels);
    [~,bigLabels]=sort(volLabels,'descend');
    
    if volLabels(bigLabels(2))/medVol > 4
        labelledImage(labelledImage==bigLabels(1))=0;
        labelledImage(labelledImage==bigLabels(2))=0;
        disp(['removed label(s) ' num2str(bigLabels(1)) ', ' num2str(bigLabels(2))])
    else
        labelledImage(labelledImage==bigLabels(1))=0;
        disp(['removed label(s) ' num2str(bigLabels(1))])
    end
    

    cystFilled = imfill(labelledImage>0,'holes');
    perimCystFilled = bwperim(cystFilled);
    basalLayer(perimCystFilled) = labelledImage(perimCystFilled);
    
    apicalBasalLayer = bwperim(labelledImage>0);
    apicalLayer(apicalBasalLayer) = labelledImage(apicalBasalLayer);
    apicalLayer(perimCystFilled)=0;
    
    totalCells = unique(labelledImage(:))';
    totalCells(totalCells==0)=[];
    for nCell = totalCells
        perimLateralCell = bwperim(labelledImage==nCell);
        lateralLayer(perimLateralCell)=nCell;
    end
    
    lateralLayer(basalLayer>0 | apicalLayer>0) = 0;
    
    lumenImage = labelledImage==0 & cystFilled;
    volumeLumen =regionprops3(bwlabeln(lumenImage),'Volume');
    if size(volumeLumen.Volume,1)>1
        [~,id] = max(volumeLumen.Volume);
        lumenImage = bwlabeln(lumenImage) == id;
    end
    
    if ~isempty(path2saveLayers)
        save(path2saveLayers, 'apicalLayer','basalLayer','lateralLayer','lumenImage','labelledImage','-v7.3')
    end
end
