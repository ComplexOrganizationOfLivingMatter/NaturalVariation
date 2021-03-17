%get cell outlines from segmented .tif images -> training set for u-net 3D

clear all; close all; addpath(genpath('src'))

%1. Load segmented cysts
selpath = uigetdir;
pathSegmentedCysts=dir(fullfile(selpath ,'*.tif'));

parpool(12)
parfor nCyst = 1:size(pathSegmentedCysts,1)
    disp(fullfile(pathSegmentedCysts(nCyst).folder,pathSegmentedCysts(nCyst).name))
    folder2save1 = strrep(pathSegmentedCysts(nCyst).folder,'Labelled','cellOutlineImage');
    if ~exist(folder2save1,'dir')
        mkdir(folder2save1)
    end
    
    folder2save2 = strrep(pathSegmentedCysts(nCyst).folder,'Labelled','lumenOutlineImage');
    if ~exist(folder2save2,'dir')
        mkdir(folder2save2)
    end
    
    
    if ~exist(fullfile(folder2save1,pathSegmentedCysts(nCyst).name),'file')
    
        %read tiff labelled images
        img = readStackTif(fullfile(pathSegmentedCysts(nCyst).folder,pathSegmentedCysts(nCyst).name));
    
        if ~exist(fullfile(path2save,filePaths(nFile).name),'file')
            %get dilated cell outlines
            maskCellOutlines = getCellOutlines(img);

            %get dilated lumen outline
            maskLumenOutlines = getLumenOutlines(img);

            %save tiff outlines images
            writeStackTif(maskCellOutlines,fullfile(folder2save1,pathSegmentedCysts(nCyst).name))

            %save tiff outlines images
            writeStackTif(maskLumenOutlines,fullfile(folder2save2,pathSegmentedCysts(nCyst).name))
        end
    end
    
   
end

