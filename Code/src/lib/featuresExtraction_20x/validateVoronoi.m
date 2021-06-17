%Voronoi Warnings table path
voronoiWarningsPath = '/media/pedro/6TB/jesus/NaturalVariation/crops/voronoi/voronoiCystWarnings_10-Jun-2021.xls';

% Voronoi .mat files path
voronoiMatFilePath = '/media/pedro/6TB/jesus/NaturalVariation/crops/voronoi/';

% RG image filepath
rgFilePath = '/media/pedro/6TB/jesus/NaturalVariation/crops';

%Load table
voronoiWarningsTable = readtable(voronoiWarningsPath);

%Make list
voronoiCysts = voronoiWarningsTable.name;

% Remove .mat
voronoiCysts = strrep(voronoiCysts, '.mat', '');
voronoiCystsModNames = strrep(voronoiCysts, '_', '.');

%Valid cysts table path
validCystsPath = '/media/pedro/6TB/jesus/NaturalVariation/crops/voronoi/cleanCystsSelection.csv';

%read table
validCystsTable = readtable(validCystsPath);

% Compare and filter
validCysts = voronoiWarningsTable(ismember(voronoiCystsModNames, validCystsTable.Variables), :);

%filter (4 wrong cells or less [user customizable])
lengths = cellfun(@(x) length(str2num(x)), validCysts.cellsNoBothSurfaces, 'UniformOutput', false);
lessThan4 = cellfun(@(x) x, lengths)<4;
validCysts = validCysts(lessThan4, :);

%New shape
numRows = 128;
numCols = 128;
numSlices = 50;

%initialze compounds
imNumber_row = 2;
imNumber_col = 2;

imgCompoundStardist = zeros(imNumber_row*numRows, numCols*imNumber_col, numSlices);
imgCompoundHollowTissue = zeros(imNumber_row*numRows, numCols*imNumber_col, numSlices);
imgCompoundRG = zeros(imNumber_row*numRows, numCols*imNumber_col, numSlices); 
imgCompoundLabelled = zeros(imNumber_row*numRows, numCols*imNumber_col, numSlices); 

labelledImageCompound = zeros(imNumber_row*numRows, 2*numCols*imNumber_col, numSlices);
imgCompoundTwoStardist = zeros(imNumber_row*numRows, 2*numCols*imNumber_col, numSlices);
n=0;
%for loop
for cyst=1:size(validCysts, 1)
    cystName = strrep(validCysts(cyst, :).name{1}, '.tif.mat', '');
    cystFolderName = validCysts(cyst, :).folder{1};
    matFile = strcat(voronoiMatFilePath, cystFolderName, '/', cystName, '/cystVoronoi.mat');
    load(matFile)
    
    rgStackImg = readStackTif(strcat(rgFilePath, '/', cystFolderName, '/',cystFolderName, '_rg/', cystName, '.tif'));
    
    binaryHollowTissue = imresize3(binaryHollowTissue,[numRows numCols numSlices], 'nearest');
    croppedStardistImgRelabel = imresize3(croppedStardistImgRelabel,[numRows numCols numSlices], 'nearest');
    lumenImage = imresize3(lumenImage,[numRows numCols numSlices], 'nearest');
    rgStackImg = imresize3(rgStackImg,[numRows numCols numSlices], 'nearest');
    labelledImage = imresize3(labelledImage,[numRows numCols numSlices], 'nearest');
    
    binaryHollowTissue = tagVoronoiWarnings(binaryHollowTissue, lumenImage, croppedStardistImgRelabel, labelledImage, warningCyst);

    n_cols = floor(n/imNumber_row);
    n_rows = n-n_cols*imNumber_col;
    disp(n_rows)
    imgCompoundStardist((1+numRows*(n_rows)):numRows*(n_rows+1), (1+numCols*(n_cols)):numCols*(n_cols+1), :) = croppedStardistImgRelabel;
    imgCompoundHollowTissue((1+numRows*(n_rows)):numRows*(n_rows+1), (1+numCols*(n_cols)):numCols*(n_cols+1), :) = binaryHollowTissue*255;
    imgCompoundRG((1+numRows*(n_rows)):numRows*(n_rows+1), (1+numCols*(n_cols)):numCols*(n_cols+1), :) = rgStackImg;
    imgCompoundLabelled((1+numRows*(n_rows)):numRows*(n_rows+1), (1+numCols*(n_cols)):numCols*(n_cols+1), :) = labelledImage;

    n = n+1;
    
    if(n==(imNumber_row*imNumber_col) || cyst==size(validCysts, 1))
       imgCompoundHollowTissueRG(1:numRows*(imNumber_row), 1:numCols*(imNumber_col), :) = imgCompoundHollowTissue;
       imgCompoundHollowTissueRG(1:numRows*(imNumber_row), numCols*(imNumber_col)+1:2*numCols*(imNumber_col), :) = imgCompoundRG;
       imgCompoundTwoStardist(1:numRows*(imNumber_row), 1:numCols*(imNumber_col), :) = imgCompoundStardist;
       imgCompoundTwoStardist(1:numRows*(imNumber_row), numCols*(imNumber_col)+1:2*numCols*(imNumber_col), :) = imgCompoundLabelled;
       imgCompoundTwoStardist = mod(imgCompoundTwoStardist, 255);

       volumeSegmenter(imgCompoundHollowTissueRG, imgCompoundTwoStardist);  
       

       w = waitforbuttonpress;
       imgCompoundStardist = zeros(imNumber_row*numRows, numCols*imNumber_col, numSlices);
       imgCompoundHollowTissue = zeros(imNumber_row*numRows, numCols*imNumber_col, numSlices);
       imgCompoundRG = zeros(imNumber_row*numRows, numCols*imNumber_col, numSlices);  
       imgCompoundLabelled = zeros(imNumber_row*numRows, numCols*imNumber_col, numSlices);  
       n=0;
    end
    
end

%read original image

%read warnings .mat file

%tag Voronoi warnings

%volumeSegmenter plot

%//wait//

