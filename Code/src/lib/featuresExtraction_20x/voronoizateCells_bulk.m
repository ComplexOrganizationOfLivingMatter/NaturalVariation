%Input path
labelsPath = '/media/pedro/6TB/jesus/methodology_naturalVariation/stardist/test/y/';
labelsDirectory = dir(strcat(labelsPath, '*', '.tif'));
% origPath = '/media/pedro/6TB/jesus/EM_Image_Segmentation/exp_results/evaluate_RG_bigDataset/results/evaluate_RG_bigDataset_20210701/per_image_no_binarized_old/itk/original/';
maskPath = '/media/pedro/6TB/jesus/EM_Image_Segmentation/exp_results/mask_training_10cysts/results/mask_training_10cysts_0/per_image/';
%Output path
savePath = '/media/pedro/6TB/jesus/methodology_naturalVariation/stardist/test/y_VOR/';

%For loop
for idx=1:length(labelsDirectory)
    
    %Read Labelled Img
    fileName = labelsDirectory(idx).name;
    labelledImage = readStackTif(strcat(labelsPath, fileName));
    name = strsplit(fileName, '.tif');
    name = name{1};
       
    if isempty(maskPath)
        se = strel('sphere',10);
        labelledImage(labelledImage==1)=0;
        labelledImage(labelledImage==2)=0;

        dilatedlabelledImage = imdilate(labelledImage, se);

        %binary label
        [apicalLayer,basalLayer,lateralLayer,lumenImage] = getApicalBasalLateralAndLumenFromPlantSeg(dilatedlabelledImage, '');
        binaryLabel = bwlabeln(dilatedlabelledImage);
        
    else
        mask = readStackTif(strcat(maskPath, fileName));
        binaryLabel = imbinarize(mask);
    end
    voronoiCyst = VoronoizateCells(binaryLabel, labelledImage);
    
    labelledImage =  reduceLumenVolume(voronoiCyst);
    
%     name = strsplit(fileName, '.mat');
%     writeStackTif(double(labelledImage)./255, strcat(savePath, name{1}, '.tif'));
    writeStackTif(double(labelledImage)./255, strcat(savePath, fileName));
    
    if isempty(maskPath)
        rgStackImg =  readStackTif(strcat(origPath, name));
        filename = fullfile(strcat(savePath, 'newMatFiles/'), strcat(name, '.mat'));
        save(filename, 'rgStackImg', 'labelledImage');
    end
end