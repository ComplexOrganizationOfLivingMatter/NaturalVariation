function maskOutlines = getLumenOutlines(img)
    %get outline
    binaryNonCells = ~(img>0);
    labelNonCells = bwlabeln(binaryNonCells);
    labelNonCells(labelNonCells==1)=0;
    
    volume = regionprops3(labelNonCells,'Volume');
    [~,idLabel]=max(volume.Volume);
    BWLumen = L==idLabel;
      
    maskOutlines = imdilate(bwperim(BWLumen),strel('sphere',2));
end