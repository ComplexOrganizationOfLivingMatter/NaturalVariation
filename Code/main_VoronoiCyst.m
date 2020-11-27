clear all; close all; addpath(genpath('..\Code'))

%1. Load final segmented cysts
pathCysts = dir('..\data\**\3d_layers_info.mat');
rootPathModels = '..\models\';
mkdir(rootPathModels)

for nCyst = 1:size(pathCysts,1)
    
    if exist(fullfile(pathCysts(nCyst).folder,'realSize3dLayers.mat'),'file')
        load(fullfile(pathCysts(nCyst).folder,'realSize3dLayers.mat'),'apicalLayer','basalLayer','labelledImage_realSize')
        labelledImage = labelledImage_realSize;
        clearvars labelledImage_realSize
    else
        load(fullfile(pathCysts(nCyst).folder,pathCysts(nCyst).name),'apicalLayer','basalLayer','labelledImage')
    end
    
    splittedFolder = strsplit(pathCysts(nCyst).folder,'\');
    folderModel = fullfile(rootPathModels,splittedFolder{6},splittedFolder{7});

    %2. Get raw and adjusted cell centroids
    if ~exist([folderModel '\cellCentroids.mat'],'file')
        mkdir(folderModel)
        [centroidsRaw,newCentroids] = getCentroids(labelledImage,apicalLayer,basalLayer);
        save([folderModel '\cellCentroids.mat'],'newCentroids','centroidsRaw')
    else
        load([folderModel '\cellCentroids.mat'],'newCentroids','centroidsRaw')
    end

    %3. Generate 3D Voronoi (from centroids as seeds)
    if ~exist([folderModel '\cystVoronoi.mat'],'file')
        [labelledImageVoronoi_Raw] = generate3DVoronoi_bounded(centroidsRaw,labelledImage>0);
        [labelledImageVoronoi_NewSeeds] = generate3DVoronoi_bounded(newCentroids,labelledImage>0);
        save([folderModel '\cystVoronoi.mat'],'labelledImageVoronoi_Raw','labelledImageVoronoi_NewSeeds','-v7.3')
    else
        load([folderModel '\cystVoronoi.mat'],'labelledImageVoronoi_Raw','labelledImageVoronoi_NewSeeds')
    end
    
    %4. Extract features from 3D Voronoi models
    
    
end
        
