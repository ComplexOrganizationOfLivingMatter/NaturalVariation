function getCellSpatialDataBulk(originalImagesPath, fixedCystsPath, variable, savePath, saveName)
    
    % Directory
    fixedCystsDir = dir(strcat(fixedCystsPath, '*.mat'));
    
    % arrays for table
    variableArray = [];
    typeArray = [];
    classArray = [];
    cystIDArray = [];
    cystShapeArray = [];
    zPosArray = [];
    normVariableDataArray = [];
    variableDataArray = [];
    normZPosArray = [];
    cellIDsArray = [];
    negativeCurvatureArray = [];
    nCellsArray = [];
    
    for cyst=1:length(fixedCystsDir)

        cystName = fixedCystsDir(cyst).name;
        cystName = strsplit(cystName, '.mat');
        cystName = cystName{1};
        disp(cystName);

        %% Load labels
        load(strcat(fixedCystsPath, cystName, '.mat'), 'labelledImage');

        %% Read rgStack and imgInfo
        [rgStackImg, imgInfo] = readStackTif(strcat(originalImagesPath, cystName, '.tif'));

        %% Extract pixel-micron relation
        xResolution = imgInfo(1).XResolution;
        yResolution = imgInfo(1).YResolution;
        spacingInfo = strsplit(imgInfo(1).ImageDescription, 'spacing=');
        spacingInfo = strsplit(spacingInfo{2}, '\n');
        z_pixel = str2num(spacingInfo{1});
        x_pixel = 1/xResolution;
        y_pixel = 1/yResolution;
        
        pixelScale = x_pixel;

        %% Get original image size
        shape = size(rgStackImg);

        %% Make homogeneous
        numRows = shape(1);
        numCols = shape(2);
        numSlices = round(shape(3)*(z_pixel/x_pixel));

        labelledImage = imresize3(labelledImage, [numRows, numCols, numSlices], 'nearest');

        principalAxisLength = regionprops3(labelledImage>1, 'PrincipalAxisLength');
        cystClassification = clasifyCyst(principalAxisLength.PrincipalAxisLength, 0.1);
        
        [apicalLayer,basalLayer,lateralLayer,lumenImage] = getApicalBasalLateralAndLumenFromCyst(labelledImage,'');
        
        %% At least the 0.5% of lateral membrane contacting with other cell to be1 considered as neighbor.
        contactThreshold = 1;
        dilatedVx = 2;

        validCells = find(table2array(regionprops3(labelledImage,'Volume'))>0);
        noValidCells = [];

        try
            [cells3dFeatures, tissue3dFeatures, ~,~, ~, ~,~, ~,~, ~, ~, apicoBasalNeighs] = obtain3DFeatures(labelledImage,apicalLayer,basalLayer,lateralLayer,lumenImage,validCells,noValidCells,'',contactThreshold, dilatedVx);
            %% Calculate Network features            
            [~ ,coefCluster,betweennessCentrality] = obtainNetworksFeatures(apicoBasalNeighs,validCells, '');
            
            [cells3dFeatures, ~,~,~] = convertPixelsToMicrons(cells3dFeatures, cells3dFeatures, cells3dFeatures, cells3dFeatures,cells3dFeatures, pixelScale);

        catch
            continue
        end
        
        
        
        if strcmp(variable, "coefCluster")
            data = coefCluster;
        elseif strcmp(variable, "betCentrality")
            data = betweennessCentrality;
        else
            data = cells3dFeatures(:, variable).Variables;
        end
        
        cellIDArray = cells3dFeatures.ID_Cell;
                
        [normZPos, zPos, normVariableData, variableData] = getCellSpatialData(labelledImage, data, cellIDArray, variable, pixelScale);
        
        cystShape = clasifyCyst(tissue3dFeatures.PrincipalAxisLength, 0.1);
        negativeCurvature = {evaluateCurvNeg(tissue3dFeatures.Solidity, 0.9)};


        cystIDArray = [cystIDArray; repmat({cystName}, [size(normZPos,2), 1])];
        cystShapeArray = [cystShapeArray; repmat({cystShape}, [size(normZPos,2), 1])];
        negativeCurvatureArray = [negativeCurvatureArray; repmat({negativeCurvature}, [size(normZPos,2), 1])];
        nCellsArray = [nCellsArray; repmat({validCells}, [size(normZPos,2), 1])];

        cellIDsArray = [cellIDsArray, cellIDArray'];
        normZPosArray = [normZPosArray, normZPos];        
        zPosArray = [zPosArray, zPos];     
        normVariableDataArray = [normVariableDataArray, normVariableData];  
        variableDataArray = [variableDataArray, variableData];

    end
    
    spatialDataTable.cystID = cellfun(@(x) string(x), cystIDArray);
    spatialDataTable.cellID = cellIDsArray';
    spatialDataTable.cystShape = cellfun(@(x) string(x), cystShapeArray);
    spatialDataTable.cystCurvature = cellfun(@(x) string(x), negativeCurvatureArray);
    spatialDataTable.nCells = nCellsArray;
    spatialDataTable.normZpos = normZPosArray';
    spatialDataTable.zPos = zPosArray';
    spatialDataTable.normVariableData = normVariableDataArray';
    spatialDataTable.variableData = variableDataArray';

    spatialDataTable = struct2table(spatialDataTable);
    
    fileName = strcat(savePath, saveName, '_', variable, '_spatialData.xls');
    writetable(spatialDataTable,fileName{1});

end
