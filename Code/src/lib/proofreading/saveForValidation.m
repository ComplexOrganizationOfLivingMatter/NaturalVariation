labelPath = uigetdir('D:\Jesus\tutorial\', 'Select label images (.tif) path');
imagesPath = uigetdir('D:\Jesus\tutorial\', 'Select raw images (.tif) path');

savePath = uigetdir('D:\Jesus\tutorial\', 'Select where to save label images (.mat)');

labelPath = strcat(labelPath, '\');
imagesPath = strcat(imagesPath, '\');
savePath = strcat(savePath, '\');

labelDir = dir(strcat(labelPath, '*', '.tif'));


for idx=1:length(labelDir)
    
    fileName = labelDir(idx).name;
    
    labelledImage = readStackTif(strcat(labelPath, fileName));

    %% Relabel 
    idLabels = unique(labelledImage(:));
    imgRelabel = zeros(size(labelledImage));
    for id = 1:length(idLabels)-1
        imgRelabel(labelledImage==idLabels(id+1))= id;
    end
    labelledImage = imgRelabel;
    
    fileName = strsplit(fileName, '.tif');
    fileName = fileName{1};
    rgStackImg = readStackTif(strcat(imagesPath, fileName, '.tif'));
    
%     name = strsplit(fileName, '.tif');
    
    filename = fullfile(savePath, strcat(fileName, '.mat'));
    save(filename, 'rgStackImg', 'labelledImage');
    
end
