%get cell outlines from segmented .tif images -> training set for u-net 3D

clear all; close all; addpath(genpath('src'))

%1. Load segmented cysts
pathSegmentedCysts = dir('..\data\trainingDataSetCysts_UNET_3D\Labelled\news\*.tif');

parpool(10)
parfor nCyst = 1:size(pathSegmentedCysts,1)
    disp(fullfile(pathSegmentedCysts(nCyst).folder,pathSegmentedCysts(nCyst).name))
    folder2save = strrep(pathSegmentedCysts(nCyst).folder,'Labelled','outlineImage');
    if ~exist(folder2save,'dir')
        mkdir(folder2save)
    end
    if ~exist(fullfile(folder2save,pathSegmentedCysts(nCyst).name),'file')
    
        %read tiff labelled images
        img = readStackTif(fullfile(pathSegmentedCysts(nCyst).folder,pathSegmentedCysts(nCyst).name));
    
        %get dilated cell outlines
        maskOutlines = getCellOutlines(img);
        
        %save tiff outlines images
        writeStackTif(maskOutlines,fullfile(folder2save,pathSegmentedCysts(nCyst).name))
    end
    
   
end

