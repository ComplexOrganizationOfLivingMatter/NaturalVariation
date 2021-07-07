% No-voronoi Warnings table path
voronoiWarningsPath = '/media/pedro/6TB/jesus/NaturalVariation/crops/no_voronoi_20210705/voronoiCystWarnings_05-Jul-2021.xls';

% No-voronoi .mat files path
voronoiMatFilePath = '/media/pedro/6TB/jesus/NaturalVariation/crops/no_voronoi_20210705/';

% RG image filepath
% rgFilePath = '/media/pedro/6TB/jesus/NaturalVariation/crops';

matDirectory = strcat('/media/pedro/6TB/jesus/NaturalVariation/validateCysts/');

%Load table
voronoiWarningsTable = readtable(voronoiWarningsPath);

%Make list
voronoiCysts = voronoiWarningsTable.name;

% Remove .mat
voronoiCysts = strrep(voronoiCysts, '.mat', '');
voronoiCystsModNames = strrep(voronoiCysts, '_', '.');

% Compare and filter
validCysts = voronoiWarningsTable;

%filter (4 wrong cells or less [user customizable])
validCysts(strcmp(validCysts.cellsNoBothSurfaces,'OPEN cyst'), :) = [];
lengths = cellfun(@(x) length(str2num(x)), validCysts.cellsNoBothSurfaces, 'UniformOutput', false);
lessThan4 = cellfun(@(x) x, lengths)<=4;
validCysts = validCysts(lessThan4, :);
errorNum = lengths(lessThan4);

%New shape
numRows = 128;
numCols = 128;
numSlices = 50;

%initialze compounds
imNumber_row = 2;
imNumber_col = 2;

imgCompoundRG = zeros(imNumber_row*numRows, numCols*imNumber_col, numSlices); 
imgCompoundLabelled = zeros(imNumber_row*numRows, numCols*imNumber_col, numSlices); 

labelledImageCompound = zeros(imNumber_row*numRows, numCols*imNumber_col, numSlices);

n=0;
%for loop
for cyst=1:size(validCysts, 1)
    cystName = strrep(validCysts(cyst, :).name{1}, '.tif.mat', '');
    cystFolderName = strsplit(cystName, '/');
    cystName = cystFolderName{2};
    cystFolderName = cystFolderName{1};
    cystName = strsplit(cystName, '.tif_itkws');
    cystName = cystName{1};

    matFile = strcat(voronoiMatFilePath, cystFolderName, '_probMap/', cystName, '.mat');
    load(matFile)
    load(strcat(matDirectory, cystName, '.mat'))
%     rgStackImg = readStackTif(strcat(rgFilePath, '/', cystFolderName, '/',cystFolderName, '_rg/', cystName, '.tif'));
%     
%     rgStackImg = imresize3(rgStackImg,[numRows numCols numSlices], 'nearest');
%     labelledImage = imresize3(labelledImage,[numRows numCols numSlices], 'nearest');

%     saveName = strcat(matDirectory, cystName, '.mat');
%     save(saveName, 'rgStackImg', 'labelledImage');
%     
    rgStackImg = tagCellOutliers(rgStackImg, labelledImage);
    rgStackImg = tagVoronoiWarnings(rgStackImg, labelledImage, validCysts(cyst, :).Variables, true);
    rgFirstSlice = rgStackImg(:, :, 1)/255;
    rgFirstSlice = insertText(rgFirstSlice, [0, 0], strcat(cystName, ' - errors: ', num2str(errorNum{cyst})), 'TextColor', 'white', 'FontSize', 6);
    rgStackImg(:, :, 1) = rgFirstSlice(:, :, 1)*255;

    n_cols = floor(n/imNumber_row);
    n_rows = n-n_cols*imNumber_col;
    disp(n_rows)
    imgCompoundRG((1+numRows*(n_rows)):numRows*(n_rows+1), (1+numCols*(n_cols)):numCols*(n_cols+1), :) = rgStackImg;
    imgCompoundLabelled((1+numRows*(n_rows)):numRows*(n_rows+1), (1+numCols*(n_cols)):numCols*(n_cols+1), :) = labelledImage;

    n = n+1;
    
    if(n==(imNumber_row*imNumber_col) || cyst==size(validCysts, 1))
       imgCompoundRG(1:numRows*(imNumber_row), 1:numCols*(imNumber_col), :) = imgCompoundRG;
       labelledImageCompound(1:numRows*(imNumber_row), 1:numCols*(imNumber_col), :) = imgCompoundLabelled;

       volumeSegmenter(imgCompoundRG, labelledImageCompound);  
       

       w = waitforbuttonpress;
       labelledImageCompound = zeros(imNumber_row*numRows, numCols*imNumber_col, numSlices);
       imgCompoundRG = zeros(imNumber_row*numRows, numCols*imNumber_col, numSlices);  
       imgCompoundLabelled = zeros(imNumber_row*numRows, numCols*imNumber_col, numSlices);  
       n=0;
    end
    
end


