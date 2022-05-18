function getCellSpatialStatisticsBULK(originalImagesPath, fixedCystsPath, variable, savePath, saveName)
    
    % Directory
    fixedCystsDir = dir(strcat(fixedCystsPath, '*.mat'));
    
    % arrays for table
    variableArray = [];
    typeArray = [];
    classArray = [];
    cystIDArray = [];
    
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
        else
            data = cells3dFeatures;
        end
        
        cellIDArray = cells3dFeatures.ID_Cell;
        
        [normFirstQuartilePosition, normSecondQuartilePosition, normThirdQuartilePosition, normFourthQuartilePosition] = getCellSpatialStatistics(labelledImage, data, cellIDArray, variable);
        
        cystIDArray = [cystIDArray; repmat({cystName}, [4, 1])];

        variableArray = [variableArray; normFirstQuartilePosition];
        typeArray = [typeArray; 1];
        
        variableArray = [variableArray; normSecondQuartilePosition];
        typeArray = [typeArray; 2];
        
        variableArray = [variableArray; normThirdQuartilePosition];
        typeArray = [typeArray; 3];
        
        variableArray = [variableArray; normFourthQuartilePosition];
        typeArray = [typeArray; 4];

    end
    
    classArray = repmat({'class 0'}, [size(cystIDArray, 1), 1]);

    spatialStatisticsTable.class = classArray;
    spatialStatisticsTable.cystID = cystIDArray;
    spatialStatisticsTable.variable = variableArray;
    spatialStatisticsTable.type = typeArray;
    spatialStatisticsTable = struct2table(spatialStatisticsTable);
        
    %stats
    statsDataTable = table();
    firstQuartileMean = mean(spatialStatisticsTable(spatialStatisticsTable.type==1, 'variable').variable);
    firstQuartileStd = std(spatialStatisticsTable(spatialStatisticsTable.type==1, 'variable').variable);
    secondQuartileMean = mean(spatialStatisticsTable(spatialStatisticsTable.type==2, 'variable').variable);
    secondQuartileStd = std(spatialStatisticsTable(spatialStatisticsTable.type==2, 'variable').variable);
    thirdQuartileMean = mean(spatialStatisticsTable(spatialStatisticsTable.type==3, 'variable').variable);
    thirdQuartileStd = std(spatialStatisticsTable(spatialStatisticsTable.type==3, 'variable').variable);
    fourthQuartileMean = mean(spatialStatisticsTable(spatialStatisticsTable.type==4, 'variable').variable);
    fourthQuartileStd = std(spatialStatisticsTable(spatialStatisticsTable.type==4, 'variable').variable);
    
    meanArray = [firstQuartileMean; secondQuartileMean; thirdQuartileMean; fourthQuartileMean];
    stdArray = [firstQuartileStd; secondQuartileStd; thirdQuartileStd; fourthQuartileStd];

    statsDataTable.quartile = [1; 2; 3; 4];
    statsDataTable.meanNormZpos = meanArray;
    statsDataTable.stdNormZpos = stdArray;
    
    %data for plotting
    dataTable_sheet_1 = spatialStatisticsTable(:, {'class', 'cystID', 'variable', 'type'});
    writetable(dataTable_sheet_1,strcat(savePath, saveName,'_', variable, '_stats.xls'),'Sheet','polygonDistributions');
    %data for stats
    dataTable_sheet_2 = statsDataTable(:, {'quartile', 'meanNormZpos', 'stdNormZpos'});
    writetable(dataTable_sheet_2,strcat(savePath, saveName,'_', variable, '_stats.xls'), 'Sheet','statsTable');
    
    writetable(dataTable_sheet_1,strcat(savePath, saveName, '_', variable, '_forPlotViolin.xls'));

end