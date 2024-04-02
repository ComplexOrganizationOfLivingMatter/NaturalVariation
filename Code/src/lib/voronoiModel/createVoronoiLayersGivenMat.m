function createVoronoiLayersGivenMat()

% path = '/media/pedro/6TB/jesus/NaturalVariation/voronoi_SELECTED/bySeeds/';
path = '/media/pedro/6TB/jesus/NaturalVariation/voronoi_SELECTED/bySeeds/30/';

% matDir = dir(strcat(path, '*/*/*.mat'));
matDir = dir(strcat(path, '*/*.mat'));


surfaceRatioList = [8,2.45;16,2.08;20,1.91;30,1.52; 50,1.42;100,1.40; 500,1.15;1000,1.03];

numLayers = 2;

for dirIx = 1:numel(matDir)
    try

        name = matDir(dirIx).name;
        folder = matDir(dirIx).folder;

        nameClean = strsplit(name, '.mat');
        nameClean = nameClean{1};
        disp(strcat('working with ', nameClean))


        fullapicalxlsPath =  strcat(folder, '/', nameClean, '.xls');
        fullapicalmatPath = strcat(folder, '/', name);

        fullbasalxlsWritePath = strcat(folder, '/', nameClean, 'BASAL', '.xls');
        fullbasalmatWritePath = strcat(folder, '/', nameClean, 'BASAL', '.mat');

        full3DInfoPath = strcat(folder, '/', nameClean, '3D_info', '.xls');
            
        if exist(full3DInfoPath, 'file')==2 | exist(strrep(full3DInfoPath, 'BASAL', ''), 'file')==2
            disp(strcat('skipping ', nameClean))
            continue
        else

            load(strcat(folder, '/', name))

            surfaceRatio = surfaceRatioList(find(surfaceRatioList(:,1)==nSeeds), 2);
            layerIx = 1;

            %% Layers
            cellHeight = ellipsoidAxis2*surfaceRatio-ellipsoidAxis2;
            step = cellHeight;

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

            writetable(infoTable, fullbasalxlsWritePath);
            save(fullbasalmatWritePath, '-v7.3')

        %     basalFileName = fileName;

           apicalFileName = strcat('voronoiModel_', date, '_principalAxisLength_', num2str(ellipsoidAxis1), '_', num2str(ellipsoidAxis2), '_', num2str(ellipsoidAxis3), '_nSeeds_', num2str(nSeeds), '_nDots_', num2str(nDots), '_lloydIters_', num2str(lloydIter), '_runId_', num2str(runId), '_LAYER_', num2str(0));

           tableLayerApical = readtable(fullapicalxlsPath);
           tableLayerBasal = readtable(fullbasalxlsWritePath);

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

            writetable(dataTable, full3DInfoPath);
        end
    catch
        continue
    end
           
end