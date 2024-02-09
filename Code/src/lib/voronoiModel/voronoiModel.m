function voronoiModel(ellipsoidAxis1, ellipsoidAxis2, ellipsoidAxis3, nDots, nSeeds, lloydIter, plotBool, savePath)

    %% add paths
    warning off
    addpath('toolbox_signal')
    addpath('toolbox_general')
    addpath('toolbox_graph')
    addpath('toolbox_wavelet_meshes')
    addpath('solutions/fastmarching_4_mesh')

    %% define ellipsoid
    [X,Y,Z] = ellipsoid(0,0,0,ellipsoidAxis1,ellipsoidAxis2,ellipsoidAxis3,nDots);

    coordinates = [X(:),Y(:),Z(:)];
    coordinates = unique(coordinates,'rows');

    shp = alphaShape(coordinates);

    shp.Alpha = 2*shp.Alpha;

    vertex = shp.Points';

    faces = shp.boundaryFacets';

    %% params for voronoi such as random seed positioning

    nvert = size(vertex,2);
    nstart = nSeeds;
    pstarts = floor(rand(nstart,1)*nvert)+1;
    options.start_points = pstarts;

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

    pstarts = perform_lloyd_mesh(vertex,faces, pstarts, options);

    %% Neighs
    tic
    find_neighbors = @(vertexId) find(ismember(Djj(ismember(vertex', [ve(1,vertexId), ve(2,vertexId), ve(3,vertexId)],'rows'), :),mink(Djj(ismember(vertex', [ve(1,vertexId), ve(2,vertexId), ve(3,vertexId)],'rows'), :), 2)));
    neighs = arrayfun(find_neighbors, 1:size(ve, 2), 'UniformOutput', false);

    neighsmat = cell2mat(neighs');

    numNeighs = [];

    labels  = unique(Qexact);
    for cellIx = 1:length(labels)
        cellId = labels(cellIx);
        numNeighs = [numNeighs; length(unique([(unique(neighsmat(neighsmat(:, 1)==cellId, 2))); unique(neighsmat(neighsmat(:, 2)==cellId, 1))]))];
    end
    toc
    disp('time finding neighs');
    disp(mean(numNeighs))

    %% capture and close
    fig = get(groot,'CurrentFigure');

    frame = getframe(fig);      % Grab the rendered frame
    voronoiImage = frame.cdata;    % This is the rendered image
    close(fig)
    
    date = datestr(datetime);
    date = strrep(date, ' ', '_');
    date = strrep(date, ':', '-');

    fileName = strcat('voronoiModel_', date, '_principalAxisLength_', num2str(ellipsoidAxis1), '_', num2str(ellipsoidAxis2), '_', num2str(ellipsoidAxis3), '_nSeeds_', num2str(nSeeds), '_nDots_', num2str(nDots), '_lloydIters_', num2str(lloydIter));

    save(fig, strcat(savePath, fileName, '.fig'));
