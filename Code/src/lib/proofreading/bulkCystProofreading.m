addpath(genpath('D:\Github\Processing3DSegmentation\'))
rmpath 'C:\Program Files\MATLAB\R2021b\toolbox\signal\signal\'
addpath(genpath('D:\Github\NaturalVariation\'))

%% Last fixed Cyst.
lastFixedCyst = '4d.1FBS2.B.17.1.tiff'; %Example '7d.1B/7d.1.B.5_3.tif_itkws.tiff' // all cysts are in the same folder. That's to resume the fixing where you stopped (based on the xls)

%% No-voronoi Warnings table path
voronoiWarningsPath = 'D:\GitHub\NaturalVariation\data\FBS\4d_FBS_01oct\voronoiCystWarnings_01-Oct-2021.xls';

%% No-voronoi .mat files path
% voronoiMatFilePath = 'D:\GitHub\NaturalVariation\data\FBS\4d_FBS_01oct\matFiles\';

%% Fixed cysts file path
fixedCystsFilePath = 'D:\GitHub\NaturalVariation\data\FBS\4d_FBS_01oct\fixedCysts\';

%% RG image filepath
rgFilePath = 'D:\GitHub\NaturalVariation\data\FBS\4d_FBS_01oct\rgStack\';

%%
matDirectory = 'D:\GitHub\NaturalVariation\data\FBS\4d_FBS_01oct\matFiles\';

%% Load table
voronoiWarningsTable = readtable(voronoiWarningsPath);

%% Make list
voronoiCysts = voronoiWarningsTable.name;

%% Remove .mat
voronoiCysts = strrep(voronoiCysts, '.mat', '');
voronoiCystsModNames = strrep(voronoiCysts, '_', '.');

%% Compare and filter
validCysts = voronoiWarningsTable;

%% filter (4 wrong cells or less [user customizable])
validCysts(strcmp(validCysts.cellsNoBothSurfaces,'OPEN cyst'), :) = [];
lengths = cellfun(@(x) length(str2num(x)), validCysts.cellsNoBothSurfaces, 'UniformOutput', false);
lessThan4 = cellfun(@(x) x, lengths)<=4;
validCysts = validCysts(lessThan4, :);
errorNum = lengths(lessThan4);

if ~isempty(lastFixedCyst)
    startCyst = find(strcmp(validCysts.name, lastFixedCyst)) + 1;
else
    startCyst = 1;
end

%% for loop
for cyst=startCyst:size(validCysts, 1)

    %load images
    cystName = validCysts(cyst, :).name{1};
    cystName = strsplit(validCysts(cyst, :).name{1}, '.tiff');
    cystName = cystName{1};

    load(strcat(matDirectory, cystName, '.mat'))

    [~, cellOutlier] = tagCellOutliers(rgStackImg, labelledImage);
    cellOutlierStringArray = string(cellOutlier);
    cellOutlier = strjoin(cellOutlierStringArray,',');
    
    notFoundCellsSurfaces = validCysts(cyst, :).cellsNoBothSurfaces{1};
    notFoundCellsSurfacesStringArray = string(notFoundCellsSurfaces);
    notFoundCellsSurfaces = strjoin(notFoundCellsSurfacesStringArray,',');
    
    saveCystPath = strcat(fixedCystsFilePath, cystName, '.mat');
    
    [apicalLayer,basalLayer,lateralLayer,lumenImage] = getApicalBasalLateralAndLumenFromCyst(labelledImage, '');
    
    disp(cystName)
    proofReadingCustomWindow(rgStackImg,labelledImage,lumenImage,apicalLayer,basalLayer,[],notFoundCellsSurfaces,cellOutlier,saveCystPath);
    w = waitforbuttonpress;

end


