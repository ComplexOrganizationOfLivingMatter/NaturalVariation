labelPath = '/media/pedro/6TB/jesus/NaturalVariation/fixedCysts_CARMEN/validateCysts_17_feb/reducedLumen/';
imagesPath = '/media/pedro/6TB/jesus/NaturalVariation/fixedCysts_CARMEN/validateCysts_17_feb/rg/';

savePath = '/media/pedro/6TB/jesus/NaturalVariation/fixedCysts_CARMEN/validateCysts_17_feb/validateCysts_reducedLumen/';

labelDir = dir(strcat(labelPath, '*', '.tiff'));

for idx=1:length(labelDir)
    
    fileName = labelDir(idx).name;
    
    labelledImage = readStackTif(strcat(labelPath, fileName));

    %% Relabel 
    idLabels = unique(labelledImage(:));
    imgRelabel = zeros(size(labelledImage));
    for id = 2:length(idLabels)-1
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
