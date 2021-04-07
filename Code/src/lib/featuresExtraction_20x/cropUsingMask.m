function [croppedStackImg] = cropUsingMask(img, volumeMask, threshold, dilateFactor)
    volumeMaskBW = volumeMask/255;
    volumeMaskBW = imbinarize(volumeMaskBW, threshold); 
    se = strel('sphere',dilateFactor); 
    dilatedVolumeMask = imdilate(volumeMaskBW,se);
    croppedStackImg = dilatedVolumeMask.*img;
end