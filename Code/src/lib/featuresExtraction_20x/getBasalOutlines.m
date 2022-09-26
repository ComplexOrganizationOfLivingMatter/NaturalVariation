function maskOutlines = getBasalOutlines(img)
    %get outline
    BW = (img>0);
    for nZ=1:size(img,3)
        BW(:,:,nZ) = imfill(BW(:,:,nZ),'holes');
    end
    maskOutlines = double(imdilate(bwperim(BW),strel('sphere',2)));
end
