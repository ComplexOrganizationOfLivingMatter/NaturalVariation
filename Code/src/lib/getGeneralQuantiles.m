function quantiles = getGeneralQuantiles(originalImagesPath, fixedCystsDir, fixedCystsPath, variable, savePath, saveName)

   alldata = [];
   fileName = strcat(savePath, saveName, '_', variable, '_generalQuantiles.xls');

   if isfile(fileName)
       quantilesTable = readtable(fileName{1});
       quantiles = [quantilesTable.firstQuantile, quantilesTable.secondQuantile, quantilesTable.thirdQuantile];
   else

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
                data = cells3dFeatures(:, variable).Variable;
            end

            alldata = [alldata; data];

        end
        firstQuantile = quantile(alldata, 0.25);
        secondQuantile = quantile(alldata, 0.5);
        thirdQuantile = quantile(alldata, 0.75);

        dataTable_sheet_1 = table();
        dataTable_sheet_1.firstQuantile = firstQuantile;
        dataTable_sheet_1.secondQuantile = secondQuantile;
        dataTable_sheet_1.thirdQuantile = thirdQuantile;

        writetable(dataTable_sheet_1,fileName{1});
        quantiles = [firstQuantile, secondQuantile, thirdQuantile];
   end
end