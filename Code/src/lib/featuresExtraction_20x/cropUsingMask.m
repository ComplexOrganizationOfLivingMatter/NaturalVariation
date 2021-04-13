function [croppedStackImg] = cropUsingMask(img, volumeMask, threshold, dilateFactor, overlap, centroidMethod)
    volumeMaskBW = volumeMask/255;
    volumeMaskBW = imbinarize(volumeMaskBW, threshold); 
    se = strel('sphere',dilateFactor); 
    dilatedVolumeMask = imdilate(volumeMaskBW,se);
    
    if centroidMethod == false
        croppedStackImg = dilatedVolumeMask.*img;

        %Compare volumes (overlap)
        imgFeatures = extractCellDescriptors(img, unique(img));
        croppedStackImgFeatures = extractCellDescriptors(croppedStackImg, unique(croppedStackImg));
        [isInB, ~] = ismember(imgFeatures.ID_Cell,croppedStackImgFeatures.ID_Cell);
        imgFeatures = imgFeatures(isInB, :);
        cells2Remove = croppedStackImgFeatures(croppedStackImgFeatures.Volume<overlap*imgFeatures.Volume, 'ID_Cell');
    %     croppedStackImgFeatures(croppedStackImgFeatures.Volume<0.85*imgFeatures.Volume, :) = [];

        for cell=1:length(cells2Remove.ID_Cell)
            cellID = cells2Remove(cell, 'ID_Cell');
            cellID_parts = strsplit(cellID.ID_Cell{1}, '_');
            croppedStackImg(croppedStackImg == str2double(cellID_parts{2})) = 0;
        end
        fprintf('%s cells removed due to low overlap\n', num2str(length(cells2Remove.ID_Cell)));
    else           
        imgFeatures = extractCellDescriptors(img, unique(img));
        cells = unique(img);
        counter = 0;
        for cell=1:length(cells)
            inMask = dilatedVolumeMask(round(imgFeatures.Centroid(cell,2)), round(imgFeatures.Centroid(cell,1)),round(imgFeatures.Centroid(cell,3)));
            cellId = cells(cell);
            if ~inMask
                img(img==cellId)=0;
                counter=counter+1;
            end
        end
        fprintf('%s cells removed by centroid method\n', num2str(counter));
        croppedStackImg = img;
    end
end