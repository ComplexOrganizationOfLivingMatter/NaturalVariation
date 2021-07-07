%Training Dataset
trainingDatasetDir = '/media/pedro/6TB/jesus/NaturalVariation/trainingDatasetFromVoronoi/';
trainingDatasetXDir = strcat(trainingDatasetDir, 'x/');
trainingDatasetYDir = strcat(trainingDatasetDir, 'y/');
trainingDatasetYHTDir = strcat(trainingDatasetDir, 'y_ht/');
trainingDatasetYLumenDir = strcat(trainingDatasetDir, 'y_lumen/');
trainingDatasetYCellOutlineDir = strcat(trainingDatasetDir, 'y_cellOutline/');
%Voronoi Warnings table path
voronoiWarningsPath = '/media/pedro/6TB/jesus/NaturalVariation/crops/voronoi_20210618/voronoiCystWarnings_18-Jun-2021.xls';

%Read Voronoi Table
voronoiWarningsTable = readtable(voronoiWarningsPath);

% Ok voronoi table path
okVoronoiTablePath = '/media/pedro/6TB/jesus/NaturalVariation/crops/okVoronoi.xls';

%Read Ok Voronoi Table
voronoiOkTable = readtable(okVoronoiTablePath);

% Voronoi .mat files path
voronoiMatFilePath = '/media/pedro/6TB/jesus/NaturalVariation/crops/voronoi_20210618/';

% RG image filepath
rgFilePath = '/media/pedro/6TB/jesus/NaturalVariation/crops';

%Make list
voronoiCysts = voronoiWarningsTable.name;
okCysts = voronoiOkTable.name;

% Remove .mat
voronoiCysts = strrep(voronoiCysts, '.mat', '');
voronoiCystsModNames = strrep(voronoiCysts, '_', '.');

okCysts = strrep(okCysts, '.mat', '');
okCystsModNames = strrep(okCysts, '_', '.');

% Compare and filter
validCysts = voronoiWarningsTable;

%filter (4 wrong cells or less [user customizable])
validCysts = voronoiWarningsTable(ismember(voronoiWarningsTable.name, voronoiOkTable.name), :);

for cyst=1:size(validCysts, 1)
    cystName = strrep(validCysts(cyst, :).name{1}, '.tif.mat', '');
    cystFolderName = validCysts(cyst, :).folder{1};
    matFile = strcat(voronoiMatFilePath, cystFolderName, '/', cystName, '/cystVoronoi.mat');
    load(matFile)
    
    [rgStackImg, ~] = readStackTif(strcat(rgFilePath, '/', cystFolderName, '/',cystFolderName, '_rg/', cystName, '.tif'));

    %Resize (homogeneous x-y-z)
    shape = size(rgStackImg);
    numRows = shape(1);
    numCols = shape(2);
    numSlices = shape(3);
    
    labelledImage = imresize3(labelledImage,[numRows numCols numSlices], 'nearest');
    
    writeStackTif(labelledImage/255, strcat(trainingDatasetYDir, cystName, '.tif'))
    writeStackTif(rgStackImg/255, strcat(trainingDatasetXDir, cystName, '.tif'))
    
    %HT
    binaryHollowTissue = imresize3(binaryHollowTissue,[numRows numCols numSlices], 'nearest');
    writeStackTif(binaryHollowTissue, strcat(trainingDatasetYHTDir, cystName, '.tif'))
    
    %Lumen
    lumen = imfill(binaryHollowTissue, 'holes') - binaryHollowTissue;
    lumen = imresize3(lumen,[numRows numCols numSlices], 'nearest');

    writeStackTif(lumen, strcat(trainingDatasetYLumenDir, cystName, '.tif'))

    %CellOutline
    cellOutline = getCellOutlines(labelledImage);
    writeStackTif(cellOutline, strcat(trainingDatasetYCellOutlineDir, cystName, '.tif'))



end