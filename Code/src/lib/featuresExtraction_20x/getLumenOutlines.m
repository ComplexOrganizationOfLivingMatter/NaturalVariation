function maskOutlines = getLumenOutlines(img)
    %get outline
    BW = (img>0);
    for nZ=1:size(img,3)
        BW(:,:,nZ) = imfill(BW(:,:,nZ),'holes');
    end
    
    binaryNonCells = ~(img>0);
    binaryNonCells(BW==0)=0;
    
    labelNonCells = bwlabeln(binaryNonCells);
    labels2Del = unique([labelNonCells(1,1,1),labelNonCells(end,end,end),labelNonCells(1,end,end),labelNonCells(1,1,end),labelNonCells(1,end,1),labelNonCells(end,1,1),labelNonCells(end,end,1)]);
    labelNonCells(labelNonCells==labels2Del)=0;
    
    volume = regionprops3(labelNonCells,'Volume');
    [~,idLabel]=max(volume.Volume);
    BWLumen = labelNonCells==idLabel;
      
    maskOutlines = double(imdilate(bwperim(BWLumen),strel('sphere',2)));
end
