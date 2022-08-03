function correlateVariableWithScutoidsBULK(originalImagesPath, fixedCystsPath, variable, savePath, saveName, statsQuest)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % correlateVariableWithScutoidsBULK
    % main code for using correlateViariableWithScutoids
    % THIS FUNCTION IS INTENDED TO BE LAUNCHED USING THE HOMONIMOUS _UI FILE!
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % inputs:
    % originalImagesPath: raw images path
    % fixedCystsPath: labels path
    % variable: Name of the variable e.g. "cell_height"
    % savePath: path to save the result
    % statsQuest: "NO" if general quantiles. "YES" if you want to calculate quantiles for each cyst.
    
    % Directory
    fixedCystsDir = dir(strcat(fixedCystsPath, '*.mat'));

    % initialize arrays for table
    variableArray = [];
    typeArray = [];
    classArray = [];
    cystIDArray = [];

    if strcmp(statsQuest, "NO")
        quantiles = getGeneralQuantiles(originalImagesPath, fixedCystsDir, fixedCystsPath, variable, savePath, saveName);
    else
        quantiles = [0, 0, 0];
    end

    %For each cyst, calculate and write table
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
            [cells3dFeatures, ~, ~,~, ~, ~,~, ~,~, ~, ~, apicoBasalNeighs] = obtain3DFeatures(labelledImage,apicalLayer,basalLayer,lateralLayer,lumenImage,validCells,noValidCells,'',contactThreshold, dilatedVx);
            %% Calculate Network features            
            [~ ,coefCluster,betweennessCentrality] = obtainNetworksFeatures(apicoBasalNeighs,validCells, '');
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

        [firstQuartileScutoids, secondQuartileScutoids, thirdQuartileScutoids, fourthQuartileScutoids] = correlateVariableWithScutoids(labelledImage, data, cells3dFeatures(:, "scutoids").Variables, variable, quantiles);

        cystIDArray = [cystIDArray; repmat({cystName}, [4, 1])];

        variableArray = [variableArray; firstQuartileScutoids];
        classArray = [classArray; "Q1"];

        variableArray = [variableArray; secondQuartileScutoids];
        classArray = [classArray; "Q2"];

        variableArray = [variableArray; thirdQuartileScutoids];
        classArray = [classArray; "Q3"];

        variableArray = [variableArray; fourthQuartileScutoids];
        classArray = [classArray; "Q4"];

    end

    typeArray = repmat({'type 0'}, [size(cystIDArray, 1), 1]);

    spatialStatisticsTable.class = classArray;
    spatialStatisticsTable.cystID = cystIDArray;
    spatialStatisticsTable.variable = variableArray;
    spatialStatisticsTable.type = typeArray;
    spatialStatisticsTable = struct2table(spatialStatisticsTable);

    %stats
    statsDataTable = table();
    firstQuartileMean = mean(spatialStatisticsTable(strcmp(spatialStatisticsTable.class, "Q1"), 'variable').variable);
    firstQuartileStd = std(spatialStatisticsTable(strcmp(spatialStatisticsTable.class, "Q1"), 'variable').variable);
    secondQuartileMean = mean(spatialStatisticsTable(strcmp(spatialStatisticsTable.class, "Q2"), 'variable').variable);
    secondQuartileStd = std(spatialStatisticsTable(strcmp(spatialStatisticsTable.class, "Q2"), 'variable').variable);
    thirdQuartileMean = mean(spatialStatisticsTable(strcmp(spatialStatisticsTable.class, "Q3"), 'variable').variable);
    thirdQuartileStd = std(spatialStatisticsTable(strcmp(spatialStatisticsTable.class, "Q3"), 'variable').variable);
    fourthQuartileMean = mean(spatialStatisticsTable(strcmp(spatialStatisticsTable.class, "Q4"), 'variable').variable);
    fourthQuartileStd = std(spatialStatisticsTable(strcmp(spatialStatisticsTable.class, "Q4"), 'variable').variable);

    meanArray = [firstQuartileMean; secondQuartileMean; thirdQuartileMean; fourthQuartileMean];
    stdArray = [firstQuartileStd; secondQuartileStd; thirdQuartileStd; fourthQuartileStd];

    statsDataTable.quartile = [1; 2; 3; 4];
    statsDataTable.meanNormZpos = meanArray;
    statsDataTable.stdNormZpos = stdArray;

    fileName = strcat(savePath, saveName,'_', variable, '_stats.xls');

    %data for plotting
    dataTable_sheet_1 = spatialStatisticsTable(:, {'class', 'cystID', 'variable', 'type'});
    writetable(dataTable_sheet_1,fileName{1},'Sheet','polygonDistributions');
    %data for stats
    dataTable_sheet_2 = statsDataTable(:, {'quartile', 'meanNormZpos', 'stdNormZpos'});
    writetable(dataTable_sheet_2,fileName{1}, 'Sheet','statsTable');

    fileName = strcat(savePath, saveName, '_', variable, '_forPlotViolin.xls');

    writetable(dataTable_sheet_1,fileName{1});
end
