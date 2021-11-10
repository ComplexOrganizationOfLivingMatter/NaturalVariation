imagesPath = '/media/pedro/6TB/jesus/EM_Image_Segmentation/exp_results/unet_3d_bigDataSet_cysts_predict/results/unet_3d_bigDataSet_cysts_predict_1/per_image_enhanced/itk/PostProcessing/';
imgDirectory = dir(strcat(imagesPath, '*', '.tiff'));

savePath = '/media/pedro/6TB/jesus/EM_Image_Segmentation/exp_results/unet_3d_bigDataSet_cysts_predict/results/unet_3d_bigDataSet_cysts_predict_1/per_image_enhanced/itk/PostProcessing/reducedLumen/';

for idx=1:length(imgDirectory)
    
    fileName = imgDirectory(idx).name;
%     load(strcat(imagesPath, fileName));
    labelledImage = readStackTif(strcat(imagesPath, fileName));
    labelledImage =  reduceLumenVolume(labelledImage);
    
%     name = strsplit(fileName, '.mat');
%     writeStackTif(double(labelledImage)./255, strcat(savePath, name{1}, '.tif'));
    writeStackTif(double(labelledImage)./255, strcat(savePath, fileName));

end