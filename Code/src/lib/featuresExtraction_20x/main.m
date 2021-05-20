% Table directory
tableDirectory = '/home/pedro/Escritorio/jesus/featuresExtraction_20x_images/';

% Pixel - Micron
x_pixel = 0.6151658;
y_pixel = 0.6151658;
z_pixel = 0.7;

% Unet lumen Directory
lumenDirectory = '/media/pedro/6TB/jesus/NaturalVariation/crops/4d.3b/4d.3b_lumen_r/';
lumenFileFormat = '.tiff';
lumenFiles = dir(strcat(lumenDirectory, '*', lumenFileFormat));

% Hollow Tissue Directory
hollowTissueDirectory = '/media/pedro/6TB/jesus/NaturalVariation/crops/4d.3b/4d.3b_hollowTissue_rg/';
hollowTissueFileFormat = '.tiff';
hollowTissueFiles = dir(strcat(hollowTissueDirectory, '*', hollowTissueFileFormat));

% Stardist Directory
stardistDirectory = '/media/pedro/6TB/jesus/NaturalVariation/crops/4d.3b/4d.3b_stardist/';
stardistFileFormat = '.tif';
stardistFiles = dir(strcat(stardistDirectory, '*', stardistFileFormat));

% GreenOrig Directory
% greenOrigDirectory = '/home/pedro/Escritorio/jesus/featuresExtraction_20x_images/test/10_test_green/';
% greenOrigFileFormat = '.tif';
% greenOrigFiles = dir(strcat(greenOrigDirectory, '*', greenOrigFileFormat));

% Warning if different file number
% if (length(lumenFiles) ~= length(cystsFiles)) && (length(lumenFiles) ~= length(stardistFiles))
%        warning('Different number of files.');
% end

% for loop on files (using lumen files as reference)
for n_file = 1:length(hollowTissueFiles)
    try
        hollowTissueFilename = hollowTissueFiles(n_file).name;
        hollowTissueFullFilename = fullfile(hollowTissueDirectory, hollowTissueFilename);
        [~, fileName, ~] = fileparts(hollowTissueFullFilename);

        fprintf(1, 'Processing %s\n', fileName);

        hollowTissueStackImg = readStackTif(hollowTissueFullFilename);
        stardistStackImg = readStackTif(fullfile(stardistDirectory, fileName));
        lumenStackImg = readStackTif(fullfile(lumenDirectory, strcat(fileName, lumenFileFormat)));

        %Resize
        shape = size(hollowTissueStackImg);
        numRows = shape(1);
        numCols = shape(2);
        numSlices = round(shape(3)*(x_pixel/z_pixel));

        hollowTissueStackImg = imresize3(hollowTissueStackImg,[numRows numCols numSlices], 'nearest');
        stardistStackImg = imresize3(stardistStackImg,[numRows numCols numSlices], 'nearest');   
%         greenOrigStackImg = imresize3(greenOrigStackImg,[numRows numCols numSlices], 'nearest');   

        %Remove spare cells from stardist image
        croppedStardistImg = cropUsingMask(stardistStackImg, hollowTissueStackImg, 0.5, 1, 0.85, true); 

        numOfCells = countCells(croppedStardistImg)-1;

        %extract3dDescriptors
        
        lumen3dFeatures = regionprops3(imbinarize(lumenStackImg/255), 'PrincipalAxisLength', 'Volume', 'ConvexVolume', 'Solidity', 'SurfaceArea', 'EquivDiameter');
        lumen3dFeatures = lumen3dFeatures(lumen3dFeatures.Volume==max(lumen3dFeatures.Volume), :);

        hollowTissue3dFeatures = regionprops3(imbinarize(hollowTissueStackImg/255), 'PrincipalAxisLength', 'Volume', 'ConvexVolume', 'Solidity', 'SurfaceArea', 'EquivDiameter');
        hollowTissue3dFeatures = hollowTissue3dFeatures(hollowTissue3dFeatures.Volume==max(hollowTissue3dFeatures.Volume), :);

        fullCyst3dStackImg = imfill(imbinarize(hollowTissueStackImg/255), 'holes');
        fullCyst3dFeatures = regionprops3(fullCyst3dStackImg, 'PrincipalAxisLength', 'Volume', 'ConvexVolume', 'Solidity', 'SurfaceArea', 'EquivDiameter');

        fullCyst3dFeatures = fullCyst3dFeatures(fullCyst3dFeatures.Volume==max(fullCyst3dFeatures.Volume), :);

        avgCellVolume =  (fullCyst3dFeatures.Volume-lumen3dFeatures.Volume)/numOfCells;

        %Transform units
        lumen3dFeatures.Volume = lumen3dFeatures.Volume*(x_pixel^3);
        hollowTissue3dFeatures.Volume = hollowTissue3dFeatures.Volume*(x_pixel^3);
        fullCyst3dFeatures.Volume = fullCyst3dFeatures.Volume*(x_pixel^3);

        avgCellVolume= avgCellVolume*(x_pixel^3);
        
        lumen3dFeatures.PrincipalAxisLength = lumen3dFeatures.PrincipalAxisLength*(x_pixel);
        hollowTissue3dFeatures.PrincipalAxisLength = hollowTissue3dFeatures.PrincipalAxisLength*(x_pixel);

        lumen3dFeatures.SurfaceArea = lumen3dFeatures.SurfaceArea*(x_pixel^2);
        fullCyst3dFeatures.SurfaceArea = fullCyst3dFeatures.SurfaceArea*(x_pixel^2);
        
        celularHeight = mean(fullCyst3dFeatures.PrincipalAxisLength - lumen3dFeatures.PrincipalAxisLength)/2;
        
        normalizedPrincipalAxesLength = fullCyst3dFeatures.PrincipalAxisLength/sum(fullCyst3dFeatures.PrincipalAxisLength);
         
        [class, ellipsoidFactor] = clasifyCyst(fullCyst3dFeatures.PrincipalAxisLength, 0.1);
         
        %build and update table
        if n_file == 1
           table = buildTable(string(fileName), lumen3dFeatures, hollowTissue3dFeatures, numOfCells, avgCellVolume, fullCyst3dFeatures, celularHeight, normalizedPrincipalAxesLength, class, ellipsoidFactor);
        else
           table = [table; {string(fileName), numOfCells, class, ellipsoidFactor, celularHeight, fullCyst3dFeatures.Volume, fullCyst3dFeatures.Volume-lumen3dFeatures.Volume, lumen3dFeatures.Volume, avgCellVolume, fullCyst3dFeatures.PrincipalAxisLength, normalizedPrincipalAxesLength, lumen3dFeatures.PrincipalAxisLength, fullCyst3dFeatures.SurfaceArea, lumen3dFeatures.SurfaceArea}];
        end
    catch
        warning('%s failed\n', fileName);
        if n_file ~= 1
           table = [table; {string(fileName), "error", "error", "error", "error", "error", ["error", "error", "error"], ["error", "error", "error"], "error", "error"}];
        end
    end

end

disp('Writting table . . .');

writetable(table, strcat(tableDirectory, 'results_4d.3b.csv'));

disp('End');
