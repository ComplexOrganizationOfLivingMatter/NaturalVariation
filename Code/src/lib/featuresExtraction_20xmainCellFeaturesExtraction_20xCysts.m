%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% mainCellFeaturesExtraction_20XCysts
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
%+
% 5.- Extract features
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear vars
%% Add paths
addpath(genpath('/home/pedro/Escritorio/jesus/NaturalVariation/'));

%% mat files of fixed cysts

fixedCystsPath = 'F:\Carmen\';
fixedCystsPath = uigetdir(fixedCystsPath, 'Select labels (.mat or .tif) path');
fixedCystsPath = strcat(fixedCystsPath, '\');
%% original tif files of rg cysts
originalImagesPath = 'F:\Carmen\';
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

tablePath = 'F:\Carmen\';

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

    try
        [rgStackImg, imgInfo] = readStackTif(strcat(originalImagesPath, cystName, '.tif'));
    catch
        continue
    end

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
        
        validCells = find(table2array(regionprops3(labelledImage,'Volume'))>0);
        noValidCells = [];
        
        %% Obtain 3D features from Cells, Tissue, Lumen and Tissue+Lumen
        [cells3dFeatures, ~, ~, ~, ~, ~, ~, ~, ~, ~, ~, ~] = obtain3DFeatures(labelledImage,apicalLayer,basalLayer,lateralLayer,lumenImage,validCells,noValidCells,path2save,contactThreshold, dilatedVx);
        
%         [allGeneralInfo,allTissues,allLumens,allHollowTissue3dFeatures,allNetworkFeatures,totalMeanCellsFeatures,totalStdCellsFeatures]=calculate3DMorphologicalFeatures(labelledImage,apicalLayer,basalLayer,lateralLayer,lumenImage,path2save,cystName,pixelScale,contactThreshold, [], [], dilatedVx);
    catch
        warning("on")
        warning("calculate3DMorphologicalFeatures failed!")    
        warning("off")
        continue
    end
    
    
    %% ID_Cysts

    aux_table = [table(string(repmat(cystName,size(cells3dFeatures, 1),1))), cells3dFeatures];

    
    %% build and write table    
    dataTable = [dataTable; aux_table];
    
end

writetable(dataTable,tablePath);

