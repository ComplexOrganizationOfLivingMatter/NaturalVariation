%get cell outlines from segmented .tif images -> training set for u-net 3D

clear all; close all; addpath(genpath('..\Code'))

%1. Load final segmented cysts
pathSegmentedAdjustedCysts = dir('..\data\**\*_lateral+basal.tif');
unet3DTrainingSetPath = '..\..\U-NET3D\Cysts\';
mkdir(unet3DTrainingSetPath)

for nCyst = 1:size(pathSegmentedAdjustedCysts,1)
    
    splittedFolder = strsplit(pathCysts(nCyst).folder,'\');
    cystTypeFolder = fullfile(unet3DTrainingSetPath,splittedFolder{6});
    
    img = readStackTif(fullfile(pathSegmentedAdjustedCysts(nCyst).folder,pathSegmentedAdjustedCysts(nCyst).name));
            
    
    
end