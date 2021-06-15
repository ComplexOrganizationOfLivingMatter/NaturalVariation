folderName = '10d.4B';
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
stardistDirectory = strcat(cropsDirectory, '/', folderName, '/', folderName, '_stardist_bigSigma/');
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
imgCompoundRG = zeros(imNumber_row*numRows, numCols*imNumber_col, numSlices); 
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

    binaryHollowTissue = imbinarize(hollowTissueStackImg/255);
    binarylumen = imbinarize(lumenStackImg/255);

    %Get the biggest blob of each img
    binaryHollowTissue = getBiggestBlob(binaryHollowTissue);
    binarylumen = getBiggestBlob(binarylumen);

    %Close
    se = strel('sphere', 1);
    binaryHollowTissue = imdilate(binaryHollowTissue,se);
    binaryHollowTissue = imerode(binaryHollowTissue,se);
    binarylumen = imdilate(binarylumen,se);
    binarylumen = imerode(binarylumen,se);

    %create full cyst filling hollowTissue
    fullCyst3dStackImg = imfill(binaryHollowTissue, 'holes');
    binarylumen = imfill(binarylumen, 'holes');

    %define hollowTissue as fullCyst-lumen
    binaryHollowTissue = fullCyst3dStackImg-binarylumen;
    binaryHollowTissue(binaryHollowTissue<0) = 0;

    %Remove spare cells from stardist image
    croppedStardistImg = cropUsingMask(stardistStackImg, binaryHollowTissue, 1, 0.85, true);     
    
    htFirstSlice = binaryHollowTissue(:, :, 1);
    htFirstSlice = insertText(htFirstSlice, [0, 0], fileName, 'TextColor', 'white');
    binaryHollowTissue(:, :, 1) = htFirstSlice(:, :, 1);

    rgFirstSlice = rgStackImg(:, :, 1)/255;
    rgFirstSlice = insertText(rgFirstSlice, [0, 0], fileName, 'TextColor', 'white');
    rgStackImg(:, :, 1) = rgFirstSlice(:, :, 1)*255;
    
    n_cols = floor(n/5);
    n_rows = n-n_cols*5;
    disp(n_rows)
    imgCompoundStardist((1+numRows*(n_rows)):numRows*(n_rows+1), (1+numCols*(n_cols)):numCols*(n_cols+1), :) = croppedStardistImg;
    imgCompoundHollowTissue((1+numRows*(n_rows)):numRows*(n_rows+1), (1+numCols*(n_cols)):numCols*(n_cols+1), :) = binaryHollowTissue*255;
    imgCompoundRG((1+numRows*(n_rows)):numRows*(n_rows+1), (1+numCols*(n_cols)):numCols*(n_cols+1), :) = rgStackImg;

    n = n+1;

    if(n==(imNumber_row*imNumber_col) || n_file==length(hollowTissueFiles))
       imgCompoundHollowTissueRG(1:numRows*(imNumber_row), 1:numCols*(imNumber_col), :) = imgCompoundHollowTissue;
       imgCompoundHollowTissueRG(1:numRows*(imNumber_row), numCols*(imNumber_col)+1:2*numCols*(imNumber_col), :) = imgCompoundRG;
       imgCompoundTwoStardist(1:numRows*(imNumber_row), 1:numCols*(imNumber_col), :) = imgCompoundStardist;
       imgCompoundTwoStardist(1:numRows*(imNumber_row), numCols*(imNumber_col)+1:2*numCols*(imNumber_col), :) = imgCompoundStardist;
       imgCompoundTwoStardist = mod(imgCompoundTwoStardist, 255);

       volumeSegmenter(imgCompoundHollowTissueRG, imgCompoundTwoStardist);  
       

       w = waitforbuttonpress;
       imgCompoundStardist = zeros(imNumber_row*numRows, numCols*imNumber_col, numSlices);
       imgCompoundHollowTissue = zeros(imNumber_row*numRows, numCols*imNumber_col, numSlices);
       imgCompoundRG = zeros(imNumber_row*numRows, numCols*imNumber_col, numSlices);       
       n=0;
    end
    
end