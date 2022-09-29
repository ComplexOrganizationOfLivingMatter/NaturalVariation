function plotSpatialDistribution(rgStackPath, labelsPath, variable, savePath, saveName)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % plotSpatialDistribution
    % Plotting cysts stamps
    % THIS FUNCTION IS INTENDED TO BE LAUNCHED USING THE HOMONIMOUS _UI FILE!
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % inputs:
    % rgStackPath: raw images path
    % labelsPath: labels path
    % variable: Name of the variable e.g. "cell_height"
    % savePath: path to save table (unused)
    % saveName: name to save table (unused)
    
    rgStackPath = strcat(rgStackPath, '\');
    labelsPath = strcat(labelsPath, '\');
  
    %% Directory
    labelsDir = dir(strcat(labelsPath, '*.mat'));
    if isempty(labelsDir)
        labelsDir = dir(strcat(labelsPath, '*.tif'));
        formatFlag = '.tif';
    else
        formatFlag = '.mat';
    end

    layout = uint8(zeros([413*size(labelsDir, 1),570*3, 3]));
    
    spatialStatisticsTable = table();
    meanScutoidZPosArray = [];
    cystIDArrayCyst = [];

    for labelIx = 1:size(labelsDir, 1)
        %% Extract cyst name
        cystName = labelsDir(labelIx).name;
        if strcmp(formatFlag, '.mat')
            cystName = strsplit(cystName, '.mat');
        else
            cystName = strsplit(cystName, '.tif');
        end
        
        cystName = cystName{1};
        disp(cystName);
        name = cystName;
        
        if strcmp(formatFlag, '.mat')
            %% Load labels
            load(strcat(labelsPath, cystName, '.mat'), 'labelledImage');
        else
            labelledImage = readStackTif(strcat(labelsPath, cystName, '.tif'));
        end

        [rgStackImg, imgInfo] = readStackTif(strcat(rgStackPath, cystName, '.tif'));

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
        contactThreshold = 0.5;
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
                    colours = [colours; [0.3,0.3,0.3]];
                else
                    colours = [colours; [0.9, 0.9, 0.9]];
                end
            end
            disp(strcat('scutoids: ', num2str(scu/size(cells3dFeatures, 1))));
        elseif variable == "surfaceRatio"
            surfaceRatio = cells3dFeatures(:, "basal_Area").Variables./cells3dFeatures(:, "apical_Area").Variables;
            colours = [];
            for cellIx = 1:size(cells3dFeatures, 1)
                maxValue = max(surfaceRatio);
                minValue = min(surfaceRatio);

             cMap1 = interp1([0;0.5],[1 0.84 0.150; 1 0.28 0.65],linspace(0,0.5,50));
             cMap2 = interp1([0.5;1],[1 0.28 0.6; 0.41 0.28 0.55],linspace(0.5,1,50));
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

                cMap1 = interp1([0;0.5],[0 0 1; 1 1 0],linspace(0,0.5,50));
                cMap2 = interp1([0.5;1],[1 1 0; 1 0 0],linspace(0.5,1,50));
                cMap = [cMap1; cMap2];                cMapIndex = round(100*(coefCluster(cellIx)-minValue)/(maxValue-minValue));
                if cMapIndex == 0 || isnan(cMapIndex)
                    cMapIndex = 1;
                end
                colours = [colours; cMap(cMapIndex, :)];
            end
        elseif variable == "GRAY"
            colours = [];
            for cellIx = 1:size(cells3dFeatures, 1)
                colours = [colours; [0.9,0.9,0.9]];
            end
        else
            colours = [];
            for cellIx = 1:size(cells3dFeatures, 1)
                maxValue = max(cells3dFeatures(:, variable).Variables);
                minValue = min(cells3dFeatures(:, variable).Variables);

                
        cMap1 = interp1([0;0.5],[1 0.84 0.150; 1 0.28 0.65],linspace(0,0.5,50));
        cMap2 = interp1([0.5;1],[1 0.28 0.6; 0.41 0.28 0.55],linspace(0.5,1,50));

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
        
        
        paint3D(labelledImage, validCells, colours, 3, 2);
        material([0.5 0.2 0.0 10 1])
        fig = get(groot,'CurrentFigure');
        fig.Color = [1 1 1];
        delete(findall(gcf,'Type','light'));
        camlight('headlight', 'infinite');
        camlight('headlight', 'infinite');
        camlight('headlight', 'infinite');

        if ~strcmp(variable, "scutoids") && ~strcmp(variable, "GRAY")
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
        delete(findall(gcf,'Type','light'));
        camlight('headlight', 'infinite');
        camlight('headlight', 'infinite');
        camlight('headlight', 'infinite');
        renderedFrontImage = imresize(renderedFrontImage, [413, 570]);

        %second render
        camorbit(180, 0)
        delete(findall(gcf,'Type','light'));
        camlight('headlight', 'infinite');
        camlight('headlight', 'infinite');
        camlight('headlight', 'infinite');
        frame = getframe(fig);      % Grab the rendered frame
        renderedBackImage = frame.cdata;    % This is the rendered image
        renderedBackImage = imresize(renderedBackImage, [413, 570]);

        %third render
        camorbit(0, -90)
        delete(findall(gcf,'Type','light'));
        camlight('headlight', 'infinite');
        camlight('headlight', 'infinite');
        camlight('headlight', 'infinite');
        frame = getframe(fig);      % Grab the rendered frame
        renderedBottomImage = frame.cdata;    % This is the rendered image
        renderedBottomImage = imresize(renderedBottomImage, [413, 570]);

        %% Insert text
        renderedFrontImage = insertText(renderedFrontImage,[1, 1],name,'FontSize',18,'BoxOpacity',0.4,'TextColor','black', 'BoxColor', 'white');
        renderedFrontImage = insertText(renderedFrontImage,[1, 40],variable,'FontSize',18,'BoxOpacity',0.4,'TextColor','black', 'BoxColor', 'white');
        renderedFrontImage = insertText(renderedFrontImage,[390, 1],'FRONT','FontSize',18,'BoxOpacity',0.4,'TextColor','black', 'BoxColor', 'white');
        renderedBackImage = insertText(renderedBackImage,[390, 1],'BACK','FontSize',18,'BoxOpacity',0.4,'TextColor','black',  'BoxColor', 'white');
        renderedBottomImage = insertText(renderedBottomImage,[390, 1],'BOTTOM','FontSize',18,'BoxOpacity',0.4,'TextColor','black',  'BoxColor', 'white');

        layout(413*(labelIx-1)+1:413*(labelIx),1:570,:) = renderedFrontImage;
        layout(413*(labelIx-1)+1:413*(labelIx), 571:570*2, :) = renderedBackImage;
        layout(413*(labelIx-1)+1:413*(labelIx), 570*2+1:end, :) = renderedBottomImage;

        close(fig)


    end
    
    imwrite(layout, strcat(savePath, '/', saveName, '_', variable,'.bmp'),'bmp');
    imwrite(layout, strcat(savePath, '/', saveName, '_', variable,'.png'),'png');
    save(strcat(savePath, '/', saveName, '_', variable, '.mat'), 'layout');

    writetable(spatialStatisticsTable,strcat(savePath, '/', saveName, '_', variable, '.csv'))
    
end
