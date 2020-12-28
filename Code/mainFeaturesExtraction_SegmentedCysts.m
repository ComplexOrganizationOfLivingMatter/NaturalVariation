%%main features extraction segmented Cysts
clear all
close all
addpath(genpath('..\Code'))

%1. Load final segmented cysts
pathCysts = dir('..\data\**\3d_layers_info.mat');
path2saveSummary = '..\data\';

allGeneralInfo = cell(size(pathCysts,1),1);
allTissues = cell(size(pathCysts,1),1);
allLumens = cell(size(pathCysts,1),1);
allHollowTissue3dFeatures = cell(size(pathCysts,1),1);
allNetworkFeatures = cell(size(pathCysts,1),1);
totalMeanCellsFeatures = cell(size(pathCysts,1),1);
totalStdCellsFeatures = cell(size(pathCysts,1),1);
totalMean3DNeighsFeatures = cell(size(pathCysts,1),1);
totalSTD3DNeighsFeatures = cell(size(pathCysts,1),1);

%At least the 0.5% of lateral membrane contacting with other cell to be
%considered as neighbor.
contactThreshold = 0.5;

for nCyst = 1:size(pathCysts,1)
    
    splittedFolder = strsplit(pathCysts(nCyst).folder,'\');
    display(splittedFolder{7})
    folderFeatures = fullfile(pathCysts(nCyst).folder,'Features');
    mkdir(folderFeatures)
    
    if exist(fullfile(pathCysts(nCyst).folder,'realSize3dLayers.mat'),'file')
        load(fullfile(pathCysts(nCyst).folder,'realSize3dLayers.mat'),'labelledImage_realSize')
        labelledImage = labelledImage_realSize;
        clearvars labelledImage_realSize
    else
        load(fullfile(pathCysts(nCyst).folder,pathCysts(nCyst).name),'labelledImage')
        load(fullfile(pathCysts(nCyst).folder,'zScaleOfGland.mat'),'zScale')

        labelledImage = imresize3(labelledImage,[size(labelledImage,1),size(labelledImage,2),round(size(labelledImage,3)*zScale)],'nearest');
        if size(labelledImage,3)>size(labelledImage,1)
            labelledImage = imresize3(labelledImage,[size(labelledImage,1)*zScale,size(labelledImage,2)*zScale,round(size(labelledImage,3))],'nearest');
        end

    end
    
%   4. Extract features from 3D Voronoi models
    load(fullfile(pathCysts(nCyst).folder,'pixelScaleOfGland.mat'),'pixelScale')    
    fileName = [splittedFolder{6} '/' splittedFolder{7}];
    %%get apical and basal layers, and Lumen
    if ~exist([folderFeatures '\layersTissue.mat'],'file')
        [apicalLayer,basalLayer,lateralLayer,lumenImage] = getApicalBasalLateralAndLumenFromCyst(labelledImage);
        save([folderFeatures '\layersTissue.mat'],'apicalLayer','basalLayer','lateralLayer','lumenImage','-v7.3')
    else
        if ~exist(fullfile(folderFeatures, 'global_3dFeatures.mat'),'file')
            load([folderFeatures '\layersTissue.mat'],'apicalLayer','basalLayer','lateralLayer','lumenImage')
        else
            apicalLayer=[]; basalLayer = []; lateralLayer =[]; lumenImage=[];
        end
    end

    tic
    [allGeneralInfo{nCyst},allTissues{nCyst},allLumens{nCyst},allHollowTissue3dFeatures{nCyst},allNetworkFeatures{nCyst},totalMeanCellsFeatures{nCyst},totalStdCellsFeatures{nCyst}]=calculate3DMorphologicalFeatures(labelledImage,apicalLayer,basalLayer,lateralLayer,lumenImage,folderFeatures,fileName,pixelScale,contactThreshold);
    toc
end

summarizeAllTissuesProperties(allGeneralInfo,allTissues,allLumens,allHollowTissue3dFeatures,allNetworkFeatures,totalMeanCellsFeatures,totalStdCellsFeatures,path2saveSummary);
        