%% Directory (labels)
labelsDir = '/media/pedro/6TB/jesus/NaturalVariation/DAPI_nucleos/test_pred_3_fixed/';
labelsFiles = dir(strcat(labelsDir, '*', '.mat'));

%% Directory (saving table)
tableDir = '/media/pedro/6TB/jesus/NaturalVariation/DAPI_nucleos/results.csv';

%% Directory (raw images for iminfo)
rawDir = '/media/pedro/6TB/jesus/NaturalVariation/DAPI_nucleos/7d.1B.Pha,Bcat,DAPI/crop_DAPI_norm/';

%FOR LOOP
for cyst=1:size(labelsFiles,1)

    %% Read label files
    
    load(strcat(labelsDir, labelsFiles(cyst).name));
    name = extractBetween(labelsFiles(cyst).name, 1, length(labelsFiles(cyst).name)-4);
    name = name{1};
    
    %% Read Raw Image (iminfo)
    [~, iminfo] = readStackTif(strcat(rawDir, name, '.tif'));

    
    %Image transormation
    spacingInfo = strsplit(iminfo(1,:).ImageDescription, 'spacing=');
    spacingInfo = strsplit(spacingInfo{2}, '\n');
    z_pixel = str2num(spacingInfo{1});

    x_pixel = 1/iminfo(1, :).XResolution;
    y_pixel = 1/iminfo(1, :).YResolution;
    
    %Resize (homogeneous x-y-z)
    shape = size(labelledImage);
    numRows = shape(1);
    numCols = shape(2);
    numSlices = round(shape(3)*(x_pixel/z_pixel));

    labelledImage = imresize3(labelledImage,[numRows numCols numSlices], 'nearest');
    
    %% Extract descriptors
    cellDescriptors = extract3dDescriptors(labelledImage, unique(labelledImage));
    
    %Remove 0 (background)
    cellDescriptors = cellDescriptors(2:end, :);
    
    %Unit transformation
    cellDescriptors.Volume = cellDescriptors.Volume*(x_pixel^3);
    cellDescriptors.ConvexVolume = cellDescriptors.ConvexVolume*(x_pixel^3);
    cellDescriptors.SurfaceArea = cellDescriptors.SurfaceArea*(x_pixel^2);
    cellDescriptors.PrincipalAxisLength = cellDescriptors.PrincipalAxisLength*(x_pixel);
    cellDescriptors.EquivDiameter = cellDescriptors.EquivDiameter*(x_pixel);

    
    for cell=1:size(cellDescriptors,1)
        %% Create/update table
        if ~exist('resultTable')
            resultTable = table(string(name), cellDescriptors(1, :).ID_Cell, cellDescriptors(1, :).Volume, cellDescriptors(1, :).ConvexVolume, cellDescriptors(1, :).Solidity, cellDescriptors(1, :).SurfaceArea, cellDescriptors(1, :).PrincipalAxisLength, cellDescriptors(1, :).EquivDiameter, cellDescriptors(1, :).irregularityShapeIndex);
            resultTable.Properties.VariableNames = [{'cystName'}, {'cellID'}, {'Volume'}, {'ConvexVolume'}, {'Solidity'}, {'surfaceArea'}, {'PrincipalAxisLength'}, {'equivDiameter'}, {'irregularityShapeIndex'}];
        else
            resultTable = [resultTable; {string(name), cellDescriptors(cell, :).ID_Cell, cellDescriptors(cell, :).Volume, cellDescriptors(cell, :).ConvexVolume, cellDescriptors(cell, :).Solidity, cellDescriptors(cell, :).SurfaceArea, cellDescriptors(cell, :).PrincipalAxisLength, cellDescriptors(cell, :).EquivDiameter, cellDescriptors(cell, :).irregularityShapeIndex}];
        end
    end
    
end

writetable(resultTable, tableDir);