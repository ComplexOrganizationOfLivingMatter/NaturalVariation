%%main features extraction segmented Cysts
clear all
close all
addpath(genpath(fullfile('..','..','Processing3DSegmentation')))

%1. Load final segmented cysts
pathCysts = dir('..\data\**\3d_layers_info.mat');

%At least the 0.5% of lateral membrane contacting with other cell to be
%considered as neighbor.
contactThreshold = 0.5;

%init params to store features
allGeneralInfo = cell(size(pathCysts,1),1);
allTissues = cell(size(pathCysts,1),1);
allLumens = cell(size(pathCysts,1),1);
allHollowTissue3dFeatures = cell(size(pathCysts,1),1);
allNetworkFeatures = cell(size(pathCysts,1),1);
totalMeanCellsFeatures = cell(size(pathCysts,1),1);
totalStdCellsFeatures = cell(size(pathCysts,1),1);

%define path 2 save
path2saveSummary = "";

parfor nCyst = 1:size(pathCysts,1)

    %%display cyst name
    disp('')
    folderFeatures = [fullfile(pathCysts(nCyst).folder,'Features'), num2str(contactThreshold)];
    if ~exist(folderFeatures,'dir')
        mkdir(folderFeatures);
    end

    %%load labelled image and make X, Y, Z resolution equal
    if exist(fullfile(pathCysts(nCyst).folder,'realSize3dLayers.mat'),'file')
        %%load same resolution image
        labelledImage=struct2array(load(fullfile(pathCysts(nCyst).folder,'realSize3dLayers.mat'),'labelledImage_realSize'));
    else
        %%load image with different Z scale
        labelledImage=struct2array(load(fullfile(pathCysts(nCyst).folder,pathCysts(nCyst).name),'labelledImage'));
        zScale = struct2array(load(fullfile(pathCysts(nCyst).folder,'zScaleOfGland.mat'),'zScale'));
        labelledImage = imresize3(labelledImage,[size(labelledImage,1),size(labelledImage,2),round(size(labelledImage,3)*zScale)],'nearest');
    end

%   4. Extract features from 3d image
    pixelScale = struct2array(load(fullfile(pathCysts(nCyst).folder,'pixelScaleOfGland.mat'),'pixelScale'));
    
    %%define filename
    fileName = '';
    
    %%get apical and basal layers, and Lumen
    if ~exist(fullfile(pathCysts(nCyst).folder, '\layersTissue.mat'),'file')
        path2saveLayers = fullfile(pathCysts(nCyst).folder, '\layersTissue.mat');
        [apicalLayer,basalLayer,lateralLayer,lumenImage] = getApicalBasalLateralAndLumenFromCyst(labelledImage,path2saveLayers);
    else
        if ~exist(fullfile(folderFeatures, 'global_3dFeatures.mat'),'file')
            allLayers = load(fullfile(pathCysts(nCyst).folder, '\layersTissue.mat'),'apicalLayer','basalLayer','lateralLayer','lumenImage');
            apicalLayer= allLayers.apicalLayer;     basalLayer = allLayers.basalLayer;      lateralLayer = allLayers.lateralLayer;      lumenImage = allLayers.lumenImage;
        else
            apicalLayer=[]; basalLayer = []; lateralLayer =[]; lumenImage=[];
        end
    end

    [allGeneralInfo{nCyst},allTissues{nCyst},allLumens{nCyst},allHollowTissue3dFeatures{nCyst},allNetworkFeatures{nCyst},totalMeanCellsFeatures{nCyst},totalStdCellsFeatures{nCyst}]=calculate3DMorphologicalFeatures(labelledImage,apicalLayer,basalLayer,lateralLayer,lumenImage,folderFeatures,fileName,pixelScale,contactThreshold);
end

summarizeAllTissuesProperties(allGeneralInfo,allTissues,allLumens,allHollowTissue3dFeatures,allNetworkFeatures,totalMeanCellsFeatures,totalStdCellsFeatures,path2saveSummary);
