folderName = '7d.2C';
cropsDirectory = '/media/pedro/6TB/jesus/NaturalVariation/crops';

% Unet lumen Directory
lumenDirectory = strcat(cropsDirectory, '/', folderName, '/', folderName, '_lumen_r/');
lumenFileFormat = '.tiff';
lumenFiles = dir(strcat(lumenDirectory, '*', lumenFileFormat));

% Hollow Tissue Directory
hollowTissueDirectory = strcat(cropsDirectory, '/', folderName, '/', folderName, '_hollowTissue_rg/');
hollowTissueFileFormat = '.tiff';
hollowTissueFiles = dir(strcat(hollowTissueDirectory, '*', hollowTissueFileFormat));

% Stardist Directory
stardistDirectory = strcat(cropsDirectory, '/', folderName, '/', folderName, '_stardist/');
stardistFileFormat = '.tif';
stardistFiles = dir(strcat(stardistDirectory, '*', stardistFileFormat));

% RG Directory
rgDirectory = strcat(cropsDirectory, '/', folderName, '/', folderName, '_rg/');
rgFileFormat = '.tif';
rgFiles = dir(strcat(rgDirectory, '*', rgFileFormat));

%New shape
numRows = 128;
numCols = 128;
numSlices = 50;

imNumber_row = 5;
imNumber_col = 5;

imgCompoundStardist = zeros(imNumber_row*numRows, numCols*imNumber_col, numSlices);
imgCompoundHollowTissue = zeros(imNumber_row*numRows, numCols*imNumber_col, numSlices);
imgCompoundRG = zeros(imNumber_row*numRows, numCcdols*imNumber_col, numSlices); 
imgCompoundHollowTissueRG = zeros(imNumber_row*numRows, 2*numCols*imNumber_col, numSlices);
imgCompoundTwoStardist = zeros(imNumber_row*numRows, 2*numCols*imNumber_col, numSlices);

n=0;

for n_file = 1:length(hollowTissueFiles)
    
    hollowTissueFilename = hollowTissueFiles(n_file).name;
    hollowTissueFullFilename = fullfile(hollowTissueDirectory, hollowTissueFilename);
    [~, fileName, ~] = fileparts(hollowTissueFullFilename);

    fprintf(1, 'Processing %s\n', fileName);

    hollowTissueStackImg = readStackTif(hollowTissueFullFilename);
    stardistStackImg = readStackTif(fullfile(stardistDirectory, fileName));
    lumenStackImg = readStackTif(fullfile(lumenDirectory, strcat(fileName, lumenFileFormat)));
    rgStackImg = readStackTif(fullfile(rgDirectory, fileName));


    hollowTissueStackImg = imresize3(hollowTissueStackImg,[numRows numCols numSlices], 'nearest');
    stardistStackImg = imresize3(stardistStackImg,[numRows numCols numSlices], 'nearest');
    lumenStackImg = imresize3(lumenStackImg,[numRows numCols numSlices], 'nearest');
    rgStackImg = imresize3(rgStackImg,[numRows numCols numSlices], 'nearest');

    croppedStardistImg = cropUsingMask(stardistStackImg, hollowTissueStackImg, 0.5, 1, 0.85, true); 

    htFirstSlice = hollowTissueStackImg(:, :, 1)/255;
    htFirstSlice = insertText(htFirstSlice, [0, 0], fileName, 'TextColor', 'white');
    hollowTissueStackImg(:, :, 1) = htFirstSlice(:, :, 1)*255;

    rgFirstSlice = rgStackImg(:, :, 1)/255;
    rgFirstSlice = insertText(rgFirstSlice, [0, 0], fileName, 'TextColor', 'white');
    rgStackImg(:, :, 1) = rgFirstSlice(:, :, 1)*255;
    
    n_cols = floor(n/5);
    n_rows = n-n_cols*5;
    disp(n_rows)
    imgCompoundStardist((1+numRows*(n_rows)):numRows*(n_rows+1), (1+numCols*(n_cols)):numCols*(n_cols+1), :) = croppedStardistImg;
    imgCompoundHollowTissue((1+numRows*(n_rows)):numRows*(n_rows+1), (1+numCols*(n_cols)):numCols*(n_cols+1), :) = hollowTissueStackImg;
    imgCompoundRG((1+numRows*(n_rows)):numRows*(n_rows+1), (1+numCols*(n_cols)):numCols*(n_cols+1), :) = rgStackImg;

    n = n+1;

    if(n==(imNumber_row*imNumber_col) || n_file==length(hollowTissueFiles))
       imgCompoundHollowTissueRG(1:numRows*(imNumber_row), 1:numCols*(imNumber_col), :) = imgCompoundHollowTissue;
       imgCompoundHollowTissueRG(1:numRows*(imNumber_row), numCols*(imNumber_col)+1:2*numCols*(imNumber_col), :) = imgCompoundRG;
       imgCompoundTwoStardist(1:numRows*(imNumber_row), 1:numCols*(imNumber_col), :) = imgCompoundStardist;
       imgCompoundTwoStardist(1:numRows*(imNumber_row), numCols*(imNumber_col)+1:2*numCols*(imNumber_col), :) = imgCompoundStardist;
       volumeSegmenter(imgCompoundHollowTissueRG, imgCompoundTwoStardist);  
       
       w = waitforbuttonpress;
       imgCompoundStardist = zeros(imNumber_row*numRows, numCols*imNumber_col, numSlices);
       imgCompoundHollowTissue = zeros(imNumber_row*numRows, numCols*imNumber_col, numSlices);
       imgCompoundRG = zeros(imNumber_row*numRows, numCols*imNumber_col, numSlices);       
       n=0;
    end
    
end