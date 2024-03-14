function voronoiModel(ellipsoidAxis1, ellipsoidAxis2, ellipsoidAxis3, nDots, nSeeds, lloydIter, plotBool, savePath, runId, numLayers, surfaceRatio)

%     voronoiModel(100, 50, 75, 100, 10, 1, false, '')
    tic

    %% add paths
    warning off
    addpath('toolbox_signal')
    addpath('toolbox_general')
    addpath('toolbox_graph')
    addpath('toolbox_wavelet_meshes')
    addpath('solutions/fastmarching_4_mesh')

    %% define ellipsoid
    ellipsoidInfo = struct();
    ellipsoidInfo.xCenter = 0;
    ellipsoidInfo.yCenter = 0;
    ellipsoidInfo.zCenter = 0;
    ellipsoidInfo.resolutionEllipse = nDots;
    ellipsoidInfo.xRadius = ellipsoidAxis1;
    ellipsoidInfo.yRadius = ellipsoidAxis2;
    ellipsoidInfo.zRadius = ellipsoidAxis3;
    
    [X,Y,Z] = ellipsoid(ellipsoidInfo.xCenter,ellipsoidInfo.yCenter,ellipsoidInfo.zCenter,ellipsoidInfo.xRadius,ellipsoidInfo.yRadius,ellipsoidInfo.zRadius,nDots);

    coordinates = [X(:),Y(:),Z(:)];
    coordinates = unique(coordinates,'rows');

    shp = alphaShape(coordinates);

    shp.Alpha = 2*shp.Alpha;

    vertex = shp.Points';

    faces = shp.boundaryFacets';
    minimumSeparation = 50;
    
    while minimumSeparation >= 1
        try
            pstarts = createSeeds(nSeeds, vertex, minimumSeparation);
            break;
        catch
            if minimumSeparation >10
                minimumSeparation = minimumSeparation - 10;
            else
                minimumSeparation = minimumSeparation - 1;
            end
                disp(strcat('smth wrong with seed localization,retrying with minSep_', num2str(minimumSeparation)));
        end
    end
   
    
    %% initialization
    nvert = size(vertex,2);
    clear options;
    options.end_points = [];
    options.W = ones(nvert,1);
    options.nb_iter_max = Inf;
    
    %% try to perform fast marching, if it doesnt work, compile mex and retry
    try
        [D,S,Q] = perform_fast_marching_mesh(vertex, faces, pstarts, options);
    catch
        compile_mex
        [D,S,Q] = perform_fast_marching_mesh(vertex, faces, pstarts, options);
    end

    [Qexact,DQ, voronoi_edges, edges_id, lambda, Djj] = compute_voronoi_mesh(vertex, faces, pstarts, options);
    % [Qexact,DQ, voronoi_edges, edges_id, lambda, Djj]
    options.voronoi_edges = voronoi_edges;
    
    %% VORONOI LLOYD 0
    
    [D,S,Q] = perform_fast_marching_mesh(vertex, faces, pstarts, options);
    [Qexact,DQ, voronoi_edges, edges_id, lambda, Djj] = compute_voronoi_mesh(vertex, faces, pstarts, options);

    options.voronoi_edges = voronoi_edges;  
    ve = voronoi_edges;
    
    %% Neighs and area
    [sortedDjj, SortedDjjIndices] = sort(Djj, 2);
    uniqueVe = unique(ve, 'rows');
    veInVertexBool = ismember(vertex', ve(1:3,:)', 'rows');
    neighs = SortedDjjIndices(veInVertexBool, 1:2);

    neighsmat = neighs;

    numNeighs = [];
    neighsArray = [];
    labels  = unique(pstarts, 'stable');
    for cellIx = 1:length(labels)
    cellId = cellIx;
    numNeighs = [numNeighs; length(unique([(unique(neighsmat(neighsmat(:, 1)==cellId, 2))); unique(neighsmat(neighsmat(:, 2)==cellId, 1))]))];
    neighsArray = [neighsArray, {unique([(unique(neighsmat(neighsmat(:, 1)==cellId, 2))); unique(neighsmat(neighsmat(:, 2)==cellId, 1))])}];
    end

    uniqueLabels = unique(pstarts, 'stable');
    areaArray = [];
    perimArray = [];

    for cellIx = 1:length(uniqueLabels)
    cellId = uniqueLabels(cellIx);
    [area, perim] = calculateArea(vertex, faces, Q, cellId);
    areaArray = [areaArray; area];
    perimArray = [perimArray; perim];
    end

    [totalArea, ~] = calculateArea(vertex, faces, Q, []);

    infoTable = table(unique(pstarts', 'stable'), areaArray, perimArray, repelem(totalArea, size(numNeighs,1))', numNeighs, neighsArray');
    infoTable.Properties.VariableNames = {'id', 'cell_area', 'perim_area', 'total_ellipsoid_area', 'numNeighs', 'neighs'};

    %% save name  
    date = datestr(datetime);
    date = strrep(date, ' ', '_');
    date = strrep(date, ':', '-');

    fileName = strcat('voronoiModel_', date, '_principalAxisLength_', num2str(ellipsoidAxis1), '_', num2str(ellipsoidAxis2), '_', num2str(ellipsoidAxis3), '_nSeeds_', num2str(nSeeds), '_nDots_', num2str(nDots), '_lloydIters_', num2str(0), '_runId_', num2str(runId), '_LAYER_', num2str(0));

    %% REDEFINE SAVEPATH. CREATE FOLDER
    savePath = strcat(savePath, 'voronoiModel_', date, '_principalAxisLength_', num2str(ellipsoidAxis1), '_', num2str(ellipsoidAxis2), '_', num2str(ellipsoidAxis3), '_nSeeds_', num2str(nSeeds), '_nDots_', num2str(nDots), '/');
    mkdir(savePath);

    writetable(infoTable, strcat(savePath, fileName, '.xls'));
    save(strcat(savePath, fileName), '-v7.3')
        
    
    %% START LLOYD
    %% lloyd iterations
    for lloidIterIx = 1:lloydIter

        pstarts = perform_lloyd_mesh(vertex,faces, pstarts, options);

        [D,S,Q] = perform_fast_marching_mesh(vertex, faces, pstarts, options);
        [Qexact,DQ, voronoi_edges, edges_id, lambda, Djj] = compute_voronoi_mesh(vertex, faces, pstarts, options);

        options.voronoi_edges = voronoi_edges;  
        ve = voronoi_edges;

        %% Neighs and area
        [sortedDjj, SortedDjjIndices] = sort(Djj, 2);
        uniqueVe = unique(ve, 'rows');
        veInVertexBool = ismember(vertex', ve(1:3,:)', 'rows');
        neighs = SortedDjjIndices(veInVertexBool, 1:2);

        neighsmat = neighs;

        numNeighs = [];
        neighsArray = [];
        labels  = unique(pstarts, 'stable');
        for cellIx = 1:length(labels)
            cellId = cellIx;
            numNeighs = [numNeighs; length(unique([(unique(neighsmat(neighsmat(:, 1)==cellId, 2))); unique(neighsmat(neighsmat(:, 2)==cellId, 1))]))];
            neighsArray = [neighsArray, {unique([(unique(neighsmat(neighsmat(:, 1)==cellId, 2))); unique(neighsmat(neighsmat(:, 2)==cellId, 1))])}];
        end

        uniqueLabels = unique(pstarts, 'stable');
        areaArray = [];
        perimArray = [];

        for cellIx = 1:length(uniqueLabels)
            cellId = uniqueLabels(cellIx);
            [area, perim] = calculateArea(vertex, faces, Q, cellId);
            areaArray = [areaArray; area];
            perimArray = [perimArray; perim];
        end

        [totalArea, ~] = calculateArea(vertex, faces, Q, []);

        infoTable = table(unique(pstarts, 'stable'), areaArray, perimArray, repelem(totalArea, size(numNeighs,1))', numNeighs, neighsArray');
        infoTable.Properties.VariableNames = {'id', 'cell_area', 'perim_area', 'total_ellipsoid_area', 'numNeighs', 'neighs'};

        %% save name  (not needed calculated before)
%         date = datestr(datetime);
%         date = strrep(date, ' ', '_');
%         date = strrep(date, ':', '-');

        fileName = strcat('voronoiModel_', date, '_principalAxisLength_', num2str(ellipsoidAxis1), '_', num2str(ellipsoidAxis2), '_', num2str(ellipsoidAxis3), '_nSeeds_', num2str(nSeeds), '_nDots_', num2str(nDots), '_lloydIters_', num2str(lloidIterIx), '_runId_', num2str(runId), '_LAYER_', num2str(0));

        writetable(infoTable, strcat(savePath, fileName, '.xls'));
        save(strcat(savePath, fileName), '-v7.3')
        
    end
    
    %% STOP LLOYD
    
    
    %% Layers
    cellHeight = ellipsoidAxis2*surfaceRatio-ellipsoidAxis2;
    step = cellHeight/numLayers;
    
    for layerIx = 1:numLayers
       %% 3d ellipsoid layers

        [vertexPstarts2, X, Y, Z] = getAugmentedCentroids(ellipsoidInfo, vertex(:, pstarts)', layerIx*step); 
        
        coordinates = [X(:),Y(:),Z(:)];
        coordinates = unique(coordinates,'rows');
        shp2 = alphaShape(coordinates);
        shp2.Alpha = 2*shp2.Alpha;
        vertex2 = shp2.Points';
        faces2 = shp2.boundaryFacets';
                
%         arrayfun(@(pstarts2ID) find(ismember(vertex2', vertexPstarts2(pstarts2ID)), size(vertex2,2)))
        pstarts2 = arrayfun(@(pstarts2ID) find(ismember(vertex2', vertexPstarts2(pstarts2ID,:), 'rows')), 1:size(vertexPstarts2, 1), 'UniformOutput', false);
        pstarts2 = cell2mat(pstarts2)';
            
        [D,S,Q] = perform_fast_marching_mesh(vertex2, faces2, pstarts2, options);
        [Qexact,DQ, voronoi_edges, edges_id, lambda, Djj] = compute_voronoi_mesh(vertex2, faces2, pstarts2, options);
        
        %% Neighs and area
        options.voronoi_edges = voronoi_edges;  
        ve = voronoi_edges;
    
        [sortedDjj, SortedDjjIndices] = sort(Djj, 2);
        uniqueVe = unique(ve, 'rows');
        veInVertexBool = ismember(vertex2', ve(1:3,:)', 'rows');
        neighs = SortedDjjIndices(veInVertexBool, 1:2);

        neighsmat = neighs;

        numNeighs = [];
        neighsArray = [];
        labels  = unique(pstarts2, 'stable');
        for cellIx = 1:length(labels)
            cellId = cellIx;
            numNeighs = [numNeighs; length(unique([(unique(neighsmat(neighsmat(:, 1)==cellId, 2))); unique(neighsmat(neighsmat(:, 2)==cellId, 1))]))];
            neighsArray = [neighsArray, {unique([(unique(neighsmat(neighsmat(:, 1)==cellId, 2))); unique(neighsmat(neighsmat(:, 2)==cellId, 1))])}];
        end

        uniqueLabels = unique(pstarts2, 'stable');
        areaArray = [];
        perimArray = [];

        for cellIx = 1:length(uniqueLabels)
            cellId = uniqueLabels(cellIx);
            [area, perim] = calculateArea(vertex2, faces2, Q, cellId);
            areaArray = [areaArray; area];
            perimArray = [perimArray; perim];
        end

        [totalArea, ~] = calculateArea(vertex2, faces2, Q, []);
        
        infoTable = table(unique(pstarts, 'stable'),unique(pstarts2, 'stable'), areaArray, perimArray, repelem(totalArea, size(numNeighs,1))', numNeighs, neighsArray');
        infoTable.Properties.VariableNames = {'id_layer0','id', 'cell_area', 'perim_area', 'total_ellipsoid_area', 'numNeighs', 'neighs'};
        fileName = strcat('voronoiModel_', date, '_principalAxisLength_', num2str(ellipsoidAxis1), '_', num2str(ellipsoidAxis2), '_', num2str(ellipsoidAxis3), '_nSeeds_', num2str(nSeeds), '_nDots_', num2str(nDots), '_lloydIters_', num2str(lloydIter), '_runId_', num2str(runId), '_LAYER_', num2str(layerIx));

        writetable(infoTable, strcat(savePath, fileName, '.xls'));
        save(strcat(savePath, fileName, '.mat'), '-v7.3')
        
        basalFileName = fileName;
        if layerIx == numLayers
            
           apicalFileName = strcat('voronoiModel_', date, '_principalAxisLength_', num2str(ellipsoidAxis1), '_', num2str(ellipsoidAxis2), '_', num2str(ellipsoidAxis3), '_nSeeds_', num2str(nSeeds), '_nDots_', num2str(nDots), '_lloydIters_', num2str(lloydIter), '_runId_', num2str(runId), '_LAYER_', num2str(0));

           tableLayerApical = readtable(strcat(savePath, apicalFileName));
           tableLayerBasal = readtable(strcat(savePath, basalFileName));
           
           apicalNeighsArray = [];
           basalNeighsArray= [];
           apicoBasalTransitionsArray = [];
           scutoidArray = [];
           
           for cellIx=1:size(tableLayerApical,1)
                apicalNeighs = tableLayerApical(cellIx, 6:end).Variables;
                basalNeighs = tableLayerBasal(cellIx, 7:end).Variables;
                
                apicalNeighs = apicalNeighs(~isnan(apicalNeighs));
                basalNeighs = basalNeighs(~isnan(basalNeighs));
                
                apicoBasalTransitions = length(vertcat(setdiff(basalNeighs,apicalNeighs), setdiff(apicalNeighs,basalNeighs)));
                scutoid = apicoBasalTransitions>0;
                
                apicalNeighsArray = [apicalNeighsArray; {apicalNeighs}];
                basalNeighsArray = [basalNeighsArray; {basalNeighs}];
                apicoBasalTransitionsArray = [apicoBasalTransitionsArray; apicoBasalTransitions];
                scutoidArray = [scutoidArray; scutoid];
           end
           
           dataTable = table(tableLayerApical.id, tableLayerApical.cell_area, tableLayerBasal.cell_area, tableLayerApical.perim_area, tableLayerBasal.perim_area, tableLayerApical.total_ellipsoid_area, tableLayerBasal.total_ellipsoid_area, tableLayerApical.numNeighs, tableLayerBasal.numNeighs, apicoBasalTransitionsArray, scutoidArray, apicalNeighsArray, basalNeighsArray);
           dataTable.Properties.VariableNames = {'id', 'apicalCellArea', 'basalCellArea', 'apicalPerim', 'basalPerim', 'apicalTotalArea', 'basalTotalArea', 'apicalNumNeighs', 'basalNumNeighs', 'apicoBasalTransitions', 'scutoid', 'apicalNeighs', 'basalNeighs'};           
           fileName = strcat('voronoiModel_3D_', date, '_principalAxisLength_', num2str(ellipsoidAxis1), '_', num2str(ellipsoidAxis2), '_', num2str(ellipsoidAxis3), '_nSeeds_', num2str(nSeeds), '_nDots_', num2str(nDots), '_lloydIters_', num2str(lloydIter), '_runId_', num2str(runId));

           writetable(dataTable, strcat(savePath, fileName, '.xls'));
           
        end

    end
    
   
    if plotBool == true
        %% capture and close
        ve = plot_fast_marching_mesh(vertex,faces, Q, [], options);

        fig = get(groot,'CurrentFigure');

        frame = getframe(fig);      % Grab the rendered frame
        voronoiImage = frame.cdata;    % This is the rendered image
        close(fig)

        save(fig, strcat(savePath, fileName, '.fig'));
    end
    
    display(toc)
    clear all
