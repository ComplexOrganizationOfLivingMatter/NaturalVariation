function voronoiModelPlane(planeAxis, nDots, nSeeds, lloydIter, plotBool, savePath, runId, numLayers, surfaceRatio)

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
%     ellipsoidInfo = struct();
%     ellipsoidInfo.xCenter = 0;
%     ellipsoidInfo.yCenter = 0;
%     ellipsoidInfo.zCenter = 0;
%     ellipsoidInfo.resolutionEllipse = nDots;
%     ellipsoidInfo.xRadius = ellipsoidAxis1;
%     ellipsoidInfo.yRadius = ellipsoidAxis2;
%     ellipsoidInfo.zRadius = ellipsoidAxis3;
%     
%     [X,Y,Z] = ellipsoid(ellipsoidInfo.xCenter,ellipsoidInfo.yCenter,ellipsoidInfo.zCenter,ellipsoidInfo.xRadius,ellipsoidInfo.yRadius,ellipsoidInfo.zRadius,nDots);
    

    % Define the ranges for x and y coordinates
    x_range = linspace(-planeAxis, planeAxis, nDots);
    y_range = linspace(-planeAxis, planeAxis, nDots);

    % Generate grid of points
    [X, Y] = meshgrid(x_range, y_range);

    % Flatten the matrices into arrays
    X = X(:);
    Y = Y(:);

    % Create alpha shape
    shp = alphaShape(X, Y);
    shp.Alpha = 2*shp.Alpha; % Adjust as needed

    vertex = shp.Points';
    vertex(3,:) = repmat(0, size(vertex(1,:)));
    faces = shp.alphaTriangulation';
    
    validDots = true(1, size(vertex, 2));
    validDots(unique(shp.boundaryFacets)) = false;
    nonValidDots = false(1, size(vertex, 2));
    nonValidDots(unique(shp.boundaryFacets)) = true;

    minimumSeparation = 50;
    
    while minimumSeparation >= 1
        try
            pstarts = createSeeds(nSeeds, vertex(:, validDots), minimumSeparation);
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
    
    %% remove borders
    nonValidCells = unique(SortedDjjIndices(nonValidDots,1));
    validRows = true(1, size(pstarts',1));
    validRows(nonValidCells) = false;
    
    %% table
    infoTable = table(unique(pstarts', 'stable'), validRows', areaArray, perimArray, repelem(totalArea, size(numNeighs,1))', numNeighs, neighsArray');
    infoTable.Properties.VariableNames = {'id', 'validCell', 'cell_area', 'perim_area', 'total_ellipsoid_area', 'numNeighs', 'neighs'};

    %% save name  
    date = datestr(datetime);
    date = strrep(date, ' ', '_');
    date = strrep(date, ':', '-');

    fileName = strcat('voronoiModel_planeSurface', date, '_principalAxisLength_', num2str(planeAxis), '_nSeeds_', num2str(nSeeds), '_nDots_', num2str(nDots), '_lloydIters_', num2str(0), '_runId_', num2str(runId), '_LAYER_', num2str(0));

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
        
        %% remove borders
        nonValidCells = unique(SortedDjjIndices(nonValidDots,1));
        validRows = true(1, size(pstarts',1));
        validRows(nonValidCells) = false;

        %% table
        infoTable = table(unique(pstarts, 'stable'), validRows', areaArray, perimArray, repelem(totalArea, size(numNeighs,1))', numNeighs, neighsArray');
        infoTable.Properties.VariableNames = {'id', 'validCell', 'cell_area', 'perim_area', 'total_ellipsoid_area', 'numNeighs', 'neighs'};
        
        %% save name  (not needed calculated before)
%         date = datestr(datetime);
%         date = strrep(date, ' ', '_');
%         date = strrep(date, ':', '-');

        fileName = strcat('voronoiModel_planeSurface', date, '_principalAxisLength_', num2str(planeAxis), '_nSeeds_', num2str(nSeeds), '_nDots_', num2str(nDots), '_lloydIters_', num2str(lloidIterIx), '_runId_', num2str(runId), '_LAYER_', num2str(0));

        writetable(infoTable, strcat(savePath, fileName, '.xls'));
        save(strcat(savePath, fileName), '-v7.3')
        
    end
    
    %% STOP LLOYD
    
   
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