%resize images from 1024 x 1024 x X to 128 x 128 x X
folderImages = 'E:\Pedro\Stardist\cyst_20X_Jan_2021\Raw_LateralMembranes';
pathImages = dir([folderImages '\*.tif']);

for nImages = 1:size(pathImages,1)
    fileName = fullfile(pathImages(nImages).folder,pathImages(nImages).name);
    loadedImage = uint16(readStackTif(fileName));
    
    img2save = imresize3(loadedImage,[128,128,size(loadedImage,3)]);
%     img2save = imresize3(loadedImage,[128,128,size(loadedImage,3)],'nearest');
        
    fileName2save = fullfile(pathImages(nImages).folder,strrep(pathImages(nImages).name,'.tif','_20X.tif'));

    writeStackTif(img2save,fileName2save)
end