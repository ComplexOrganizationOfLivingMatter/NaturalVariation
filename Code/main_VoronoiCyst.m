clear all; close all; addpath(genpath('..\Code'))

%1. Load final segmented cysts
pathCysts = dir('..\data\**\3d_layers_info.mat');
rootPathModels = '..\models\';
mkdir(rootPathModels)

for nCyst = 1:size(pathCysts,1)
    splittedFolder = strsplit(pathCysts(nCyst).folder,'\');
    folderModel = fullfile(rootPathModels,splittedFolder{6},splittedFolder{7});
    display(splittedFolder{7})
    if ~exist([folderModel '\cystVoronoi.mat'],'file')
    
        if exist(fullfile(pathCysts(nCyst).folder,'realSize3dLayers.mat'),'file')
            load(fullfile(pathCysts(nCyst).folder,'realSize3dLayers.mat'),'apicalLayer','basalLayer','labelledImage_realSize')
            labelledImage = labelledImage_realSize;
            
            clearvars labelledImage_realSize
        else
            load(fullfile(pathCysts(nCyst).folder,pathCysts(nCyst).name),'apicalLayer','basalLayer','labelledImage')
            load(fullfile(pathCysts(nCyst).folder,'zScaleOfGland.mat'),'zScale')
            apicalLayer = imresize3(apicalLayer,[size(apicalLayer,1),size(apicalLayer,2),round(size(apicalLayer,3)*zScale)],'nearest');
            basalLayer = imresize3(basalLayer,[size(basalLayer,1),size(basalLayer,2),round(size(basalLayer,3)*zScale)],'nearest');
            labelledImage = imresize3(labelledImage,[size(labelledImage,1),size(labelledImage,2),round(size(labelledImage,3)*zScale)],'nearest');
            
            if size(labelledImage,3)>size(labelledImage,1)
                apicalLayer = imresize3(apicalLayer,[size(apicalLayer,1)*zScale,size(apicalLayer,2)*zScale,round(size(apicalLayer,3))],'nearest');
                basalLayer = imresize3(basalLayer,[size(basalLayer,1)*zScale,size(basalLayer,2)*zScale,round(size(basalLayer,3))],'nearest');
                labelledImage = imresize3(labelledImage,[size(labelledImage,1)*zScale,size(labelledImage,2)*zScale,round(size(labelledImage,3))],'nearest');
            end
            
        end

        if any(size(apicalLayer)~=size(labelledImage))
            basalLayer = zeros(size(labelledImage));
            apicalLayer = zeros(size(labelledImage));
            perims = bwlabeln(bwperim(labelledImage>0));
            basalLayer(perims==1) = labelledImage(perims==1);
            apicalLayer(perims==2) = labelledImage(perims==2);
        end
        
%         2. Get raw and adjusted cell centroids
        if ~exist([folderModel '\cellCentroids.mat'],'file')
            mkdir(folderModel)
            [centroidsRaw,newCentroids] = getCentroids(labelledImage,apicalLayer,basalLayer);
            save([folderModel '\cellCentroids.mat'],'newCentroids','centroidsRaw')
        else
            load([folderModel '\cellCentroids.mat'],'newCentroids','centroidsRaw')
        end

%         3. Generate 3D Voronoi (from centroids as seeds)
        [labelledImageVoronoi_Raw] = generate3DVoronoi_bounded(centroidsRaw,labelledImage>0);
        [labelledImageVoronoi_NewSeeds] = generate3DVoronoi_bounded(newCentroids,labelledImage>0);
        save([folderModel '\cystVoronoi.mat'],'labelledImageVoronoi_Raw','labelledImageVoronoi_NewSeeds','-v7.3')
    else
        %load([folderModel '\cystVoronoi.mat'],'labelledImageVoronoi_Raw','labelledImageVoronoi_NewSeeds')
    end
    %4. Extract features from 3D Voronoi models
    
    
end
        
