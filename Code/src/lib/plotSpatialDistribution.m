function plotSpatialDistribution(rgStackPath, labelsPath, variable, savePath, saveName)
    
    rgStackPath = strcat(rgStackPath, '/');
    labelsPath = strcat(labelsPath, '/');
  
    labelsDir = dir(strcat(labelsPath, '*.mat'));
    
    layout = uint8(zeros([413*size(labelsDir, 1),570*3, 3]));
    
    spatialStatisticsTable = table();
    meanScutoidZPosArray = [];
    cystIDArrayCyst = [];

    for labelIx = 1:size(labelsDir, 1)
        
        load(strcat(labelsPath, labelsDir(labelIx).name));
        name = strsplit(labelsDir(labelIx).name, '.mat');
        disp(name{1})

        [rgStackImg, imgInfo] = readStackTif(strcat(rgStackPath, name{1}, '.tif'));

        validCells = [];
        cystName = imgInfo(1).Filename;
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
        rgStackImg = imresize3(rgStackImg, [numRows, numCols, numSlices], 'nearest');

        %% Pixel scale
        pixelScale = x_pixel;

        %% Get Apical, basal and lateral layers as well as lumen
        [apicalLayer,basalLayer,lateralLayer,lumenImage] = getApicalBasalLateralAndLumenFromCyst(labelledImage,'');

        %% At least the 0.5% of lateral membrane contacting with other cell to be1 considered as neighbor.
        contactThreshold = 1;
        dilatedVx = 2;

        if isempty(validCells)
            validCells = find(table2array(regionprops3(labelledImage,'Volume'))>0);
            noValidCells = [];
        end

        %% Obtain 3D features from Cells, Tissue, Lumen and Tissue+Lumen
        try
            [cells3dFeatures, ~, ~,~, ~, ~,~, ~,~, ~, ~, apicoBasalNeighs] = obtain3DFeatures(labelledImage,apicalLayer,basalLayer,lateralLayer,lumenImage,validCells,noValidCells,'',contactThreshold, dilatedVx);
            %% Calculate Network features            
            [degreeNodesCorrelation,coefCluster,betweennessCentrality] = obtainNetworksFeatures(apicoBasalNeighs,validCells, '');
            
            [cells3dFeatures, ~,~,~] = convertPixelsToMicrons(cells3dFeatures, cells3dFeatures, cells3dFeatures, cells3dFeatures,cells3dFeatures, pixelScale);

        catch
            warning("ERROR")
            disp(cystName)
            continue
        end
        if variable == "scutoids"
            colours = [];
            maxValue = 1;
            minValue = 0;
            scu = 0;
            uniqueLabels = unique(labelledImage);
            for cellIx = 1:size(cells3dFeatures, 1)
                if cells3dFeatures.scutoids(cellIx) == 1
                    scu = scu + 1;
                    colours = [colours; [1,0,0]];
                else
                    colours = [colours; [0,1,0]];
                end
            end
            disp(strcat('scutoids: ', num2str(scu/size(cells3dFeatures, 1))));
        elseif variable == "surfaceRatio"
            surfaceRatio = cells3dFeatures(:, "basal_Area").Variables./cells3dFeatures(:, "apical_Area").Variables;
            colours = [];
            for cellIx = 1:size(cells3dFeatures, 1)
                maxValue = max(surfaceRatio);
                minValue = min(surfaceRatio);

                cMap1 = interp1([0;0.5],[0 1 0; 1 1 0],linspace(0,0.5,50));
                cMap2 = interp1([0.5;1],[1 1 0; 1 0 0],linspace(0.5,1,50));
                cMap = [cMap1; cMap2];
                cMapIndex = round(100*(surfaceRatio(cellIx)-minValue)/(maxValue-minValue));
                if cMapIndex == 0 || isnan(cMapIndex)
                    cMapIndex = 1;
                end
                colours = [colours; cMap(cMapIndex, :)];
            end
        elseif variable == "betCentrality"
            colours = [];
            for cellIx = 1:size(cells3dFeatures, 1)
                maxValue = max(betweennessCentrality);
                minValue = min(betweennessCentrality);

                cMap1 = interp1([0;0.5],[0 1 0; 1 1 0],linspace(0,0.5,50));
                cMap2 = interp1([0.5;1],[1 1 0; 1 0 0],linspace(0.5,1,50));
                cMap = [cMap1; cMap2];
                cMapIndex = round(100*(betweennessCentrality(cellIx)-minValue)/(maxValue-minValue));
                if cMapIndex == 0 || isnan(cMapIndex)
                    cMapIndex = 1;
                end
                colours = [colours; cMap(cMapIndex, :)];
            end
        elseif variable == "coefCluster"
            colours = [];
            for cellIx = 1:size(cells3dFeatures, 1)
                maxValue = max(coefCluster);
                minValue = min(coefCluster);

                cMap1 = interp1([0;0.5],[0 1 0; 1 1 0],linspace(0,0.5,50));
                cMap2 = interp1([0.5;1],[1 1 0; 1 0 0],linspace(0.5,1,50));
                cMap = [cMap1; cMap2];                cMapIndex = round(100*(coefCluster(cellIx)-minValue)/(maxValue-minValue));
                if cMapIndex == 0 || isnan(cMapIndex)
                    cMapIndex = 1;
                end
                colours = [colours; cMap(cMapIndex, :)];
            end
        else
            colours = [];
            for cellIx = 1:size(cells3dFeatures, 1)
                maxValue = max(cells3dFeatures(:, variable).Variables);
                minValue = min(cells3dFeatures(:, variable).Variables);

                cMap1 = interp1([0;0.5],[0 1 0; 1 1 0],linspace(0,0.5,50));
                cMap2 = interp1([0.5;1],[1 1 0; 1 0 0],linspace(0.5,1,50));
                cMap = [cMap1; cMap2];                cMapIndex = round(100*(cells3dFeatures(cellIx, variable).Variables-minValue)/(maxValue-minValue));
                if cMapIndex == 0 || isnan(cMapIndex)
                    cMapIndex = 1;
                end
                colours = [colours; cMap(cMapIndex, :)];
            end
        end
        
        %Units
        if contains(variable, 'height') || contains(variable, 'Height')
            units = "\mum";
        elseif contains(variable, 'area') || contains(variable, 'Area')
            units = "\mum^2";
        elseif contains(variable, 'volume') || contains(variable, 'Volume')
            units = "\mum^3";
        else
            units = "";
        end
        
        
        paint3D(labelledImage, validCells, colours, 3);
        material([0.5 0.2 0.0 10 1])
        fig = get(groot,'CurrentFigure');
        fig.Color = [1 1 1];
        camlight('headlight');
        
        if ~strcmp(variable, "scutoids")
            %colorBar
            colormap(cMap)
            caxis([minValue,maxValue])
            colorbarHandler=colorbar;
            title(colorbarHandler, units);
            colorbarHandler.Label.String = strrep(variable, "_", " ");
        end
        
        %first render
        frame = getframe(fig);      % Grab the rendered frame
        renderedFrontImage = frame.cdata;    % This is the rendered image
        renderedFrontImage = imresize(renderedFrontImage, [413, 570]);
        
        %second render
        camorbit(180, 0)
        camlight('headlight') 
        frame = getframe(fig);      % Grab the rendered frame
        renderedBackImage = frame.cdata;    % This is the rendered image
        renderedBackImage = imresize(renderedBackImage, [413, 570]);

        %third render
        camorbit(0, -90)
        camlight('headlight') 
        frame = getframe(fig);      % Grab the rendered frame
        renderedBottomImage = frame.cdata;    % This is the rendered image
        renderedBottomImage = imresize(renderedBottomImage, [413, 570]);

        %% Insert text
        renderedFrontImage = insertText(renderedFrontImage,[1, 1],name{1},'FontSize',18,'BoxOpacity',0.4,'TextColor','black', 'BoxColor', 'white');
        renderedFrontImage = insertText(renderedFrontImage,[1, 40],variable,'FontSize',18,'BoxOpacity',0.4,'TextColor','black', 'BoxColor', 'white');
        renderedFrontImage = insertText(renderedFrontImage,[390, 1],'FRONT','FontSize',18,'BoxOpacity',0.4,'TextColor','black', 'BoxColor', 'white');
        renderedBackImage = insertText(renderedBackImage,[390, 1],'BACK','FontSize',18,'BoxOpacity',0.4,'TextColor','black',  'BoxColor', 'white');
        renderedBottomImage = insertText(renderedBottomImage,[390, 1],'BOTTOM','FontSize',18,'BoxOpacity',0.4,'TextColor','black',  'BoxColor', 'white');

        layout(413*(labelIx-1)+1:413*(labelIx),1:570,:) = renderedFrontImage;
        layout(413*(labelIx-1)+1:413*(labelIx), 571:570*2, :) = renderedBackImage;
        layout(413*(labelIx-1)+1:413*(labelIx), 570*2+1:end, :) = renderedBottomImage;

        close(fig)
        
%         principalAxisLength = regionprops3(labelledImage>1, 'PrincipalAxisLength');
%         cystClassification = clasifyCyst(principalAxisLength.PrincipalAxisLength, 0.1);
%         
% 
%         meanScutoidZPos = getCellSpatialStatistics(labelledImage, cells3dFeatures);
%         cystIDArray = repmat({cystName}, [size(meanScutoidZPos, 2), 1]);
%         cystType = repmat(cystClassification, [size(meanScutoidZPos, 2), 1]);
%         cystTypeArray = [cystTypeArray, cystType];
%         meanScutoidZPosArray = [meanScutoidZPosArray, meanScutoidZPos];
%         cystIDArrayCyst = [cystIDArrayCyst, cystIDArray];

%         spatialStatisticsTable.cystID(labelIx) = {cystName};
%         spatialStatisticsTable.meanScutoidZPos(labelIx) = {meanScutoidZPos};
%         spatialStatisticsTable.expName(labelIx) = {saveName};
%         spatialStatisticsTable.cystClassification(labelIx) = {cystClassification};


    end
    
%     cystTagArray = repmat({saveName}, [size(meanScutoidZPosArray, 2), 1]);
%     spatialStatisticsTable.cystID = cystIDArray;
%     spatialStatisticsTable.scutoidZPos = meanScutoidZPosArray(1, :)';
%     spatialStatisticsTable.expName = cystTagArray;
%     spatialStatisticsTable.cystClassification = cystTypeArray;

%     if statQuest=="NO"
        imwrite(layout, strcat(savePath, '/', saveName, '_', variable,'.bmp'),'bmp');
        imwrite(layout, strcat(savePath, '/', saveName, '_', variable,'.png'),'png');
        save(strcat(savePath, '/', saveName, '_', variable, '.mat'), 'layout');
%     end
    writetable(spatialStatisticsTable,strcat(savePath, '/', saveName, '_', variable, '.csv'))
    
end
