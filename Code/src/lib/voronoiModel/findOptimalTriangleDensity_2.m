function findOptimalTriangleDensity()

warning off
addpath('toolbox_signal')
addpath('toolbox_general')
addpath('toolbox_graph')
addpath('toolbox_wavelet_meshes')
addpath('solutions/fastmarching_4_mesh')
    
savePath = '/media/pedro/6TB/jesus/NaturalVariation/voronoiModel_11/';
nSeeds = 750;
axis1 = 75;

for ix = 1:10
    ix100=ix;
    %% 100
    ellipsoidInfo100 = struct();
    ellipsoidInfo100.xCenter = 0;
    ellipsoidInfo100.yCenter = 0;
    ellipsoidInfo100.zCenter = 0;
    ellipsoidInfo100.resolutionEllipse = 100;
    ellipsoidInfo100.xRadius = 75;
    ellipsoidInfo100.yRadius = 100;
    ellipsoidInfo100.zRadius = 100;

    %%
    [X_100,Y_100,Z_100] = ellipsoid(ellipsoidInfo100.xCenter,ellipsoidInfo100.yCenter,ellipsoidInfo100.zCenter,ellipsoidInfo100.xRadius,ellipsoidInfo100.yRadius,ellipsoidInfo100.zRadius,100);

    coordinates = [X_100(:),Y_100(:),Z_100(:)];
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

    vertex100 = vertex;
    faces100 = faces;
    originalPoints = vertex100(:, pstarts);
    pstarts100 = pstarts;

    nvert = size(vertex100,2);
    clear options100;
    options100.end_points = [];
    options100.W = ones(nvert,1);
    options100.nb_iter_max = Inf;

    [D100,S100,Q100] = perform_fast_marching_mesh(vertex100, faces100, pstarts100, options100);
    [Qexact100,DQ100, voronoi_edges100, edges_id100, lambda100, Djj100] = compute_voronoi_mesh(vertex100, faces100, pstarts100, options100);

    options100.voronoi_edges = voronoi_edges100;  
    ve100 = voronoi_edges100;


    %% Neighs and area
    [sortedDjj100, SortedDjjIndices100] = sort(Djj100, 2);
    uniqueVe100 = unique(ve100, 'rows');
    veInVertexBool100 = ismember(vertex100', ve100(1:3,:)', 'rows');
    neighs100 = SortedDjjIndices100(veInVertexBool100, 1:2);

    neighsmat100 = neighs100;

    numNeighs100 = [];
    neighsArray100 = [];
    labels100  = unique(pstarts100, 'stable');

    for cellIx100 = 1:length(labels100)
        cellId100 = cellIx100;
        numNeighs100 = [numNeighs100; length(unique([(unique(neighsmat100(neighsmat100(:, 1)==cellId100, 2))); unique(neighsmat100(neighsmat100(:, 2)==cellId100, 1))]))];
        neighsArray100 = [neighsArray100, {unique([(unique(neighsmat100(neighsmat100(:, 1)==cellId100, 2))); unique(neighsmat100(neighsmat100(:, 2)==cellId100, 1))])}];
    end

    uniqueLabels100 = unique(pstarts100, 'stable');
    areaArray100 = [];
    perimArray100 = [];

    for cellIx100 = 1:length(uniqueLabels100)
        cellId100 = uniqueLabels100(cellIx100);
        [area100, perim100] = calculateArea(vertex100, faces100, Q100, cellId100);
        areaArray100 = [areaArray100; area100];
        perimArray100 = [perimArray100; perim100];
    end

    [totalArea100, ~] = calculateArea(vertex100, faces100, Q100, []);

    infoTable100 = table(unique(pstarts100', 'stable'), areaArray100, perimArray100, repelem(totalArea100, size(numNeighs100,1))', numNeighs100, neighsArray100');
    infoTable100.Properties.VariableNames = {'id', 'cell_area', 'perim_area', 'total_ellipsoid_area', 'numNeighs', 'neighs'};

        %% save name  
    date = datestr(datetime);
    date = strrep(date, ' ', '_');
    date = strrep(date, ':', '-');

    fileName = strcat('voronoiModel_', date, '_principalAxisLength_', num2str(75), '_', num2str(100), '_', num2str(100), '_nSeeds_', num2str(nSeeds), '_nDots_', num2str(100), '_lloydIters_', num2str(1), '_runId_', num2str(ix100), '_LAYER_', num2str(0));

    writetable(infoTable100, strcat(savePath, fileName, '.xls'));
    save(strcat(savePath, fileName), '-v7.3')

    %% 250
    ix250=ix;
    ellipsoidInfo250 = struct();
    ellipsoidInfo250 = struct();
    ellipsoidInfo250.xCenter = 0;
    ellipsoidInfo250.yCenter = 0;
    ellipsoidInfo250.zCenter = 0;
    ellipsoidInfo250.resolutionEllipse = 250;
    ellipsoidInfo250.xRadius = 75;
    ellipsoidInfo250.yRadius = 100;
    ellipsoidInfo250.zRadius = 100;

    [vertexPstarts250, X250, Y250, Z250] = getAugmentedCentroids( ellipsoidInfo250, originalPoints', 0 );

    coordinates250 = [X250(:),Y250(:),Z250(:)];
    coordinates250 = unique(coordinates250,'rows');
    shp250 = alphaShape(coordinates250);
    shp250.Alpha = 2*shp250.Alpha;
    vertex250 = shp250.Points';
    faces250 = shp250.boundaryFacets';

    pstarts250 = arrayfun(@(pstarts2ID) find(ismember(vertex250', vertexPstarts250(pstarts2ID,:), 'rows')), 1:size(vertexPstarts250, 1), 'UniformOutput', false);
    pstarts250 = cell2mat(pstarts250)';

    nvert250 = size(vertex250,2);
    clear options;
    options250.end_points = [];
    options250.W = ones(nvert250,1);
    options250.nb_iter_max = Inf;

    [D250,S250,Q250] = perform_fast_marching_mesh(vertex250, faces250, pstarts250, options250);
    [Qexact,DQ, voronoi_edges250, edges_id250, lambda250, Djj250] = compute_voronoi_mesh(vertex250, faces250, pstarts250, options250);

    options.voronoi_edges = voronoi_edges250;  
    ve250 = voronoi_edges250;

    %% Neighs and area
    [sortedDjj250, SortedDjjIndices250] = sort(Djj250, 2);
    uniqueVe250 = unique(ve250, 'rows');
    veInVertexBool250 = ismember(vertex250', ve250(1:3,:)', 'rows');
    neighs250 = SortedDjjIndices250(veInVertexBool250, 1:2);

    neighsmat250 = neighs250;

    numNeighs250 = [];
    neighsArray250 = [];
    labels250  = unique(pstarts250, 'stable');

    for cellIx250 = 1:length(labels250)
        cellId250 = cellIx250;
        numNeighs250 = [numNeighs250; length(unique([(unique(neighsmat250(neighsmat250(:, 1)==cellId250, 2))); unique(neighsmat250(neighsmat250(:, 2)==cellId250, 1))]))];
        neighsArray250 = [neighsArray250, {unique([(unique(neighsmat250(neighsmat250(:, 1)==cellId250, 2))); unique(neighsmat250(neighsmat250(:, 2)==cellId250, 1))])}];
    end

    uniqueLabels250 = unique(pstarts250, 'stable');
    areaArray250 = [];
    perimArray250 = [];

    for cellIx250 = 1:length(uniqueLabels250)
        cellId250 = uniqueLabels250(cellIx250);
        [area250, perim250] = calculateArea(vertex250, faces250, Q250, cellId250);
        areaArray250 = [areaArray250; area250];
        perimArray250 = [perimArray250; perim250];
    end

    [totalArea250, ~] = calculateArea(vertex250, faces250, Q250, []);

    infoTable250 = table(unique(pstarts250, 'stable'), areaArray250, perimArray250, repelem(totalArea250, size(numNeighs250,1))', numNeighs250, neighsArray250');
    infoTable250.Properties.VariableNames = {'id', 'cell_area', 'perim_area', 'total_ellipsoid_area', 'numNeighs', 'neighs'};


    fileName = strcat('voronoiModel_', date, '_principalAxisLength_', num2str(75), '_', num2str(100), '_', num2str(100), '_nSeeds_', num2str(nSeeds), '_nDots_', num2str(250), '_lloydIters_', num2str(1), '_runId_', num2str(ix250), '_LAYER_', num2str(0));

    writetable(infoTable250, strcat(savePath, fileName, '.xls'));
    save(strcat(savePath, fileName), '-v7.3')


    %% 500
    ix500=ix;
    ellipsoidInfo500 = struct();
    ellipsoidInfo500.xCenter = 0;
    ellipsoidInfo500.yCenter = 0;
    ellipsoidInfo500.zCenter = 0;
    ellipsoidInfo500.resolutionEllipse = 500;
    ellipsoidInfo500.xRadius = 75;
    ellipsoidInfo500.yRadius = 100;
    ellipsoidInfo500.zRadius = 100;

    [vertexPstarts500, X500, Y500, Z500] = getAugmentedCentroids( ellipsoidInfo500, originalPoints', 0 );

    coordinates500 = [X500(:),Y500(:),Z500(:)];
    coordinates500 = unique(coordinates500,'rows');
    shp500 = alphaShape(coordinates500);
    shp500.Alpha = 2*shp500.Alpha;
    vertex500 = shp500.Points';
    faces500 = shp500.boundaryFacets';

    pstarts500 = arrayfun(@(pstarts2ID) find(ismember(vertex500', vertexPstarts500(pstarts2ID,:), 'rows')), 1:size(vertexPstarts500, 1), 'UniformOutput', false);
    pstarts500 = cell2mat(pstarts500)';

    nvert500 = size(vertex500,2);
    clear options;
    options500.end_points = [];
    options500.W = ones(nvert500,1);
    options500.nb_iter_max = Inf;

    [D500,S500,Q500] = perform_fast_marching_mesh(vertex500, faces500, pstarts500, options500);
    [Qexact500,DQ500, voronoi_edges500, edges_id500, lambda500, Djj500] = compute_voronoi_mesh(vertex500, faces500, pstarts500, options500);

    options500.voronoi_edges = voronoi_edges500;  
    ve500 = voronoi_edges500;

    %% Neighs and area
    [sortedDjj500, SortedDjjIndices500] = sort(Djj500, 2);
    uniqueVe500 = unique(ve500, 'rows');
    veInVertexBool500 = ismember(vertex500', ve500(1:3,:)', 'rows');
    neighs500 = SortedDjjIndices500(veInVertexBool500, 1:2);

    neighsmat500 = neighs500;

    numNeighs500 = [];
    neighsArray500 = [];
    labels500  = unique(pstarts500, 'stable');

    for cellIx500 = 1:length(labels500)
        cellId500 = cellIx500;
        numNeighs500 = [numNeighs500; length(unique([(unique(neighsmat500(neighsmat500(:, 1)==cellId500, 2))); unique(neighsmat500(neighsmat500(:, 2)==cellId500, 1))]))];
        neighsArray500 = [neighsArray500, {unique([(unique(neighsmat500(neighsmat500(:, 1)==cellId500, 2))); unique(neighsmat500(neighsmat500(:, 2)==cellId500, 1))])}];
    end

    uniqueLabels500 = unique(pstarts500, 'stable');
    areaArray500 = [];
    perimArray500 = [];

    for cellIx500 = 1:length(uniqueLabels500)
        cellId500 = uniqueLabels500(cellIx500);
        [area500, perim500] = calculateArea(vertex500, faces500, Q500, cellId500);
        areaArray500 = [areaArray500; area500];
        perimArray500 = [perimArray500; perim500];
    end

    [totalArea500, ~] = calculateArea(vertex500, faces500, Q500, []);

    infoTable500 = table(unique(pstarts500, 'stable'), areaArray500, perimArray500, repelem(totalArea500, size(numNeighs500,1))', numNeighs500, neighsArray500');
    infoTable500.Properties.VariableNames = {'id', 'cell_area', 'perim_area', 'total_ellipsoid_area', 'numNeighs', 'neighs'};

    fileName = strcat('voronoiModel_', date, '_principalAxisLength_', num2str(75), '_', num2str(100), '_', num2str(100), '_nSeeds_', num2str(nSeeds), '_nDots_', num2str(500), '_lloydIters_', num2str(1), '_runId_', num2str(ix500), '_LAYER_', num2str(0));

    writetable(infoTable500, strcat(savePath, fileName, '.xls'));
    save(strcat(savePath, fileName), '-v7.3')

    %% 750
    ix750=ix;
    ellipsoidInfo750 = struct();
    ellipsoidInfo750.xCenter = 0;
    ellipsoidInfo750.yCenter = 0;
    ellipsoidInfo750.zCenter = 0;
    ellipsoidInfo750.resolutionEllipse = 750;
    ellipsoidInfo750.xRadius = 75;
    ellipsoidInfo750.yRadius = 100;
    ellipsoidInfo750.zRadius = 100;

    [vertexPstarts750, X750, Y750, Z750] = getAugmentedCentroids( ellipsoidInfo750, originalPoints', 0 );

    coordinates750 = [X750(:),Y750(:),Z750(:)];
    coordinates750 = unique(coordinates750,'rows');
    shp750 = alphaShape(coordinates750);
    shp750.Alpha = 2*shp750.Alpha;
    vertex750 = shp750.Points';
    faces750 = shp750.boundaryFacets';

    pstarts750 = arrayfun(@(pstarts2ID) find(ismember(vertex750', vertexPstarts750(pstarts2ID,:), 'rows')), 1:size(vertexPstarts750, 1), 'UniformOutput', false);
    pstarts750 = cell2mat(pstarts750)';

    nvert750 = size(vertex750,2);
    clear options;
    options750.end_points = [];
    options750.W = ones(nvert750,1);
    options750.nb_iter_max = Inf;

    [D750,S750,Q750] = perform_fast_marching_mesh(vertex750, faces750, pstarts750, options750);
    [Qexact750,DQ750, voronoi_edges750, edges_id750, lambda750, Djj750] = compute_voronoi_mesh(vertex750, faces750, pstarts750, options750);

    options750.voronoi_edges = voronoi_edges750;  
    ve750 = voronoi_edges750;

    %% Neighs and area
    [sortedDjj750, SortedDjjIndices750] = sort(Djj750, 2);
    uniqueVe750 = unique(ve750, 'rows');
    veInVertexBool750 = ismember(vertex750', ve750(1:3,:)', 'rows');
    neighs750 = SortedDjjIndices750(veInVertexBool750, 1:2);

    neighsmat750 = neighs750;

    numNeighs750 = [];
    neighsArray750 = [];
    labels750  = unique(pstarts750, 'stable');

    for cellIx750 = 1:length(labels750)
        cellId750 = cellIx750;
        numNeighs750 = [numNeighs750; length(unique([(unique(neighsmat750(neighsmat750(:, 1)==cellId750, 2))); unique(neighsmat750(neighsmat750(:, 2)==cellId750, 1))]))];
        neighsArray750 = [neighsArray750, {unique([(unique(neighsmat750(neighsmat750(:, 1)==cellId750, 2))); unique(neighsmat750(neighsmat750(:, 2)==cellId750, 1))])}];
    end

    uniqueLabels750 = unique(pstarts750, 'stable');
    areaArray750 = [];
    perimArray750 = [];

    for cellIx750 = 1:length(uniqueLabels750)
        cellId750 = uniqueLabels750(cellIx750);
        [area750, perim750] = calculateArea(vertex750, faces750, Q750, cellId750);
        areaArray750 = [areaArray750; area750];
        perimArray750 = [perimArray750; perim750];
    end

    [totalArea750, ~] = calculateArea(vertex750, faces750, Q750, []);

    infoTable750 = table(unique(pstarts750, 'stable'), areaArray750, perimArray750, repelem(totalArea750, size(numNeighs750,1))', numNeighs750, neighsArray750');
    infoTable750.Properties.VariableNames = {'id', 'cell_area', 'perim_area', 'total_ellipsoid_area', 'numNeighs', 'neighs'};

    fileName = strcat('voronoiModel_', date, '_principalAxisLength_', num2str(75), '_', num2str(100), '_', num2str(100), '_nSeeds_', num2str(nSeeds), '_nDots_', num2str(750), '_lloydIters_', num2str(1), '_runId_', num2str(ix750), '_LAYER_', num2str(0));

    writetable(infoTable750, strcat(savePath, fileName, '.xls'));
    save(strcat(savePath, fileName), '-v7.3')


    %% 1000
    ix1000=ix;
    ellipsoidInfo1000 = struct();
    ellipsoidInfo1000.xCenter = 0;
    ellipsoidInfo1000.yCenter = 0;
    ellipsoidInfo1000.zCenter = 0;
    ellipsoidInfo1000.resolutionEllipse = 1000;
    ellipsoidInfo1000.xRadius = 75;
    ellipsoidInfo1000.yRadius = 100;
    ellipsoidInfo1000.zRadius = 100;

    [vertexPstarts1000, X1000, Y1000, Z1000] = getAugmentedCentroids( ellipsoidInfo1000, originalPoints', 0 );

    coordinates1000 = [X1000(:),Y1000(:),Z1000(:)];
    coordinates1000 = unique(coordinates1000,'rows');
    shp1000 = alphaShape(coordinates1000);
    shp1000.Alpha = 2*shp1000.Alpha;
    vertex1000 = shp1000.Points';
    faces1000 = shp1000.boundaryFacets';

    pstarts1000 = arrayfun(@(pstarts2ID) find(ismember(vertex1000', vertexPstarts1000(pstarts2ID,:), 'rows')), 1:size(vertexPstarts1000, 1), 'UniformOutput', false);
    pstarts1000 = cell2mat(pstarts1000)';


    nvert1000 = size(vertex1000,2);
    clear options;
    options1000.end_points = [];
    options1000.W = ones(nvert1000,1);
    options1000.nb_iter_max = Inf;

    [D1000,S1000,Q1000] = perform_fast_marching_mesh(vertex1000, faces1000, pstarts1000, options1000);
    [Qexact1000,DQ1000, voronoi_edges1000, edges_id1000, lambda1000, Djj1000] = compute_voronoi_mesh(vertex1000, faces1000, pstarts1000, options1000);

    options1000.voronoi_edges = voronoi_edges1000;  
    ve1000 = voronoi_edges1000;

    %% Neighs and area
    [sortedDjj1000, SortedDjjIndices1000] = sort(Djj1000, 2);
    uniqueVe1000 = unique(ve1000, 'rows');
    veInVertexBool1000 = ismember(vertex1000', ve1000(1:3,:)', 'rows');
    neighs1000 = SortedDjjIndices1000(veInVertexBool1000, 1:2);

    neighsmat1000 = neighs1000;

    numNeighs1000 = [];
    neighsArray1000 = [];
    labels1000  = unique(pstarts1000, 'stable');

    for cellIx1000 = 1:length(labels1000)
        cellId1000 = cellIx1000;
        numNeighs1000 = [numNeighs1000; length(unique([(unique(neighsmat1000(neighsmat1000(:, 1)==cellId1000, 2))); unique(neighsmat1000(neighsmat1000(:, 2)==cellId1000, 1))]))];
        neighsArray1000 = [neighsArray1000, {unique([(unique(neighsmat1000(neighsmat1000(:, 1)==cellId1000, 2))); unique(neighsmat1000(neighsmat1000(:, 2)==cellId1000, 1))])}];
    end

    uniqueLabels1000 = unique(pstarts1000, 'stable');
    areaArray1000 = [];
    perimArray1000 = [];

    for cellIx1000 = 1:length(uniqueLabels1000)
        cellId1000 = uniqueLabels1000(cellIx1000);
        [area1000, perim1000] = calculateArea(vertex1000, faces1000, Q1000, cellId1000);
        areaArray1000 = [areaArray1000; area1000];
        perimArray1000 = [perimArray1000; perim1000];
    end

    [totalArea1000, ~] = calculateArea(vertex1000, faces1000, Q1000, []);

    infoTable1000 = table(unique(pstarts1000, 'stable'), areaArray1000, perimArray1000, repelem(totalArea1000, size(numNeighs1000,1))', numNeighs1000, neighsArray1000');
    infoTable1000.Properties.VariableNames = {'id', 'cell_area', 'perim_area', 'total_ellipsoid_area', 'numNeighs', 'neighs'};

    fileName = strcat('voronoiModel_', date, '_principalAxisLength_', num2str(75), '_', num2str(100), '_', num2str(100), '_nSeeds_', num2str(nSeeds), '_nDots_', num2str(1000), '_lloydIters_', num2str(1), '_runId_', num2str(ix1000), '_LAYER_', num2str(0));

    writetable(infoTable1000, strcat(savePath, fileName, '.xls'));
    save(strcat(savePath, fileName), '-v7.3')
    
end