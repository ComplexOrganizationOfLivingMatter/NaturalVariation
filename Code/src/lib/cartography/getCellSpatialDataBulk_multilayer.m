function getCellSpatialDataBulk_multilayer(originalImagesPath, fixedCystsPath, variable, savePath, saveName)
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
    validCellsArray = [];
    normXYPosArray = [];
    xyPosArray = [];
    zPosCentroidArray = [];
    polarDistrArray = [];
    polarDistArray = [];
    variableMeanArray = [];
    normVariableMeanArray = [];
    
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
        contactThreshold = 0.5;
        dilatedVx = 2;
        
        nCells = length(unique(labelledImage))-1;
        validCells = find(table2array(regionprops3(labelledImage,'Volume'))>0);
        noValidCells = [];
        
        validCells_size = find(table2array(regionprops3(labelledImage,'Volume'))>0);
        validCells_apicoBasal = intersect(unique(apicalLayer),unique(basalLayer));
        validCells = intersect(unique(validCells_size), unique(validCells_apicoBasal));
        noValidCells = setdiff(unique(labelledImage), validCells);

        try
            
            [lateral3dInfo,totalLateralCellsArea,absoluteLateralContacts] = getLateralContacts(lateralLayer,dilatedVx,contactThreshold);
                    
            %% BASAL INFO: NEIGHBOURS, PERIMETER, AREA, 
            [basal3dInfo] = calculateNeighbours3D(basalLayer, dilatedVx, basalLayer == 0);

            if size(basal3dInfo.neighbourhood,1) < size(lateral3dInfo',1)
                for nCell=size(basal3dInfo.neighbourhood,1)+1:size(lateral3dInfo',1)
                    basal3dInfo.neighbourhood{nCell}=[];
                end

            elseif size(basal3dInfo.neighbourhood,1) > size(lateral3dInfo',1)
                basal3dInfo.neighbourhood=basal3dInfo.neighbourhood(1:size(lateral3dInfo,2),1);
            end
             basal3dInfo = basal3dInfo.neighbourhood';            

%            basal3dInfo = cellfun(@(x,y) intersect(x,y),lateral3dInfo,basal3dInfo.neighbourhood','UniformOutput',false);  %% commented 20250113

            total3Dneighbours = calculateTotalNeighbours3D(labelledImage, dilatedVx, labelledImage == 0);
            total3Dneighbours = cellfun(@numel, total3Dneighbours.neighbourhood);
            
            basalCells = unique(basalLayer);
            basalCells = basalCells(basalCells>0);
            
            [~, basalPerimeter, ~, basalNeighsOfNeighs, ~] = calculatePerimeters(basalCells, [], [], basalLayer, basal3dInfo, lateralLayer, []);
            
            basal_area_cells=cell2mat(struct2cell(regionprops(basalLayer,'Area'))).';
            
            %% CONVEX VOLUME, SOLIDITY, ASPECT RATIO, SPHERICITY, NORMALIZEDVOLUME, IRREGULARITYSHAPE INDEX, 
            cells3dFeatures = extract3dDescriptors(labelledImage, unique(labelledImage));
            cells3dFeatures = cells3dFeatures(~strcmpi(cells3dFeatures.ID_Cell,'cell_0'), :);
            
            cells3dFeatures.basalPerimeter = repmat(0, size(cells3dFeatures,1), 1);
            cells3dFeatures.basalNeighsOfNeighs = repmat(0, size(cells3dFeatures,1), 1);
            cells3dFeatures.basal_NumNeighs = repmat(0, size(cells3dFeatures,1), 1);
            cells3dFeatures.basal_Area = repmat(0, size(cells3dFeatures,1), 1);
            
            for cellIx = 1:size(cells3dFeatures,1)
                currentCellId = cells3dFeatures.ID_Cell(cellIx);
                currentCellId = currentCellId{1};
                currentCellId = strsplit(currentCellId, '_');
                currentCellId = str2num(currentCellId{2});
                
                if ismember(currentCellId, basalCells)
                    cells3dFeatures.basalPerimeter(cellIx) = basalPerimeter(find(basalCells==currentCellId));
                    cells3dFeatures.basal_Area(cellIx) = basal_area_cells(find(basalCells==currentCellId));
                    cells3dFeatures.basalNeighsOfNeighs(cellIx) = (basalNeighsOfNeighs(find(basalCells==currentCellId)));
                    cells3dFeatures.basal_NumNeighs(cellIx) = length(basal3dInfo{find(basalCells==currentCellId)});
                end
            end

            cells3dFeatures.total3DNeighbours = total3Dneighbours;

            %% JOIN TABLES
            cells3dFeatures.totalBasalArea = repmat(sum(cells3dFeatures.basal_Area), size(cells3dFeatures, 1), 1);
            
            [cells3dFeatures, ~,~,~] = convertPixelsToMicrons(cells3dFeatures, cells3dFeatures, cells3dFeatures, cells3dFeatures,cells3dFeatures, pixelScale);
            
        catch
            continue
        end

        data = cells3dFeatures(:, variable).Variables;
        
        cellIDArray = cells3dFeatures.ID_Cell;
                
        try
            [normZPos, zPos, normVariableData, variableData, xyPos, normXYPos, zPosCentroid, polarDist, polarDistr] = getCellSpatialData(labelledImage, data, cellIDArray, variable, pixelScale);
        catch
            warning('check segmentation')
            continue
        end
        
        [tissue3dFeatures] = extract3dDescriptors(labelledImage>0|lumenImage>0, 1);

        cystShape = clasifyCyst(tissue3dFeatures.PrincipalAxisLength, 0.1);
        negativeCurvature = {evaluateCurvNeg(tissue3dFeatures.Solidity, 0.9)};

        cystIDArray = [cystIDArray; repmat({cystName}, [size(normZPos,2), 1])];
        cystShapeArray = [cystShapeArray; repmat({cystShape}, [size(normZPos,2), 1])];
        negativeCurvatureArray = [negativeCurvatureArray; repmat({negativeCurvature}, [size(normZPos,2), 1])];
        nCellsArray = [nCellsArray; repmat({nCells}, [size(normZPos,2), 1])];
        validCellsArray = [validCellsArray; repmat({length(validCells)}, [size(normZPos,2), 1])];
        variableMeanArray = [variableMeanArray; repmat({mean(variableData)}, [size(normZPos,2), 1])];
        normVariableMeanArray = [normVariableMeanArray; repmat({mean(normVariableData)}, [size(normZPos,2), 1])];

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
    spatialDataTable.validCells = validCellsArray;
    spatialDataTable.normZPos = normZPosArray';
    spatialDataTable.zPos = zPosArray';
    spatialDataTable.zPosCentroid = zPosCentroidArray';
    spatialDataTable.normXYPos = normXYPosArray';
    spatialDataTable.xyPos = xyPosArray';
    spatialDataTable.polarDist = polarDistArray';
    spatialDataTable.polarDistr = polarDistrArray';
    spatialDataTable.variableData = variableDataArray';
    spatialDataTable.variableDataMean = variableMeanArray;
    spatialDataTable.normVariableData = normVariableDataArray';
    spatialDataTable.normVariableDataMean = normVariableMeanArray;


    spatialDataTable = struct2table(spatialDataTable);
    spatialDataTable.Properties.VariableNames{'variableData'} = char(variable);
    spatialDataTable.Properties.VariableNames{'normVariableData'} = char(strcat(variable, '_norm'));
    spatialDataTable.Properties.VariableNames{'variableDataMean'} = char(strcat(variable, '_mean'));
    spatialDataTable.Properties.VariableNames{'normVariableDataMean'} = char(strcat(variable, '_mean_norm'));

    fileName = strcat(savePath, saveName, '_', variable, '_spatialData.xls');
    writetable(spatialDataTable,fileName);
    

end
