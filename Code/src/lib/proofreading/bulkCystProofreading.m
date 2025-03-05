%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% bulkCystProofreading
% 
% Main code for proofreading and semiautomatic curation
% of cysts
%
% It requires .mat files from:
% saveForValidation.m
%
% and xls from:
%
% checkingSegmentedCysts.m
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% add and remove paths that might create conflicts
addpath(genpath('D:\Jesus\tutorial\NaturalVariation-main\'))

%% Last fixed Cyst.
lastFixedCyst =['']; %Example '7d.1.B.5_3.tif' // all cysts are in the same folder. That's to resume the fixing where you stopped (based on the xls)

%% No-voronoi Warnings table path
[warningsTableName, warningsPath] = uigetfile('D:\Jesus\tutorial\*.xls', 'Select warnings table');
warningsPath = strcat(warningsPath, warningsTableName);

%% Fixed cysts file path
fixedCystsFilePath = uigetdir('D:\Jesus\tutorial\', 'Select save path');
fixedCystsFilePath = strcat(fixedCystsFilePath, '\');

%% RG image filepath
cystsToFixPath = uigetdir('D:\Jesus\tutorial\', 'Select cysts to fix path');
cystsToFixPath = strcat(cystsToFixPath, '\');

%% Load table
warningsTable = readtable(warningsPath);

%% Make list
cystsToFix = warningsTable.name;

%% Remove .mat
cystsToFix = strrep(cystsToFix, '.mat', '');

%% Compare and filter
validCysts = warningsTable;

%% filter (4 wrong cells or less [user customizable])
%validCysts(strcmp(validCysts.cellsNoBothSurfaces,'OPEN cyst'), :) = [];
% lengths = cellfun(@(x) length(str2num(x)), validCysts.cellsNoBothSurfaces, 'UniformOutput', false);
% lessThan4 = cellfun(@(x) x, lengths)<=4;
% validCysts = validCysts(lessThan4, :);
% errorNum = lengths(lessThan4);

if ~isempty(lastFixedCyst)
    startCyst = find(strcmp(validCysts.name, lastFixedCyst)) + 1;
else
    startCyst = 1;
end

%% for loop
for cyst=startCyst:size(validCysts, 1)
    % Load images
    cystName = strrep(validCysts(cyst, :).name{1}, '.tif', '');

    load(strcat(cystsToFixPath, cystName, '.mat'))
    rgStackImg = rgStackImg;
    labelledImage = labelledImage;

    % Tag outliers
    [~, cellOutlier] = tagCellOutliers(rgStackImg, labelledImage);
    cellOutlierStringArray = string(cellOutlier);
    cellOutlier = strjoin(cellOutlierStringArray,',');
    
    % check cells that do not contact apical and basal surfaces
    notFoundCellsSurfaces = validCysts(cyst, :).cellsNoBothSurfaces{1};
    notFoundCellsSurfacesStringArray = string(notFoundCellsSurfaces);
    notFoundCellsSurfaces = strjoin(notFoundCellsSurfacesStringArray,',');
    
    saveCystPath = strcat(fixedCystsFilePath, cystName, '.mat');
    
    [apicalLayer,basalLayer,lateralLayer,lumenImage] = getApicalBasalLateralAndLumenFromCyst(labelledImage, '');

    disp(cystName)
    % start proofReadingCustomWindow
    proofReadingCustomWindow(rgStackImg,labelledImage,lumenImage,apicalLayer,basalLayer,[],notFoundCellsSurfaces,cellOutlier,saveCystPath);
    w = waitforbuttonpress;
end
