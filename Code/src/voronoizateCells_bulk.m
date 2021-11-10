%Input path
labelsPath = '/media/pedro/6TB/jesus/EM_Image_Segmentation/exp_results/unet_3d_bigDataSet_cysts_predict/results/unet_3d_bigDataSet_cysts_predict_1/per_image_enhanced/itk/PostProcessing/';
labelsDirectory = dir(strcat(labelsPath, '*', '.tiff'));
origPath = '/media/pedro/6TB/jesus/NaturalVariation/crops/bigDataSet_predict/test/x/';

%Output path
savePath = '/media/pedro/6TB/jesus/EM_Image_Segmentation/exp_results/unet_3d_bigDataSet_cysts_predict/results/unet_3d_bigDataSet_cysts_predict_1/per_image_enhanced/itk/PostProcessing/voronoizateCells_reducedLumen/';

%For loop
for idx=1:length(labelsDirectory)
    
    %Read Labelled Img
    fileName = labelsDirectory(idx).name;
    labelledImage = readStackTif(strcat(labelsPath, fileName));
    name = strsplit(fileName, '_itkws.tiff');
    name = name{1};
    
    rgStackImg =  readStackTif(strcat(origPath, name, '.tif'));
    
    se = strel('sphere',1);
    dilatedlabelledImage = imdilate(labelledImage, se);
    
%     dilatedlabelledImage(dilatedlabelledImage==1)=0;
%     dilatedlabelledImage(dilatedlabelledImage==2)=0;

    %binary label
    [apicalLayer,basalLayer,lateralLayer,lumenImage] = getApicalBasalLateralAndLumenFromPlantSeg(dilatedlabelledImage, '');
    binaryLabel = bwlabeln(dilatedlabelledImage);
    
    voronoiCyst = VoronoizateCells(binaryLabel, dilatedlabelledImage);
    
    labelledImage =  reduceLumenVolume(voronoiCyst);
    
%     name = strsplit(fileName, '.mat');
%     writeStackTif(double(labelledImage)./255, strcat(savePath, name{1}, '.tif'));
    writeStackTif(double(labelledImage)./255, strcat(savePath, name, '.tif'));
    filename = fullfile(strcat(savePath, 'newMatFiles/'), strcat(name, '.mat'));
    save(filename, 'rgStackImg', 'labelledImage');
end