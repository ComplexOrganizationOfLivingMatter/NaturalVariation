function plotSpatialDistribution(rgStackPath, labelsPath, variable, savePath, saveName, minMaxRanges)
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
    
    rgStackPath = strcat(rgStackPath, '/');
    labelsPath = strcat(labelsPath, '/');
  
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

        %% RELABEL from 0 to #uniqueCells
        idLabels = unique(labelledImage);
        imgRelabel = zeros(size(labelledImage));
        for id = 1:length(idLabels)-1
            imgRelabel(labelledImage==idLabels(id+1))= id;
        end
        labelledImage = imgRelabel;
        %%
        
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
        
        validCells = find(table2array(regionprops3(labelledImage,'Volume'))>0);
        noValidCells = [];
        
        validCells_size = find(table2array(regionprops3(labelledImage,'Volume'))>0);
        validCells_apicoBasal = intersect(unique(apicalLayer),unique(basalLayer));
        validCells = intersect(unique(validCells_size), unique(validCells_apicoBasal));
        noValidCells = setdiff(unique(labelledImage), validCells);

        if isempty(validCells)
            validCells = find(table2array(regionprops3(labelledImage,'Volume'))>0);
            noValidCells = [];
        end

        %% Obtain 3D features from Cells, Tissue, Lumen and Tissue+Lumen
        try
            [cells3dFeatures, ~, ~,~, ~, ~,~, ~,~, ~, ~, apicoBasalNeighs] = obtain3DFeatures(labelledImage,apicalLayer,basalLayer,lateralLayer,lumenImage,validCells,noValidCells,'','', contactThreshold, dilatedVx);
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
            uniqueLabels = uniqueLabels(uniqueLabels~=0);
            for cellIx = 1:size(uniqueLabels, 1)
                cellId = uniqueLabels(cellIx);
                
                if ismember(cellId, validCells)
                    cellId_cells3dFeatures = strcat('cell_', num2str(cellId));
                    if cells3dFeatures(strcmp(cells3dFeatures.ID_Cell,cellId_cells3dFeatures), 'scutoids').scutoids == 1
                        scu = scu + 1;
                        colours = [colours; [1 0.84 0.150]];
                    else
                        colours = [colours; [0.41 0.28 0.55]];
                    end
                else
                    colours = [colours; [0.9 0.9 0.9]];
                end

            end
            disp(strcat('scutoids: ', num2str(scu/size(cells3dFeatures, 1))));
                elseif contains(variable,"NumNeighs")
            colours = [];
            uniqueLabels = unique(labelledImage);
            uniqueLabels = uniqueLabels(uniqueLabels~=0);
            maxValue = 9;
            minValue = 3;
            cMap = [1 0 0;254/255,101/255,0; 0, 152/255, 0;52/255,102/255,254/255;128/255,0,128/255;1/255,108/255,127/255;0 0 0];
            cellsVariableFeatures = cells3dFeatures.(variable);
            for cellIx = 1:size(cells3dFeatures, 1)
                if cellsVariableFeatures(cellIx) == 4
                    colours = [colours; [254/255,101/255,0]];
                elseif cellsVariableFeatures(cellIx) == 5
                    colours = [colours; [0, 152/255, 0]];
                elseif cellsVariableFeatures(cellIx) == 6
                    colours = [colours; [52/255,102/255,254/255]];
                elseif cellsVariableFeatures(cellIx) == 7
                    colours = [colours; [128/255,0,128/255]];
                elseif cellsVariableFeatures(cellIx) == 8
                    colours = [colours; [1/255,108/255,127/255]];
                elseif cellsVariableFeatures(cellIx) > 8 
                    colours = [colours; [0 0 0]];
                    warning('The cell %d has %d neighbours',cellIx,cellsVariableFeatures(cellIx));
                elseif cellsVariableFeatures(cellIx) < 4
                    colours = [colours; [1 0 0]];
                    warning('The cell %d has %d neighbours',cellIx,cellsVariableFeatures(cellIx));
                end
            end
        elseif variable == "apicoBasalTransitions"
            colours = [];

            maxValue = 3;
            minValue = 0;

            cMap = [1 0.84 0.150; 1 0.28 0.6;0.71 0.28 0.55;0.41 0.28 0.55];
            cellsVariableFeatures = cells3dFeatures.(variable);
            for cellIx = 1:size(cells3dFeatures, 1)
                if cellsVariableFeatures(cellIx) == 0
                    colours = [colours; [1 0.84 0.150]];
                elseif cellsVariableFeatures(cellIx) == 1
                    colours = [colours; [1 0.28 0.6]];
                elseif cellsVariableFeatures(cellIx) == 2
                    colours = [colours; [0.71 0.28 0.55]];
                elseif cellsVariableFeatures(cellIx) > 2
                    colours = [colours; [0.41 0.28 0.55]];
                end
            end
        elseif variable == "apicoBasalTransitions"
            colours = [];
            maxValue = max(cells3dFeatures(:, variable).Variables);
            minValue = min(cells3dFeatures(:, variable).Variables);
            cMap = [1 0.84 0.150; 1 0.28 0.6;0.71 0.28 0.55;0.41 0.28 0.55];
            cellsVariableFeatures = cells3dFeatures.(variable);
            for cellIx = 1:size(cells3dFeatures, 1)
                if cellsVariableFeatures(cellIx) == 0
                    colours = [colours; [1 0.84 0.150]];
                elseif cellsVariableFeatures(cellIx) == 1
                    colours = [colours; [1 0.28 0.6]];
                elseif cellsVariableFeatures(cellIx) == 2
                    colours = [colours; [0.71 0.28 0.55]];
                elseif cellsVariableFeatures(cellIx) > 2
                    colours = [colours; [0.41 0.28 0.55]];
                end
            end
        elseif variable == "surfaceRatio"
            uniqueLabels = unique(labelledImage);
            uniqueLabels = uniqueLabels(uniqueLabels~=0);
            surfaceRatio = cells3dFeatures(:, "basal_Area").Variables./cells3dFeatures(:, "apical_Area").Variables;
%                            
            colours = [];
            for cellIx = 1:size(uniqueLabels, 1)
                cellId = uniqueLabels(cellIx);
                
                if isempty(minMaxRanges)
                    maxValue = max(surfaceRatio);
                    minValue = min(surfaceRatio);
                else
                    maxValue = minMaxRanges(1);
                    minValue = minMaxRanges(2);
                end

                cMap1 = interp1([0;0.5],[1 0.84 0.150; 1 0.28 0.65],linspace(0,0.5,50));
                cMap2 = interp1([0.5;1],[1 0.28 0.6; 0.41 0.28 0.55],linspace(0.5,1,50));
                cMap = [cMap1; cMap2];
                
                if ismember(cellId, validCells)
                    
                    cellId_cells3dFeatures = strcat('cell_', num2str(cellId));
                    currentSurfaceRatio = cells3dFeatures(strcmp(cells3dFeatures.ID_Cell,cellId_cells3dFeatures), 'basal_Area').basal_Area./cells3dFeatures(strcmp(cells3dFeatures.ID_Cell,cellId_cells3dFeatures), 'apical_Area').apical_Area;
                
                    cMapIndex = round(100*(currentSurfaceRatio-minValue)/(maxValue-minValue));
                    if cMapIndex == 0 || isnan(cMapIndex)
                        cMapIndex = 1;
                    end
                    colours = [colours; cMap(cMapIndex, :)];
                else
                    colours = [colours; [0.9 0.9 0.9]];
                end
            end
        elseif variable == "betCentrality"
            colours = [];
            uniqueLabels = unique(labelledImage);
            uniqueLabels = uniqueLabels(uniqueLabels~=0);
            for cellIx = 1:size(uniqueLabels, 1)
                cellId = uniqueLabels(cellIx);
                
                if isempty(minMaxRanges)
                    maxValue = max(betweennessCentrality);
                    minValue = min(betweennessCentrality);
                else
                    maxValue = minMaxRanges(1);
                    minValue = minMaxRanges(2);
                end

                cMap1 = interp1([0;0.5],[0 1 0; 1 1 0],linspace(0,0.5,50));
                cMap2 = interp1([0.5;1],[1 1 0; 1 0 0],linspace(0.5,1,50));
                cMap = [cMap1; cMap2];
                
                if ismember(cellId, validCells)
                    cellId_cells3dFeatures = strcat('cell_', num2str(cellId));
                    currentBetweennessCentrality = cells3dFeatures(strcmp(cells3dFeatures.ID_Cell,cellId_cells3dFeatures), 'betCentrality').betCentrality;
                    cMapIndex = round(100*(currentBetweennessCentrality-minValue)/(maxValue-minValue));
                    if cMapIndex == 0 || isnan(cMapIndex)
                        cMapIndex = 1;
                    end
                    colours = [colours; cMap(cMapIndex, :)];
                else
                    colours = [colours; [0.9 0.9 0.9]];
                end
                
            end
        elseif variable == "coefCluster"
            colours = [];
            uniqueLabels = unique(labelledImage);
            uniqueLabels = uniqueLabels(uniqueLabels~=0);
            for cellIx = 1:size(uniqueLabels, 1)
                cellId = uniqueLabels(cellIx);
                
                if isempty(minMaxRanges)
                    maxValue = max(coefCluster);
                    minValue = min(coefCluster);
                else
                    maxValue = minMaxRanges(1);
                    minValue = minMaxRanges(2);
                end

                cMap1 = interp1([0;0.5],[0 0 1; 1 1 0],linspace(0,0.5,50));
                cMap2 = interp1([0.5;1],[1 1 0; 1 0 0],linspace(0.5,1,50));
                cMap = [cMap1; cMap2];                
            
                cellId_cells3dFeatures = strcat('cell_', num2str(cellId));
                currentCoefCluster = cells3dFeatures(strcmp(cells3dFeatures.ID_Cell,cellId_cells3dFeatures), 'coefCluster').coefCluster;
                cMapIndex = round(100*(currentCoefCluster-minValue)/(maxValue-minValue));
                if cMapIndex == 0 || isnan(cMapIndex)
                    cMapIndex = 1;
                end
                colours = [colours; cMap(cMapIndex, :)];
            end
        elseif variable == "apical_NumNeighs"
            colours = [];
            uniqueLabels = unique(labelledImage);
            uniqueLabels = uniqueLabels(uniqueLabels~=0);
            apicalCells = unique(apicalLayer);
            apicalCells = apicalCells(apicalCells~=0);
            
            for cellIx = 1:size(uniqueLabels, 1)
                cellId = uniqueLabels(cellIx);
                maxValue = 8;
                minValue = 4;

                cMap1 = interp1([0;0.5],[1 0.84 0.150; 1 0.28 0.65],linspace(0,0.5,50));
                cMap2 = interp1([0.5;1],[1 0.28 0.6; 0.41 0.28 0.55],linspace(0.5,1,50));
                cMap = [cMap1; cMap2];                

                if ismember(cellId, validCells)
                    cellId_cells3dFeatures = strcat('cell_', num2str(cellId));
                    currentNeighs = cells3dFeatures(strcmp(cells3dFeatures.ID_Cell,cellId_cells3dFeatures), 'apical_NumNeighs').apical_NumNeighs;
                    cMapIndex = round(100*(currentNeighs-minValue)/(maxValue-minValue));
                    if cMapIndex>100
                        cMapIndex = 100;
                    elseif cMapIndex<1
                        cMapIndex = 1;
                    end
                    if cMapIndex == 0 || isnan(cMapIndex)
                        cMapIndex = 1;
                    end
                    if ismember(cellId, apicalCells)
                        colours = [colours; cMap(cMapIndex, :)];
                    end
                else
                    if ismember(cellId, apicalCells)
                        colours = [colours; [0.9 0.9 0.9]];
                    end
                end
            end
            
        elseif variable == "GRAY"
            colours = [];
            for cellIx = 1:size(uniqueLabels, 1)
                colours = [colours; [0.9,0.9,0.9]];
            end
        else
            colours = [];
            uniqueLabels = unique(labelledImage);
            uniqueLabels = uniqueLabels(uniqueLabels~=0);
            for cellIx = 1:size(uniqueLabels, 1)
                cellId = uniqueLabels(cellIx);
                
                if isempty(minMaxRanges)
                    maxValue = max(cells3dFeatures(:, variable).Variables);
                    minValue = min(cells3dFeatures(:, variable).Variables);
                else
                    minValue = minMaxRanges(1);
                    maxValue = minMaxRanges(2);
                end
                
                cMap1 = interp1([0;0.5],[1 0.84 0.150; 1 0.28 0.65],linspace(0,0.5,50));
                cMap2 = interp1([0.5;1],[1 0.28 0.6; 0.41 0.28 0.55],linspace(0.5,1,50));

                cMap = [cMap1; cMap2];    
                
                if ismember(cellId, validCells)
                    cellId_cells3dFeatures = strcat('cell_', num2str(cellId));
                    currentCellFeature = cells3dFeatures(strcmp(cells3dFeatures.ID_Cell,cellId_cells3dFeatures), variable).Variables;
                    cMapIndex = round(100*(currentCellFeature-minValue)/(maxValue-minValue));
                    if cMapIndex == 0 || isnan(cMapIndex)
                        cMapIndex = 1;
                    end
                    colours = [colours; cMap(cMapIndex, :)];
                else
                    colours = [colours; [0.9 0.9 0.9]];
                end
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
        
        if variable == "apical_NumNeighs"
            se = strel('sphere', 1);
            apicalLayerToDraw = imdilate(apicalLayer, se);
            apicalCellsToDraw = unique(apicalLayer);
            apicalCellsToDraw = apicalCellsToDraw(apicalCellsToDraw~=0);
            
            paint3D(apicalLayerToDraw, 1:length(apicalCellsToDraw), colours, 3,1.2);
        else
            paint3D(labelledImage, unique(labelledImage), colours, 3, 0.5);
        end
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
       
        
        if contains(variable,"NumNeighs")
           caxis([(minValue-0.5),(maxValue+0.5)])
           colorbarHandler.TickLabels=["<4" "4" "5" "6" "7" "8" ">8"];
           colorbarHandler.Ticks=[3 4 5 6 7 8 9]; 
        end
        
        if strcmp(variable,"apicoBasalTransitions")
            caxis([(minValue-0.5),(maxValue+0.5)])
            colorbarHandler.TickLabels=["0" "1", "2", ">2"];
            colorbarHandler.Ticks=[0 1 2 3];
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
