function handles = updateResizedImage(hObject, handles)
%UPDATERESIZEDIMAGE Summary of this function goes here
%   Detailed explanation goes here
    labelledImage = handles.labelledImageTemp;
    lumenImage = handles.lumenImageTemp;
    resizeImg = handles.resizeImg;
    
    originalSize = size(labelledImage);
    sizeResized = originalSize * resizeImg;
    sizeResized(3) = originalSize(3);
    
    handles.labelledImageTemp_Resized = imresize3(labelledImage, sizeResized, 'nearest');
    handles.lumenImageTemp_Resized = imresize3(double(lumenImage), sizeResized, 'nearest')>0;
    
    % Update handles structure
    guidata(hObject, handles);
    
    zoom(gcf, 'off');
end

