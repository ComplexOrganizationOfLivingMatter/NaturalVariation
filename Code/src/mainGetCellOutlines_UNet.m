%get cell outlines from segmented .tif images -> training set for u-net 3D

clear all; close all; addpath(genpath('..\Code'))
% 
% %1. Load CARMEN final segmented cysts
% pathSegmentedAdjustedCysts = dir('..\data\**\Results\*_lateral+basal.tif');
unet3DTrainingSetPath = '..\..\U-NET3D\Cysts\';
% mkdir(unet3DTrainingSetPath)
% 
% parfor nCyst = 1:size(pathSegmentedAdjustedCysts,1)
%     
%     splittedFolder = strsplit(pathSegmentedAdjustedCysts(nCyst).folder,'\');
%     cystTypeFolder = fullfile(unet3DTrainingSetPath,splittedFolder{6});
%     
%     img = readStackTif(fullfile(pathSegmentedAdjustedCysts(nCyst).folder,pathSegmentedAdjustedCysts(nCyst).name));
%     
%     maskOutlines = getCellOutlines(img);
%     mkdir(cystTypeFolder)
%     writeStackTif(maskOutlines,fullfile(cystTypeFolder,pathSegmentedAdjustedCysts(nCyst).name))
%    
% end

%2. Load PEDRO final segmented cysts
pathSegmentedAdjustedCysts = dir('..\data\3D segmentation_Pedro\**\Results\3d_layers_info.mat');
for nCyst = 1:size(pathSegmentedAdjustedCysts,1)
    
    splittedFolder = strsplit(pathSegmentedAdjustedCysts(nCyst).folder,'\');
    cystTypeFolder = fullfile(unet3DTrainingSetPath,splittedFolder{8});
    load(fullfile(pathSegmentedAdjustedCysts(nCyst).folder,pathSegmentedAdjustedCysts(nCyst).name),'labelledImage')
    
%     maskOutlines = getCellOutlines(labelledImage);
%     mkdir(cystTypeFolder)
    writeStackTif(labelledImage,fullfile([splittedFolder{7} '.tif']))
end