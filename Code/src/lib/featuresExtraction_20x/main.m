% Table directory
tableDirectory = '..';

% Add path for reading
addpath('../');
addpath('../featuresExtraction/');

% Pixel - Micron
x_pixel = 0.6151658;
y_pixel = 0.6151658;
z_pixel = 0.7;

% Unet lumen Directory
lumenDirectory = '..';
lumenFileFormat = '.tiff';
lumenFiles = dir(strcat(lumenDirectory, '*', lumenFileFormat));

% Unet cyst Directory
cystsDirectory = '..';
cystsFileFormat = '.tiff';
cystsFiles = dir(strcat(cystsDirectory, '*', cystsFileFormat));

% Stardist Directory
stardistDirectory = '.';
stardistFileFormat = '.tif';
stardistFiles = dir(strcat(stardistDirectory, '*', stardistFileFormat));

% GreenOrig Directory
greenOrigDirectory = '..';
greenOrigFileFormat = '.tif';
greenOrigFiles = dir(strcat(greenOrigDirectory, '*', greenOrigFileFormat));

% Warning if different file number
if (length(lumenFiles) ~= length(cystsFiles)) && (length(lumenFiles) ~= length(stardistFiles))
       warning('Different number of files.');
end

% for loop on files (using lumen files as reference)
for n_file = 1:length(lumenFiles)
    try
        lumenFilename = lumenFiles(n_file).name;
        lumenFullFilename = fullfile(lumenDirectory, lumenFilename);
        [~, fileName, ~] = fileparts(lumenFullFilename);

        fprintf(1, 'Processing %s\n', fileName);

        lumenStackImg = readStackTif(lumenFullFilename);
        cystsStackImg = readStackTif(fullfile(cystsDirectory, strcat(fileName, cystsFileFormat)));
%         stardistStackImg = readStackTif(fullfile(stardistDirectory, strcat(fileName, cystsFileFormat)));
        stardistStackImg = readStackTif(fullfile(stardistDirectory, fileName));
%         greenOrigStackImg = readStackTif(fullfile(greenOrigDirectory, strcat(fileName, greenOrigFileFormat)));
        greenOrigStackImg = readStackTif(fullfile(greenOrigDirectory, fileName));

        %Resize
        shape = size(lumenStackImg);
        numRows = shape(1);
        numCols = shape(2);
        numSlices = round(shape(3)*(x_pixel/z_pixel));

        lumenStackImg = imresize3(lumenStackImg,[numRows numCols numSlices], 'nearest');
        cystsStackImg = imresize3(cystsStackImg,[numRows numCols numSlices], 'nearest');
        stardistStackImg = imresize3(stardistStackImg,[numRows numCols numSlices], 'nearest');   
        greenOrigStackImg = imresize3(greenOrigStackImg,[numRows numCols numSlices], 'nearest');   

        %Remove spare cells from stardist image
        croppedStardistImg = cropUsingMask(stardistStackImg, cystsStackImg, 0.5, 1, 0.85, true); 
        croppedStardistImg = cropUsingMask(croppedStardistImg, (255-lumenStackImg), 0.5, 1, 0.5, true); 

        numOfCells = countCells(croppedStardistImg)-1;
        writeStackTif(croppedStardistImg/255, strcat('/home/pedro/Escritorio/jesus/featuresExtraction_20x_images/test/10_test_stardist_cropped_resampled/',strcat(fileName, '.tif')));
        writeStackTif(greenOrigStackImg/255, strcat('/home/pedro/Escritorio/jesus/featuresExtraction_20x_images/test/10_test_green_resampled/',strcat(fileName, '.tif')));

        %extract3dDescriptors
        lumen3dFeatures = regionprops3(imbinarize(lumenStackImg/255, 0.3), 'PrincipalAxisLength', 'Volume', 'ConvexVolume', 'Solidity', 'SurfaceArea', 'EquivDiameter');
        lumen3dFeatures = lumen3dFeatures(lumen3dFeatures.Volume==max(lumen3dFeatures.Volume), :);

        cyst3dFeatures = regionprops3(imbinarize(cystsStackImg/255, 0.3), 'PrincipalAxisLength', 'Volume', 'ConvexVolume', 'Solidity', 'SurfaceArea', 'EquivDiameter');
        cyst3dFeatures = cyst3dFeatures(cyst3dFeatures.Volume==max(cyst3dFeatures.Volume), :);

        fullCyst3dStackImg = imfill(imbinarize(cystsStackImg/255, 0.3), 'holes');
        fullCyst3dFeatures = regionprops3(fullCyst3dStackImg, 'PrincipalAxisLength', 'Volume', 'ConvexVolume', 'Solidity', 'SurfaceArea', 'EquivDiameter');

        fullCyst3dFeatures = fullCyst3dFeatures(fullCyst3dFeatures.Volume==max(fullCyst3dFeatures.Volume), :);

        avgCellVolume =  cyst3dFeatures.Volume/numOfCells;

        %Transform units
        lumen3dFeatures.Volume = lumen3dFeatures.Volume*(x_pixel^3);
        cyst3dFeatures.Volume = cyst3dFeatures.Volume*(x_pixel^3);
        fullCyst3dFeatures.Volume = fullCyst3dFeatures.Volume*(x_pixel^3);

        avgCellVolume= avgCellVolume*(x_pixel^3);
        
        lumen3dFeatures.PrincipalAxisLength = lumen3dFeatures.PrincipalAxisLength*(x_pixel);
        cyst3dFeatures.PrincipalAxisLength = cyst3dFeatures.PrincipalAxisLength*(x_pixel);

        lumen3dFeatures.SurfaceArea = lumen3dFeatures.SurfaceArea*(x_pixel^2);
        cyst3dFeatures.SurfaceArea = cyst3dFeatures.SurfaceArea*(x_pixel^2);
        
%         volumeSegmenter(greenOrigStackImg, croppedStardistImg);
%         volumeSegmenter(cystsStackImg, croppedStardistImg);
%         volumeSegmenter(greenOrigStackImg, imbinarize(cystsStackImg, 0.5));

        %build and update table
        if n_file == 1
           table = buildTable(string(fileName), lumen3dFeatures, cyst3dFeatures, numOfCells, avgCellVolume, fullCyst3dFeatures);
        else
           table = [table; {string(fileName), numOfCells, fullCyst3dFeatures.Volume, cyst3dFeatures.Volume, lumen3dFeatures.Volume, avgCellVolume, fullCyst3dFeatures.PrincipalAxisLength, lumen3dFeatures.PrincipalAxisLength, fullCyst3dFeatures.SurfaceArea, lumen3dFeatures.SurfaceArea}];
        end
    catch
        warning('%s failed\n', fileName);
        if n_file ~= 1
           table = [table; {string(fileName), "error", "error", "error", "error", "error", ["error", "error", "error"], ["error", "error", "error"], "error", "error"}];
        end
    end

end

disp('Writting table . . .');

writetable(table, strcat(tableDirectory, 'results.csv'));

disp('End');
