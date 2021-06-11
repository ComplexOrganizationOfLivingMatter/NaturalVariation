function [blob] = getBiggestBlob(blobs)
    volumeBlobs = regionprops3(bwlabeln(blobs),'Volume');
    if size(volumeBlobs, 1)>1
        [~,id] = max(volumeBlobs.Volume);
        blob = bwlabeln(blobs) == id;
    else
        blob = blobs;
    end
    
end