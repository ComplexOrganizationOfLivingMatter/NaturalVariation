clear all; close all; addpath(genpath('..\Code'))

%1. Load final segmented cysts
pathCysts = dir('..\data\**\3d_layers_info.mat');
rootPathModels = '..\models\';
path2saveSummary = [rootPathModels 'models_'];
mkdir(rootPathModels)

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
        load([folderModel '\cystVoronoi.mat'],'labelledImageVoronoi_Raw')
%         load([folderModel '\cystVoronoi.mat'],'labelledImageVoronoi_Raw','labelledImageVoronoi_NewSeeds')
    end
%         4. Extract features from 3D Voronoi models
    load(fullfile(pathCysts(nCyst).folder,'pixelScaleOfGland.mat'),'pixelScale')
    path2saveFeatures = fullfile(folderModel,'features');
    fileName = [splittedFolder{6} '/' splittedFolder{7}];
    
    %%get apical and basal layers, and Lumen
    if ~exist([folderModel '\layersTissue.mat'],'file')
        [apicalLayer,basalLayer,lateralLayer,lumenImage] = getApicalBasalLateralAndLumenFromCyst(labelledImageVoronoi_Raw);
        save([folderModel '\layersTissue.mat'],'apicalLayer','basalLayer','lateralLayer','lumenImage','-v7.3')
    else
        if ~exist(fullfile(path2saveFeatures, 'global_3dFeatures.mat'),'file')
            load([folderModel '\layersTissue.mat'],'apicalLayer','basalLayer','lateralLayer','lumenImage')
        else
            apicalLayer=[]; basalLayer = []; lateralLayer =[]; lumenImage=[];
        end
    end
    tic
    [allGeneralInfo{nCyst},allTissues{nCyst},allLumens{nCyst},allHollowTissue3dFeatures{nCyst},allNetworkFeatures{nCyst},totalMeanCellsFeatures{nCyst},totalStdCellsFeatures{nCyst}]=calculate3DMorphologicalFeatures(labelledImageVoronoi_Raw,apicalLayer,basalLayer,lateralLayer,lumenImage,path2saveFeatures,fileName,pixelScale,contactThreshold);
    toc
end

summarizeAllTissuesProperties(allGeneralInfo,allTissues,allLumens,allHollowTissue3dFeatures,allNetworkFeatures,totalMeanCellsFeatures,totalStdCellsFeatures,path2saveSummary);
        
