%get cell outlines from segmented .tif images -> training set for u-net 3D

clear all; close all; addpath(genpath('src'))

%1. Load segmented cysts
selpath = uigetdir;
pathSegmentedCysts=dir(fullfile(selpath ,'*.tif'));

delete(gcp('nocreate'))
parpool(12)
parfor nCyst = 1:size(pathSegmentedCysts,1)
    disp(fullfile(pathSegmentedCysts(nCyst).folder,pathSegmentedCysts(nCyst).name))
    
    %create folders to save
    folder2save = strrep(pathSegmentedCysts(nCyst).folder,'Labelled','');
     
    folder2save1 = fullfile(folder2save,'cellOutlineImage');
    if ~exist(folder2save1,'dir')
        mkdir(folder2save1)
    end
    
    folder2save2 = fullfile(folder2save,'lumenOutlineImage');
    if ~exist(folder2save2,'dir')
        mkdir(folder2save2)
    end
    
    folder2save3 = fullfile(folder2save,'basalOutlineImage');
    if ~exist(folder2save3,'dir')
        mkdir(folder2save3)
    end
    
    %read tiff labelled images
    img = readStackTif(fullfile(pathSegmentedCysts(nCyst).folder,pathSegmentedCysts(nCyst).name));
    
    if ~exist(fullfile(folder2save1,pathSegmentedCysts(nCyst).name),'file')
        %get dilated cell outlines
        maskCellOutlines = getCellOutlines(img);
        %save tiff outlines images
        writeStackTif(maskCellOutlines,fullfile(folder2save1,pathSegmentedCysts(nCyst).name))
    end
    if ~exist(fullfile(folder2save2,pathSegmentedCysts(nCyst).name),'file')
        %get dilated lumen outline
        maskLumenOutlines = getLumenOutlines(img);
        %save tiff outlines images
        writeStackTif(maskLumenOutlines,fullfile(folder2save2,pathSegmentedCysts(nCyst).name))
    end
    if ~exist(fullfile(folder2save3,pathSegmentedCysts(nCyst).name),'file')
        %get dilated basal outline
        maskBasalOutlines = getBasalOutlines(img);
        %save tiff outlines images
        writeStackTif(maskBasalOutlines,fullfile(folder2save3,pathSegmentedCysts(nCyst).name))
    end
   
end

