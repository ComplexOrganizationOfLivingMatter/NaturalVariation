labelPath = uigetdir('D:\Jesus\tutorial\', 'Select label images (.mat) path');
imagesPath = uigetdir('D:\Jesus\tutorial\', 'Select raw images (.tif) path');

savePath = uigetdir('D:\Jesus\tutorial\', 'Select where to save label images (.mat)');

labelPath = strcat(labelPath, '\');
imagesPath = strcat(imagesPath, '\');
savePath = strcat(savePath, '\');

labelDir = dir(strcat(labelPath, '*', '.mat'));


for idx=1:length(labelDir)
    
    fileName = labelDir(idx).name;
    
    load(strcat(labelPath, fileName));

    %% Relabel 
    idLabels = unique(labelledImage(:));
    imgRelabel = zeros(size(labelledImage));
    for id = 1:length(idLabels)-1
        imgRelabel(labelledImage==idLabels(id+1))= id;
    end
    labelledImage = imgRelabel;
    
    fileName = strsplit(fileName, '.mat');
    fileName = fileName{1};
    [rgStackImg, imgInfo] = readStackTif(strcat(imagesPath, fileName, '.tif'));
    
    labelledImage = imresize3(labelledImage, [size(rgStackImg, 1), size(rgStackImg, 2), size(rgStackImg, 3)], 'nearest');

    writeStackTif(double(labelledImage)./255, strcat(savePath, fileName, '.tif'))
%     name = strsplit(fileName, '.tif');
    
    filename = fullfile(savePath, strcat(fileName, '.mat'));
    save(filename, 'rgStackImg', 'labelledImage');
    
end
