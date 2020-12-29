clear all; close all; addpath(genpath('..\Code'))

pathCysts = dir('..\data\**\3d_layers_info.mat');
rootPathModels = '..\models\';
mkdir(rootPathModels)



for nCyst = 1:size(pathCysts,1)
    splittedFolder = strsplit(pathCysts(nCyst).folder,'\');
    folderModel = fullfile(rootPathModels,splittedFolder{6},splittedFolder{7});
    display(splittedFolder{7})
    if ~exist([folderModel '\cystVoronoi.mat'],'file')
%%       1. Load labelled image (also apical and basal layers)    
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

        load(fullfile(pathCysts(nCyst).folder, '\layersTissue.mat'),'apicalLayer','basalLayer')

       
%%       2. Get raw centorids and line seeds
        if ~exist([folderModel '\cellSeeds.mat'],'file')
            mkdir(folderModel)
            [centroidsRaw,lineSeeds] = getCentroids(labelledImage,apicalLayer,basalLayer);
            clearvars apicalLayer basalLayer
            save([folderModel '\cellSeeds.mat'],'lineSeeds','centroidsRaw')
        else
            load([folderModel '\cellSeeds.mat'],'lineSeeds','centroidsRaw')
        end

%%       3. Generate 3D Voronoi (from centroids as seeds)
%         [labelledImageVoronoi_Raw] = generate3DVoronoi_bounded(centroidsRaw,labelledImage>0);
        [labelledImageVoronoi_LineSeeds] = generate3DVoronoi_bounded(lineSeeds,labelledImage>0);
%         save([folderModel '\cystVoronoi.mat'],'labelledImageVoronoi_Raw','labelledImageVoronoi_LineSeeds','-v7.3')
        save([folderModel '\cystVoronoi.mat'],'labelledImageVoronoi_LineSeeds','-v7.3')
    end    
end


%% 4. Extract features from 3D Voronoi models

%Group per phenotipe 
structPaths=struct2cell(pathCysts);
idOblate4 = cellfun(@(x) contains(lower(x),'oblate 4d'),structPaths(2,:));
idOblate7 = cellfun(@(x) contains(lower(x),'oblate 7d'),structPaths(2,:));
idEllipsoid7 = cellfun(@(x) contains(lower(x),'ellipsoid 7d'),structPaths(2,:));


%At least the 0.5% of lateral membrane contacting with other cell to be
%considered as neighbor.
contactThreshold = 0.5;

cellsIds = {idOblate4,idOblate7,idEllipsoid7};
phenLabels = {'Oblate4','Oblate7','Ellipsoid7'};
for nPhen = 1:lenght(cellsIds)
    
    allGeneralInfo = cell(sum(cellsIds{nPhen}),1);
    allTissues = cell(sum(cellsIds{nPhen}),1);
    allLumens = cell(sum(cellsIds{nPhen}),1);
    allHollowTissue3dFeatures = cell(sum(cellsIds{nPhen}),1);
    allNetworkFeatures = cell(sum(cellsIds{nPhen}),1);
    totalMeanCellsFeatures = cell(sum(cellsIds{nPhen}),1);
    totalStdCellsFeatures = cell(sum(cellsIds{nPhen}),1);
    
    pathCystsPhenotype = pathCysts(cellsIds{nPhen},:);
    
    path2saveSummary = [rootPathModels phenLabels{nPhen} '_Voronoi_LineSeeds_'];

    for nCyst = 1:size(pathCystsPhenotype,1)
        splittedFolder = strsplit(pathCystsPhenotype(nCyst).folder,'\');
        folderModel = fullfile(rootPathModels,splittedFolder{6},splittedFolder{7});
        display(splittedFolder{7})
        
    
        load(fullfile(pathCystsPhenotype(nCyst).folder,'pixelScaleOfGland.mat'),'pixelScale')
        path2saveFeatures = fullfile(folderModel,['LineSeedsVoronoi_features' num2str(contactThreshold)]);
        fileName = [splittedFolder{6} '/' splittedFolder{7}];

        %load Voronoi model
        load([folderModel '\cystVoronoi.mat'],'labelledImageVoronoi_LineSeeds')
        
        %%get apical and basal layers, and Lumen from VORONOI cyst
        if ~exist(fullfile(folderModel, '\layersTissue_lineSeeds.mat'),'file')
            [apicalLayer,basalLayer,lateralLayer,lumenImage] = getApicalBasalLateralAndLumenFromCyst(labelledImageVoronoi_LineSeeds);
            save(fullfile(pathCystsPhenotype(nCyst).folder, '\layersTissue_lineSeeds.mat'),'apicalLayer','basalLayer','lateralLayer','lumenImage','-v7.3')
        else
            if ~exist(fullfile(path2saveFeatures, 'global_3dFeatures.mat'),'file')
                load(fullfile(pathCystsPhenotype(nCyst).folder, '\layersTissue_lineSeeds.mat'),'apicalLayer','basalLayer','lateralLayer','lumenImage')
            else
                apicalLayer=[]; basalLayer = []; lateralLayer =[]; lumenImage=[];
            end
        end

        tic
        [allGeneralInfo{nCyst},allTissues{nCyst},allLumens{nCyst},allHollowTissue3dFeatures{nCyst},allNetworkFeatures{nCyst},totalMeanCellsFeatures{nCyst},totalStdCellsFeatures{nCyst}]=calculate3DMorphologicalFeatures(labelledImageVoronoi_Raw,apicalLayer,basalLayer,lateralLayer,lumenImage,path2saveFeatures,fileName,pixelScale,contactThreshold);
        toc
        
    end
    summarizeAllTissuesProperties(allGeneralInfo,allTissues,allLumens,allHollowTissue3dFeatures,allNetworkFeatures,totalMeanCellsFeatures,totalStdCellsFeatures,path2saveSummary);
end
