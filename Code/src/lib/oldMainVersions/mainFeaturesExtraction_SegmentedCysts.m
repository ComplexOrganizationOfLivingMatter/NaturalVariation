%%main features extraction segmented Cysts
clear all
close all
addpath(genpath('..\Code'))

%1. Load final segmented cysts
pathCysts = dir('..\data\**\3d_layers_info.mat');


%Group per phenotipe 
structPaths=struct2cell(pathCysts);
idOblate4 = cellfun(@(x) contains(lower(x),'oblate 4d'),structPaths(2,:));
idOblate7 = cellfun(@(x) contains(lower(x),'oblate 7d'),structPaths(2,:));
idEllipsoid7 = cellfun(@(x) contains(lower(x),'ellipsoid 7d'),structPaths(2,:));

cellsIds = {idOblate4,idOblate7,idEllipsoid7};
phenLabels = {'Oblate4','Oblate7','Ellipsoid7'};

%At least the 0.5% of lateral membrane contacting with other cell to be
%considered as neighbor.
contactThreshold = 0.5;

for nPhen = 1:length(cellsIds)
    disp(['<<<<<<<<<< features extraction ' phenLabels{nPhen} ' >>>>>>>>>>>>>']);
    allGeneralInfo = cell(sum(cellsIds{nPhen}),1);
    allTissues = cell(sum(cellsIds{nPhen}),1);
    allLumens = cell(sum(cellsIds{nPhen}),1);
    allHollowTissue3dFeatures = cell(sum(cellsIds{nPhen}),1);
    allNetworkFeatures = cell(sum(cellsIds{nPhen}),1);
    totalMeanCellsFeatures = cell(sum(cellsIds{nPhen}),1);
    totalStdCellsFeatures = cell(sum(cellsIds{nPhen}),1);
    
    pathCystsPhenotype = pathCysts(cellsIds{nPhen},:);
    path2saveSummary = ['..\data\' phenLabels{nPhen} '_' num2str(contactThreshold) '%_'];

    parfor nCyst = 1:size(pathCystsPhenotype,1)
        
        splittedFolder = strsplit(pathCystsPhenotype(nCyst).folder,'\');
        display(splittedFolder{7})
        folderFeatures = [fullfile(pathCystsPhenotype(nCyst).folder,'Features'), num2str(contactThreshold)];
        if ~exist(folderFeatures,'dir')
            mkdir(folderFeatures);
        end

        if exist(fullfile(pathCystsPhenotype(nCyst).folder,'realSize3dLayers.mat'),'file')
            labelledImage=struct2array(load(fullfile(pathCystsPhenotype(nCyst).folder,'realSize3dLayers.mat'),'labelledImage_realSize'));
        else
            labelledImage=struct2array(load(fullfile(pathCystsPhenotype(nCyst).folder,pathCystsPhenotype(nCyst).name),'labelledImage'));
            zScale = struct2array(load(fullfile(pathCystsPhenotype(nCyst).folder,'zScaleOfGland.mat'),'zScale'));

            labelledImage = imresize3(labelledImage,[size(labelledImage,1),size(labelledImage,2),round(size(labelledImage,3)*zScale)],'nearest');
            if size(labelledImage,3)>size(labelledImage,1)
                labelledImage = imresize3(labelledImage,[size(labelledImage,1)*zScale,size(labelledImage,2)*zScale,round(size(labelledImage,3))],'nearest');
            end

        end

    %   4. Extract features from 3D Voronoi models
        pixelScale = struct2array(load(fullfile(pathCystsPhenotype(nCyst).folder,'pixelScaleOfGland.mat'),'pixelScale'));
        fileName = [splittedFolder{6} '/' splittedFolder{7}];
        %%get apical and basal layers, and Lumen
        if ~exist(fullfile(pathCystsPhenotype(nCyst).folder, '\layersTissue.mat'),'file')
            path2saveLayers = fullfile(pathCystsPhenotype(nCyst).folder, '\layersTissue.mat');
            [apicalLayer,basalLayer,lateralLayer,lumenImage] = getApicalBasalLateralAndLumenFromCyst(labelledImage,path2saveLayers);
        else
            if ~exist(fullfile(folderFeatures, 'global_3dFeatures.mat'),'file')
                allLayers = load(fullfile(pathCystsPhenotype(nCyst).folder, '\layersTissue.mat'),'apicalLayer','basalLayer','lateralLayer','lumenImage');
                apicalLayer= allLayers.apicalLayer;     basalLayer = allLayers.basalLayer;      lateralLayer = allLayers.lateralLayer;      lumenImage = allLayers.lumenImage;
            else
                apicalLayer=[]; basalLayer = []; lateralLayer =[]; lumenImage=[];
            end
        end

        [allGeneralInfo{nCyst},allTissues{nCyst},allLumens{nCyst},allHollowTissue3dFeatures{nCyst},allNetworkFeatures{nCyst},totalMeanCellsFeatures{nCyst},totalStdCellsFeatures{nCyst}]=calculate3DMorphologicalFeatures(labelledImage,apicalLayer,basalLayer,lateralLayer,lumenImage,folderFeatures,fileName,pixelScale,contactThreshold);
    end

    summarizeAllTissuesProperties(allGeneralInfo,allTissues,allLumens,allHollowTissue3dFeatures,allNetworkFeatures,totalMeanCellsFeatures,totalStdCellsFeatures,path2saveSummary);
end    
