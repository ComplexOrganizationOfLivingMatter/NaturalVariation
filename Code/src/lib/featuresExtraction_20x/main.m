folders = ["4d.1a", "4d.1HX3.B","4d.2HX3.A","4d.3b", "4d.5c","7d.1B","7d.1HX3.B","7d.2C","7d.2HX3.B","7d.4c","10d.1B","10d.2b","10d.4B", "7d.3HX3"] ;
% folders = ["10d.1B"];
test = false;
label= false;
for folder_ix=1:length(folders)
    folder = folders(folder_ix);
    %% Directories
    %%%%%%%%%%%%%%%%%%%% Table directory %%%%%%%%%%%%%%%%%%%%
    tableDirectory = '/home/pedro/Escritorio/jesus/featuresExtraction_20x_images/';

    addpath '/home/pedro/Escritorio/jesus/NaturalVariation/Code/src/lib/featuresExtraction'
    %%%%%%%%%%%%%%%%%% Save Cropped Stardist %%%%%%%%%%%%%%%%%%
    saveCroppedStardist = false;
    croppedStardistDirectory = '/home/pedro/Escritorio/jesus/featuresExtraction_20x_images/';

    %%%%%%%%%%%%%%%%%%%%% Pixel - Micron %%%%%%%%%%%%%%%%%%%%
    % x_pixel = 0.6151658;
    % y_pixel = 0.6151658;
    % z_pixel = 0.7;

    %%%%%%%%%%%%%%%%%%% Unet lumen Directory %%% %%%%%%%%%%%%%
    lumenDirectory = strcat('/media/pedro/6TB/jesus/NaturalVariation/crops/', folder, '/',folder,'_lumen_r/');
    if test
        lumenDirectory = '/home/pedro/Escritorio/jesus/featuresExtraction_20x_images/test/10_test_red_predicted/';
    elseif label
        lumenDirectory = '/home/pedro/Escritorio/jesus/featuresExtraction_20x_images/test/10_test_red_label/';
    end
    lumenFileFormat = '.tiff';
    lumenFiles = dir(strcat(lumenDirectory, '*', lumenFileFormat));

    %%%%%%%%%%%%%%%%% Hollow Tissue Directory %%%%%%%%%%%%%%%
    hollowTissueDirectory = strcat('/media/pedro/6TB/jesus/NaturalVariation/crops/', folder, '/',folder,'_hollowTissue_rg/');
    if test
        hollowTissueDirectory = '/home/pedro/Escritorio/jesus/featuresExtraction_20x_images/test/10_test_rg_predicted/';
    elseif label
        hollowTissueDirectory = '/home/pedro/Escritorio/jesus/featuresExtraction_20x_images/test/10_test_green_label/';
    end
    hollowTissueFileFormat = '.tiff';
    hollowTissueFiles = dir(strcat(hollowTissueDirectory, '*', hollowTissueFileFormat));

    %%%%%%%%%%%%%%%%%%%%% Stardist Directory %%%%%%%%%%%%%%%%
    stardistDirectory = strcat('/media/pedro/6TB/jesus/NaturalVariation/crops/', folder, '/',folder,'_stardist_bigSigma/');
    if test || label
        stardistDirectory = '/home/pedro/Escritorio/jesus/featuresExtraction_20x_images/test/10_img_test_green_predicted_bigSigma/';
    end
    stardistFileFormat = '.tif'; 
    stardistFiles = dir(strcat(stardistDirectory, '*', stardistFileFormat));

    %%%%%%%%%%%%%%%%%%%%% RG Directory %%%%%%%%%%%%%%%%
    rgDirectory = strcat('/media/pedro/6TB/jesus/NaturalVariation/crops/', folder, '/',folder,'_rg/');
    if test || label
        rgDirectory = '/home/pedro/Escritorio/jesus/featuresExtraction_20x_images/test/10_test_rg/';
    end
    rgFileFormat = '.tif';
    rgFiles = dir(strcat(stardistDirectory, '*', rgFileFormat));

    %mat files directory
    matDirectory = strcat('/home/pedro/Escritorio/jesus/featuresExtraction_20x_images/matFiles/',folder, '/');
    %% Main
    % for loop on files (using lumen files as reference)
    for n_file = 1:length(hollowTissueFiles)
        try
            %Load images
            hollowTissueFilename = hollowTissueFiles(n_file).name;
            hollowTissueFullFilename = fullfile(hollowTissueDirectory, hollowTissueFilename);
            [~, fileName, ~] = fileparts(hollowTissueFullFilename);

            fprintf(1, 'Processing %s\n', fileName);

            [~, infoImg] = readStackTif(fullfile(rgDirectory, fileName));
            spacingInfo = strsplit(infoImg(1,:).ImageDescription, 'spacing=');
            spacingInfo = strsplit(spacingInfo{2}, '\n');
            z_pixel = str2num(spacingInfo{1});

            x_pixel = 1/infoImg(1, :).XResolution;
            y_pixel = 1/infoImg(1, :).YResolution;

            [hollowTissueStackImg, ~] = readStackTif(hollowTissueFullFilename);
            [stardistStackImg, ~] = readStackTif(fullfile(stardistDirectory, fileName));
            [lumenStackImg, ~] = readStackTif(fullfile(lumenDirectory, strcat(fileName, lumenFileFormat)));

            %Resize (homogeneous x-y-z)
            shape = size(hollowTissueStackImg);
            numRows = shape(1);
            numCols = shape(2);
            numSlices = round(shape(3)*(x_pixel/z_pixel));

            lumenStackImg = imresize3(lumenStackImg,[numRows numCols numSlices], 'nearest');
            hollowTissueStackImg = imresize3(hollowTissueStackImg,[numRows numCols numSlices], 'nearest');
            stardistStackImg = imresize3(stardistStackImg,[numRows numCols numSlices], 'nearest');   
        
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

            %Count cells
            numOfCells = countCells(croppedStardistImg)-1;

            %extract3dDescriptors using previous function
            lumen3dFeatures = extract3dDescriptors(binarylumen, 1);
            hollowTissue3dFeatures = extract3dDescriptors(binaryHollowTissue, 1);
            fullCyst3dFeatures = extract3dDescriptors(fullCyst3dStackImg, 1);

            %hollowTissue Volume
            hollowTissueVolume = fullCyst3dFeatures.Volume-lumen3dFeatures.Volume;
            hollowTissue3dFeatures.Volume = hollowTissueVolume;
            %Average cell volume
            avgCellVolume =  hollowTissueVolume/numOfCells;

            saveName = strcat(matDirectory, fileName, '.mat');
            save(saveName, 'binaryHollowTissue', 'croppedStardistImg', 'x_pixel');


            %Transform units
            %%% Volume
            lumen3dFeatures.Volume = lumen3dFeatures.Volume*(x_pixel^3);
            hollowTissue3dFeatures.Volume = hollowTissue3dFeatures.Volume*(x_pixel^3);
            fullCyst3dFeatures.Volume = fullCyst3dFeatures.Volume*(x_pixel^3);
            lumen3dFeatures.ConvexVolume = lumen3dFeatures.ConvexVolume*(x_pixel^3);
            hollowTissue3dFeatures.ConvexVolume = hollowTissue3dFeatures.ConvexVolume*(x_pixel^3);
            fullCyst3dFeatures.ConvexVolume = fullCyst3dFeatures.ConvexVolume*(x_pixel^3);

            avgCellVolume= avgCellVolume*(x_pixel^3);

            %%% Length
            lumen3dFeatures.PrincipalAxisLength = lumen3dFeatures.PrincipalAxisLength*(x_pixel);
            hollowTissue3dFeatures.PrincipalAxisLength = hollowTissue3dFeatures.PrincipalAxisLength*(x_pixel);

            celularHeight = mean(fullCyst3dFeatures.PrincipalAxisLength - lumen3dFeatures.PrincipalAxisLength)/2;

            normalizedPrincipalAxesLength = fullCyst3dFeatures.PrincipalAxisLength/sum(fullCyst3dFeatures.PrincipalAxisLength);
            fullCyst3dFeatures.normalizedPrincipalAxesLength = normalizedPrincipalAxesLength;

            %%% Surface
            lumen3dFeatures.SurfaceArea = lumen3dFeatures.SurfaceArea*(x_pixel^2);
            fullCyst3dFeatures.SurfaceArea = fullCyst3dFeatures.SurfaceArea*(x_pixel^2);

            %Clasify Cyst (ellipsoid/oblate/prolate/sphere)
            [class, ellipsoidFactor] = clasifyCyst(fullCyst3dFeatures.PrincipalAxisLength, 0.1);

            %Save processed images
            if saveCroppedStardist
                writeStackTif(croppedStardistImg, croppedStardistDirectory)
            end

            %Negative Curvature analysis
            curvNeg = evaluateCurvNeg(fullCyst3dFeatures.Solidity, 0.85);      

            % Warnings (individual)
            warnings = '';
            [warnings,] = checkCysts(false, string(fileName), numOfCells, fullCyst3dFeatures, hollowTissue3dFeatures, lumen3dFeatures, avgCellVolume, celularHeight, class, ellipsoidFactor, '', warnings);

            decimalPlaces = 4;
            %build and update table
            if n_file == 1
               resultTable = buildTable(string(fileName), numOfCells, fullCyst3dFeatures, hollowTissue3dFeatures, lumen3dFeatures, avgCellVolume, celularHeight, class, ellipsoidFactor, curvNeg, warnings);
            else
               resultTable = [resultTable; {string(fileName), ...
                                numOfCells,...
                                celularHeight,...
                                string(class),...
                                ellipsoidFactor,...
                                fullCyst3dFeatures.Volume,...
                                fullCyst3dFeatures.ConvexVolume,...
                                fullCyst3dFeatures.SurfaceArea, ...
                                fullCyst3dFeatures.PrincipalAxisLength,...
                                fullCyst3dFeatures.normalizedPrincipalAxesLength, ...
                                fullCyst3dFeatures.aspectRatio,...
                                fullCyst3dFeatures.sphericity,...
                                fullCyst3dFeatures.Solidity,...
                                fullCyst3dFeatures.irregularityShapeIndex,...
                                fullCyst3dFeatures.Volume/numOfCells,...
                                fullCyst3dFeatures.SurfaceArea/lumen3dFeatures.SurfaceArea,...
                                fullCyst3dFeatures.SurfaceArea/numOfCells,...
                                hollowTissue3dFeatures.Volume,...
                                hollowTissue3dFeatures.SurfaceArea,...
                                hollowTissue3dFeatures.aspectRatio,...
                                hollowTissue3dFeatures.sphericity,...
                                hollowTissue3dFeatures.Solidity, ...
                                hollowTissue3dFeatures.irregularityShapeIndex,...
                                hollowTissue3dFeatures.Volume/numOfCells,...
                                lumen3dFeatures.Volume, ...
                                lumen3dFeatures.ConvexVolume,...
                                lumen3dFeatures.SurfaceArea,...
                                lumen3dFeatures.PrincipalAxisLength,...
                                lumen3dFeatures.aspectRatio,...
                                lumen3dFeatures.sphericity,...
                                lumen3dFeatures.Solidity, ...
                                lumen3dFeatures.irregularityShapeIndex,...
                                lumen3dFeatures.Volume/numOfCells,...
                                lumen3dFeatures.SurfaceArea/numOfCells,...
                                lumen3dFeatures.Volume/fullCyst3dFeatures.Volume,...
                                string(curvNeg),...
                                string(warnings)}]; 
            end
        catch
            warning('%s failed\n', fileName);
        end

    end


    %% Warnings (bulk)
    [~,resultTable] = checkCysts(true, string(fileName), numOfCells, fullCyst3dFeatures, hollowTissue3dFeatures, lumen3dFeatures, avgCellVolume, celularHeight, class, ellipsoidFactor, resultTable, warnings);

    %% Write table
    disp('Writting table . . .');
    
    if label
        folder = 'label';
    else test
        folder = 'test';
    end
    writetable(resultTable, strcat(tableDirectory, strcat('results_', folder,'.csv')));
    clearvars -except folders test label

    disp('End');
end
