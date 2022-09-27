% image path (.tif)
imagesPath = 'F:\jesus\labels\';

imgDirectory = dir(strcat(imagesPath, '*', '.tif'));

% save path
savePath = 'F:\jesus\savePath\';

for idx=1:length(imgDirectory)
    
    fileName = imgDirectory(idx).name;

    labelledImage = readStackTif(strcat(imagesPath, fileName));
    labelledImage =  enlargeLumenVolume(labelledImage);
    
    writeStackTif(labelledImage, strcat(savePath, fileName));

    
end
