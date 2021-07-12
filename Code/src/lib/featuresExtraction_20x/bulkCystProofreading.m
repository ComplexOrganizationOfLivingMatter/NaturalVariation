addpath '/home/pedro/Escritorio/jesus/NaturalVariation/Code/correctionWindow/gui'

%% Last fixed Cyst.
lastFixedCyst = ''; %Example '7d.1B/7d.1.B.5_3.tif_itkws.tiff' // all cysts are in the same folder. That's to resume the fixing where you stopped (based on the xls)

%% No-voronoi Warnings table path
voronoiWarningsPath = '/media/pedro/6TB/jesus/NaturalVariation/crops/no_voronoi_20210705/voronoiCystWarnings_05-Jul-2021.xls';

%% No-voronoi .mat files path
voronoiMatFilePath = '/media/pedro/6TB/jesus/NaturalVariation/crops/no_voronoi_20210705/';

%% Fixed cysts file path
fixedCystsFilePath = '/media/pedro/6TB/jesus/NaturalVariation/fixedCysts/';

%% RG image filepath
rgFilePath = '/media/pedro/6TB/jesus/NaturalVariation/crops';

matDirectory = strcat('/media/pedro/6TB/jesus/NaturalVariation/validateCysts_reducedLumen/');

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
    %Load images
    cystName = strrep(validCysts(cyst, :).name{1}, '.tif.mat', '');
    cystFolderName = strsplit(cystName, '/');
    cystName = cystFolderName{2};
    cystFolderName = cystFolderName{1};
    cystName = strsplit(cystName, '.tif_itkws');
    cystName = cystName{1};

    matFile = strcat(voronoiMatFilePath, cystFolderName, '_probMap/', cystName, '.mat');
    load(matFile)
%     load(strcat(matDirectory, cystName, '.mat'))
    [rgStackImg, infoImg] = readStackTif(strcat(rgFilePath, '/', cystFolderName, '/',cystFolderName, '_rg/', cystName, '.tif'));
    spacingInfo = strsplit(infoImg(1,:).ImageDescription, 'spacing=');
    spacingInfo = strsplit(spacingInfo{2}, '\n');
    z_pixel = str2num(spacingInfo{1});
    saveName = strcat(matDirectory, cystName, '.mat');
    
%     rgStackImg_validation = imresize3(rgStackImg,[numRows numCols numSlices], 'nearest');
%     labelledImage_validation = imresize3(labelledImage,[numRows numCols numSlices], 'nearest');
%     labelledImage_validation = reduceLumenVolume(labelledImage_validation);
    
    %%Rescaled img
    x_pixel = 1/infoImg(1, :).XResolution;
    y_pixel = 1/infoImg(1, :).YResolution;
    shape = size(rgStackImg);
    numRows_ = shape(1);
    numCols_ = shape(2);
    numSlices_ = round(shape(3)*(x_pixel/z_pixel));
    rgStackImg_scaled = imresize3(rgStackImg,[numRows_ numCols_ numSlices_], 'nearest');
    labelledImage_scaled = imresize3(labelledImage,[numRows_ numCols_ numSlices_], 'nearest');
    labelledImage_scaled = reduceLumenVolume(labelledImage_scaled);
%     save(saveName, 'rgStackImg_scaled', 'labelledImage_scaled');

    [~, cellOutlier] = tagCellOutliers(rgStackImg, labelledImage);
    cellOutlierStringArray = string(cellOutlier);
    cellOutlier = strjoin(cellOutlierStringArray,',');
    
    notFoundCellsSurfaces = validCysts(cyst, :).cellsNoBothSurfaces{1};
    notFoundCellsSurfacesStringArray = string(notFoundCellsSurfaces);
    notFoundCellsSurfaces = strjoin(notFoundCellsSurfacesStringArray,',');
    
    saveCystPath = strcat(fixedCystsFilePath, cystName, '.mat');
    
    addpath '/home/pedro/Escritorio/jesus/NaturalVariation/Code'
    [apicalLayer,basalLayer,lateralLayer,lumenImage] = getApicalBasalLateralAndLumenFromCyst(labelledImage_scaled, '');
    
    disp(cystName)
    proofReadingCustomWindow(rgStackImg_scaled,labelledImage_scaled,lumenImage,apicalLayer,basalLayer,[],notFoundCellsSurfaces,cellOutlier,saveCystPath);
    w = waitforbuttonpress;

end


