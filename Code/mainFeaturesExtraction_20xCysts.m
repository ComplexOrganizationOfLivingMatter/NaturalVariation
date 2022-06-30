%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% mainFeaturesExtraction_20XCysts
% 
% Main code for Cysts features extraction 
%
% 1.- Load 3d labelledImage and rgStack (raw) image
%
% 2.- Check sizes and homogenize x, y and z  resolution
%
% 3.- Load pixel/voxel scale for micrometer conversion
%
% 4.- Obtain layers: apical, basal, lateral & lumen
%
% 5.- Extract features
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear vars
%% Add paths
addpath(genpath('/home/pedro/Escritorio/jesus/NaturalVariation/'));

%% mat files of fixed cysts
fixedCystsPath = 'F:\jesus\';
fixedCystsPath = uigetdir(fixedCystsPath, 'Select labels (.mat or .tif) path');
fixedCystsPath = strcat(fixedCystsPath, '\');
%% original tif files of rg cysts
originalImagesPath = 'F:\jesus\';
originalImagesPath = uigetdir(originalImagesPath, 'Select rgStack (.tif) path');
originalImagesPath = strcat(originalImagesPath, '\');

%% path 2 save output
path2save = '';

%% Directory
fixedCystsDir = dir(strcat(fixedCystsPath, '*.mat'));
if isempty(fixedCystsDir)
    fixedCystsDir = dir(strcat(fixedCystsPath, '*.tif'));
    formatFlag = '.tif';
else
    formatFlag = '.mat';
end

%% Write table path
tablePath = 'F:\jesus\';
tablePath = uigetdir(tablePath, 'Select savePath (.xls) path');

%% Select name or automatic (date)
nameQuest = questdlg('Choose name or use default (date)?', ...
	'Table name', ...
	'Choose name','Default', 'Default');

if strcmp(nameQuest,'Default')
    tablePath = strcat(tablePath, 'cysts_features_', num2str(datetime('now').Day), '_', num2str(datetime('now').Month), '_', num2str(datetime('now').Year), '.xls');
else
    prompt = 'Enter a saveName: ';
    saveName = input(prompt, 's');
    tablePath = strcat(tablePath, '\', saveName, '.xls');
end

%% Create empty table
dataTable = table();

%% for loop. All cysts
for cyst=1:length(fixedCystsDir)
    %% Extract cyst name
    cystName = fixedCystsDir(cyst).name;
    if strcmp(formatFlag, '.mat')
        cystName = strsplit(cystName, '.mat');
    else
        cystName = strsplit(cystName, '.tif');
    end

    cystName = cystName{1};
    disp(cystName);

    if strcmp(formatFlag, '.mat')
        %% Load labels
        load(strcat(fixedCystsPath, cystName, '.mat'), 'labelledImage');
    else
        labelledImage = readStackTif(strcat(fixedCystsPath, cystName, '.tif'));
    end
    
    %% Read rgStack and imgInfo
    [rgStackImg, imgInfo] = readStackTif(strcat(originalImagesPath, cystName, '.tif'));
    
    %% Extract pixel-micron relation
    xResolution = imgInfo(1).XResolution;
    yResolution = imgInfo(1).YResolution;
    spacingInfo = strsplit(imgInfo(1).ImageDescription, 'spacing=');
    spacingInfo = strsplit(spacingInfo{2}, '\n');
    z_pixel = str2num(spacingInfo{1});
    x_pixel = 1/xResolution;
    y_pixel = 1/yResolution;
    
    %% Get original image size
    shape = size(rgStackImg);

    %% Make homogeneous
    numRows = shape(1);
    numCols = shape(2);
    numSlices = round(shape(3)*(z_pixel/x_pixel));
    
    labelledImage = imresize3(labelledImage, [numRows, numCols, numSlices], 'nearest');
    
    %% Pixel scale
    pixelScale = x_pixel;

    %% Get Apical, basal and lateral layers as well as lumen
    [apicalLayer,basalLayer,lateralLayer,lumenImage] = getApicalBasalLateralAndLumenFromCyst(labelledImage,'');
    
    %% At least the 0.5% of lateral membrane contacting with other cell to be1 considered as neighbor.
    contactThreshold = 0.5;
    dilatedVx = 2;

    disp('###################################')
    disp(strcat('dilatedVx: ', num2str(dilatedVx)))
    disp(strcat('contactThreshold: ', num2str(contactThreshold)))
    disp('###################################')
    
    try
        %% Obtain 3D descriptors
        [allGeneralInfo,allTissues,allLumens,allHollowTissue3dFeatures,allNetworkFeatures,totalMeanCellsFeatures,totalStdCellsFeatures]=calculate3DMorphologicalFeatures(labelledImage,apicalLayer,basalLayer,lateralLayer,lumenImage,path2save,cystName,pixelScale,contactThreshold, [], [], dilatedVx);
    catch
        warning("on")
        warning("calculate3DMorphologicalFeatures failed!")    
        warning("off")
        continue
    end
    %% ID_Cysts
    allGeneralInfo.Properties.VariableNames{1} = 'ID_Cysts';    
    
    %% Lumen data
    allLumens.ID_Cell = [];
    allLumens.Properties.VariableNames = cellfun(@(x) strcat('lumen_', x), allLumens.Properties.VariableNames, 'UniformOutput', false);    
    
    %% Tissue data
    allTissues.ID_Cell = [];
    allTissues.Properties.VariableNames = cellfun(@(x) strcat('tissue_', x), allTissues.Properties.VariableNames, 'UniformOutput', false);    
    
    %% Tissue data
    allHollowTissue3dFeatures.ID_Cell = [];
    allHollowTissue3dFeatures.Properties.VariableNames = cellfun(@(x) strcat('hollowTissue_', x), allHollowTissue3dFeatures.Properties.VariableNames, 'UniformOutput', false);    
    
    %% Cyst Shape
    cystShape = clasifyCyst(allTissues.tissue_PrincipalAxisLength, 0.1);
    cystShape = table({cystShape}, 'VariableNames', {'cystShape'});
    
    %% perCell Volumes 
    perCell = table({allTissues.tissue_Volume/allGeneralInfo.NCells_valid}, {allLumens.lumen_Volume/allGeneralInfo.NCells_valid}, {allHollowTissue3dFeatures.hollowTissue_Volume/allGeneralInfo.NCells_valid}, 'VariableNames', {'tissueVolume_perCell', 'lumenVolume_perCell', 'hollowTissueVolume_perCell'});
    
    %%  percentage Lumen/Space
    percentageLumenSpace = table({allLumens.lumen_Volume/allTissues.tissue_Volume}, 'VariableNames', {'percentageLumenSpace'});
    
    %% negative  Curvature
    negativeCurvature = table({evaluateCurvNeg(allTissues.tissue_Solidity, 0.9)}, 'VariableNames', {'negativeCurvature'});
    
    %% build and write table
    aux_table = [allGeneralInfo, allTissues, allHollowTissue3dFeatures, allLumens, allNetworkFeatures, totalMeanCellsFeatures, totalStdCellsFeatures, cystShape, negativeCurvature, perCell, percentageLumenSpace];
    
    dataTable = [dataTable; aux_table];
    
end

% writetable(dataTable,tablePath); 

dataTable_sheet_1 = dataTable(:, {'ID_Cysts', 'cystShape', 'negativeCurvature', 'NCells_total', 'NCells_valid',   'tissue_PrincipalAxisLength', 'tissue_aspectRatio', 'hollowTissue_Volume', 'SurfaceRatio3D_areas',   'Scutoids', 'ApicoBasalTransitions',    'tissue_Solidity',  'tissue_Volume',    'tissue_ConvexVolume',  'tissue_SurfaceArea',   'tissue_sphericity',    'tissue_irregularityShapeIndex',    'tissueVolume_perCell', 'hollowTissueVolume_perCell',   'lumenVolume_perCell',  'lumen_Solidity',   'lumen_Volume', 'lumen_ConvexVolume',   'lumen_SurfaceArea',    'lumen_sphericity', 'lumen_PrincipalAxisLength', 'lumen_aspectRatio',    'lumen_irregularityShapeIndex', 'hollowTissue_Solidity',    'hollowTissue_SurfaceArea', 'hollowTissue_sphericity',  'hollowTissue_PrincipalAxisLength',   'hollowTissue_aspectRatio', 'percentageLumenSpace'});
writetable(dataTable_sheet_1,tablePath,'Sheet','globalFeatures');
dataTable_sheet_2 = dataTable(:, {'ID_Cysts', 'tissue_apical_triangles', 'tissue_apical_squares', 'tissue_apical_pentagons', 'tissue_apical_hexagons', 'tissue_apical_heptagons', 'tissue_apical_octogons', 'tissue_apical_nonagons', 'tissue_apical_decagons', 'tissue_basal_triangles', 'tissue_basal_squares', 'tissue_basal_pentagons', 'tissue_basal_hexagons', 'tissue_basal_heptagons', 'tissue_basal_octogons', 'tissue_basal_nonagons', 'tissue_basal_decagons', 'tissue_lateral_triangles', 'tissue_lateral_squares', 'tissue_lateral_pentagons', 'tissue_lateral_hexagons', 'tissue_lateral_heptagons', 'tissue_lateral_octogons', 'tissue_lateral_nonagons', 'tissue_lateral_decagons'});
writetable(dataTable_sheet_2,tablePath,'Sheet','polygonDistributions');
dataTable_sheet_3 = dataTable(:, {'ID_Cysts', 'mean_cell_apical_Area', 'mean_cell_basal_Area', 'mean_cell_lateral_Area', 'mean_cell_average_cell_wall_Area', 'mean_cell_std_cell_wall_Area', 'mean_cell_Volume', 'mean_cell_cell_height', 'mean_cell_apical_NumNeighs', 'mean_cell_basal_NumNeighs', 'mean_cell_lateral_NumNeighs', 'mean_cell_ConvexVolume', 'mean_cell_Solidity', 'mean_cell_SurfaceArea', 'mean_cell_sphericity', 'mean_cell_PrincipalAxisLength', 'mean_cell_aspectRatio', 'mean_cell_irregularityShapeIndex', 'mean_coefCluster', 'mean_betCentrality'});
writetable(dataTable_sheet_3,tablePath,'Sheet','meanCellParameters');
dataTable_sheet_4 = dataTable(:, {'ID_Cysts', 'std_cell_apical_Area', 'std_cell_basal_Area', 'std_cell_lateral_Area', 'std_cell_average_cell_wall_Area', 'std_cell_std_cell_wall_Area', 'std_cell_Volume', 'std_cell_cell_height', 'std_cell_apical_NumNeighs', 'std_cell_basal_NumNeighs', 'std_cell_lateral_NumNeighs', 'std_cell_ConvexVolume', 'std_cell_Solidity', 'std_cell_SurfaceArea', 'std_cell_sphericity', 'std_cell_PrincipalAxisLength', 'std_cell_aspectRatio', 'std_cell_irregularityShapeIndex', 'std_coefCluster', 'std_betCentrality'});
writetable(dataTable_sheet_4,tablePath,'Sheet','stdCellParameters');


