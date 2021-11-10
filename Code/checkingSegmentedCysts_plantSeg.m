clear all; close all; addpath(genpath('..\Code'))

pathCysts = dir('E:\Pedro\NaturalVariation\data\stardistCysts_20X\normalized\**\*.tiff');

warning('off','all')
cystToCheck = cell(size(pathCysts,1),2);

for nCyst = 1:size(pathCysts,1)

    disp(pathCysts(nCyst).name)
    
    img=readStackTif(fullfile(pathCysts(nCyst).folder,pathCysts(nCyst).name));
    
    %% Relabel 
    idLabels = unique(img(:));
    imgRelabel = zeros(size(img));
    for id = 1:length(idLabels)-1
        imgRelabel(img==idLabels(id+1))= id;
    end
        
    %% Create Voronoi cells from stardist cells
    [apicalLayer,basalLayer,lateralLayer,lumenImage] = getApicalBasalLateralAndLumenFromPlantSeg(imgRelabel,fullfile(pathCysts(nCyst).folder,strrep(pathCysts(nCyst).name,'_itkws.tiff','.mat')));

    %generate warning because possible under-detected cells "holes";
    %multilayer or cells not touching any surface
    apicalLabels = unique(apicalLayer(apicalLayer>0));
    basalLabels = unique(basalLayer(basalLayer>0));

    splitFolder = strsplit(pathCysts(nCyst).folder,'\');
    kindOfError='';
    if ~isequal(apicalLabels,basalLabels) 
        %disp([num2str(setxor(apicalLabels,basalLabels))  'cells not touching both apical and basal surfaces'])
        if sum(lumenImage(:))==0
            kindOfError= 'OPEN cyst';
        else
            kindOfError= num2str(setxor(apicalLabels,basalLabels)');
        end
    end
    
    cystToCheck{nCyst,1}=[strrep(splitFolder{end},'_probMap','/'),pathCysts(nCyst).name];            
    cystToCheck{nCyst,2} = kindOfError;
    

end

writetable(cell2table(cystToCheck,'VariableNames',{'name','cellsNoBothSurfaces'}),fullfile(pathCysts(1).folder,['voronoiCystWarnings_' date '.xls']))

% %% 4. Extract features from Voronoizated Cysts
% 
% %Group per phenotipe 
% structPaths=struct2cell(pathCysts);
% idOblate4 = cellfun(@(x) contains(lower(x),'oblate 4d'),structPaths(2,:));
% idOblate7 = cellfun(@(x) contains(lower(x),'oblate 7d'),structPaths(2,:));
% idEllipsoid7 = cellfun(@(x) contains(lower(x),'ellipsoid 7d'),structPaths(2,:));
% 
% 
% %At least the 0.5% of lateral membrane contacting with other cell to be
% %considered as neighbor.
% contactThreshold = 0.5;
% 
% 
% cellsIds = {idOblate4,idOblate7,idEllipsoid7};
% phenLabels = {'Oblate4','Oblate7','Ellipsoid7'};
% for nPhen = 1:length(cellsIds)
%     disp(['<<<<<<<<<< features extraction ' phenLabels{nPhen} ' >>>>>>>>>>>>>']);
%     allGeneralInfo = cell(sum(cellsIds{nPhen}),1);
%     allTissues = cell(sum(cellsIds{nPhen}),1);
%     allLumens = cell(sum(cellsIds{nPhen}),1);
%     allHollowTissue3dFeatures = cell(sum(cellsIds{nPhen}),1);
%     allNetworkFeatures = cell(sum(cellsIds{nPhen}),1);
%     totalMeanCellsFeatures = cell(sum(cellsIds{nPhen}),1);
%     totalStdCellsFeatures = cell(sum(cellsIds{nPhen}),1);
%     
%     pathCystsPhenotype = pathCysts(cellsIds{nPhen},:);
%     
%     path2saveSummary = [rootPathModels phenLabels{nPhen} '_VoronoizateCysts_'];
%     
%     for nCyst = 1:size(pathCystsPhenotype,1)
%         splittedFolder = strsplit(pathCystsPhenotype(nCyst).folder,'\');
%         folderModel = fullfile(rootPathModels,splittedFolder{6},splittedFolder{7});
%         display(splittedFolder{7})
%         
%         path2saveFeatures = fullfile(folderModel,['VoronoizateCyst_features' num2str(contactThreshold)]);
%         fileName = [splittedFolder{6} '/' splittedFolder{7}];
% 
%         if ~exist(fullfile(path2saveFeatures, 'global_3dFeatures.mat'),'file')
%             allLayers=load([folderModel '\cystVoronoi.mat'],'voronoiCyst','apicalLayer','basalLayer','lateralLayer','lumenImage','x_pixel');
%             apicalLayer= allLayers.apicalLayer;     basalLayer = allLayers.basalLayer;      lateralLayer = allLayers.lateralLayer;      lumenImage = allLayers.lumenImage;
%             voronoiCyst= allLayers.voronoiCyst; pixelScale=allLayers.x_pixel;
%         else
%             apicalLayer=[]; basalLayer = []; lateralLayer =[]; lumenImage=[];voronoiCyst=[];
%         end
%         
%         [allGeneralInfo{nCyst},allTissues{nCyst},allLumens{nCyst},allHollowTissue3dFeatures{nCyst},allNetworkFeatures{nCyst},totalMeanCellsFeatures{nCyst},totalStdCellsFeatures{nCyst}]=calculate3DMorphologicalFeatures(voronoiCyst,apicalLayer,basalLayer,lateralLayer,lumenImage,path2saveFeatures,fileName,pixelScale,contactThreshold);
%         
%     end
%     summarizeAllTissuesProperties(allGeneralInfo,allTissues,allLumens,allHollowTissue3dFeatures,allNetworkFeatures,totalMeanCellsFeatures,totalStdCellsFeatures,path2saveSummary);
% end
