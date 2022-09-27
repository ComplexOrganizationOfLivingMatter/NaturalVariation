function getCellSpatialDataBulk(originalImagesPath, fixedCystsPath, variable, savePath, saveName)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % getCellSpatialDataBulk
    % Function that calls getCellSpatialData and get SpatialData for each cyst
    % THIS FUNCTION IS INTENDED TO BE LAUNCHED USING THE HOMONIMOUS _UI FILE!
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % inputs:
    % originalImagesPath: path for raw images
    % fixedCystsPath: path for labels
    % variable: Name of the variable e.g. "cell_height"
    % savePath: path for saving table
    % saveName: table's name
    
    %% Directory
    fixedCystsDir = dir(strcat(fixedCystsPath, '*.mat'));
    if isempty(fixedCystsDir)
        fixedCystsDir = dir(strcat(fixedCystsPath, '*.tif'));
        formatFlag = '.tif';
    else
        formatFlag = '.mat';
    end
    
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
    normXYPosArray = [];
    xyPosArray = [];
    zPosCentroidArray = [];
    polarDistrArray = [];
    polarDistArray = [];
    
    for cyst=1:length(fixedCystsDir)

        %% Extract cyst name
        cystName = fixedCystsDir(cyst).name;
        if strcmp(formatFlag, '.mat')
            cystName = strsplit(cystName, '.mat');
        else
            cystName = strsplit(cystName, '.tif');
        end

        cystName = cystName{1};
        disp(cystName)
        
        %% Load labels
        if strcmp(formatFlag, '.mat')
            load(strcat(fixedCystsPath, cystName, '.mat'), 'labelledImage');
        else
            labelledImage = readStackTif(strcat(fixedCystsPath, cystName, '.tif'));
        end
        
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
        elseif strcmp(variable, "surfaceRatio")
            data = cells3dFeatures(:, "basal_Area").Variables./cells3dFeatures(:, "apical_Area").Variables;
        else
            data = cells3dFeatures(:, variable).Variables;
        end
        
        cellIDArray = cells3dFeatures.ID_Cell;
                
        try
            [normZPos, zPos, normVariableData, variableData, xyPos, normXYPos, zPosCentroid, polarDist, polarDistr] = getCellSpatialData(labelledImage, data, cellIDArray, variable, pixelScale);
        catch
            warning('check segmentation')
            continue
        end
        
        cystShape = clasifyCyst(tissue3dFeatures.PrincipalAxisLength, 0.1);
        negativeCurvature = {evaluateCurvNeg(tissue3dFeatures.Solidity, 0.9)};


        cystIDArray = [cystIDArray; repmat({cystName}, [size(normZPos,2), 1])];
        cystShapeArray = [cystShapeArray; repmat({cystShape}, [size(normZPos,2), 1])];
        negativeCurvatureArray = [negativeCurvatureArray; repmat({negativeCurvature}, [size(normZPos,2), 1])];
        nCellsArray = [nCellsArray; repmat({length(validCells)}, [size(normZPos,2), 1])];

        cellIDsArray = [cellIDsArray, cellIDArray'];
        normZPosArray = [normZPosArray, normZPos];      
        zPosCentroidArray = [zPosCentroidArray, zPosCentroid];        
        zPosArray = [zPosArray, zPos];     
        normXYPosArray = [normXYPosArray, normXYPos];        
        xyPosArray = [xyPosArray, xyPos];   
        normVariableDataArray = [normVariableDataArray, normVariableData];  
        variableDataArray = [variableDataArray, variableData];
        polarDistArray = [polarDistArray, polarDist];
        polarDistrArray = [polarDistrArray, polarDistr];


    end
    
    spatialDataTable.cystID = cellfun(@(x) string(x), cystIDArray);
    spatialDataTable.cellID = cellIDsArray';
    spatialDataTable.cystShape = cellfun(@(x) string(x), cystShapeArray);
    spatialDataTable.cystCurvature = cellfun(@(x) string(x), negativeCurvatureArray);
    spatialDataTable.nCells = nCellsArray;
    spatialDataTable.normZPos = normZPosArray';
    spatialDataTable.zPos = zPosArray';
    spatialDataTable.zPosCentroid = zPosCentroidArray';
    spatialDataTable.normXYPos = normXYPosArray';
    spatialDataTable.xyPos = xyPosArray';
    spatialDataTable.normVariableData = normVariableDataArray';
    spatialDataTable.variableData = variableDataArray';
    spatialDataTable.polarDist = polarDistArray';
    spatialDataTable.polarDistr = polarDistrArray';

    spatialDataTable = struct2table(spatialDataTable);
    
    fileName = strcat(savePath, saveName, '_', variable, '_spatialData.xls');
    writetable(spatialDataTable,fileName{1});

end
