function [allGeneralInfo,allTissues,allLumens,allHollowTissue3dFeatures,allNetworkFeatures,totalMeanCellsFeatures,totalStdCellsFeatures,totalMean3DNeighsFeatures,totalSTD3DNeighsFeatures]=calculate3DMorphologicalFeatures(labelledImage,apicalLayer,basalLayer,lumenImage,path2save,fileName,pixelScale)

    if ~exist(path2save,'dir')
        mkdir(path2save)
    end
    
    if ~exist(fullfile(path2save, 'global_3dFeatures.mat'),'file')
        %defining all cells as valid cells
        validCells = find(table2array(regionprops3(labelledImage,'Volume'))>0);

        %% Obtain 3D features from Cells, Tissue, Lumen and Tissue+Lumen
        [cells3dFeatures, tissue3dFeatures, lumen3dFeatures,hollowTissue3dFeatures, polygon_distribution_apical, polygon_distribution_basal, cellularFeatures, numCells, surfaceRatio3D, validCells, polygon_distribution_total,apicoBasalNeighs] = obtain3DFeatures(labelledImage,apicalLayer,basalLayer,lumenImage,validCells,path2save);
        
        %% Calculate Network features
        [degreeNodesCorrelation,coefCluster,betweennessCentrality] = obtainNetworksFeatures(apicoBasalNeighs,validCells, fullfile(path2save, 'network3dFeatures.mat'));

        
        %% Calculate mean and std of 3D features
        cells3dFeatures((cells3dFeatures.ID_Cell == "Lumen" | cells3dFeatures.ID_Cell == "Tissue and Lumen"),:)=[];
        meanCellsFeatures = varfun(@(x) mean(x),cells3dFeatures(:, 2:end));
        stdFeatures = varfun(@(x) std(x),cells3dFeatures(:, 2:end));

        % Voxels/Pixels to Micrometers
        [meanCellsFeatures,stdFeatures, tissue3dFeatures, lumen3dFeatures,hollowTissue3dFeatures] = convertPixelsToMicrons(meanCellsFeatures,stdFeatures, tissue3dFeatures, lumen3dFeatures,hollowTissue3dFeatures,pixelScale);

        mean3DNeighsFeatures = varfun(@(x) mean(x), cellularFeatures(validCells, 2:end));
        std3DNeighsFeatures = varfun(@(x) std(x), cellularFeatures(validCells, 2:end));

        totalMeanCellsFeatures = table2cell(meanCellsFeatures);
        totalStdCellsFeatures = table2cell(stdFeatures);
        allTissues = table2cell([tissue3dFeatures, cell2table(polygon_distribution_apical(2, :), 'VariableNames', strcat('apical_', polygon_distribution_apical(1, :))), cell2table(polygon_distribution_basal(2, :), 'VariableNames', strcat('basal_', polygon_distribution_basal(1, :))), cell2table(polygon_distribution_total(2, :), 'VariableNames', strcat('total_', polygon_distribution_total(1, :)))]);
        allLumens = table2cell(lumen3dFeatures);
        totalMean3DNeighsFeatures = table2cell(mean3DNeighsFeatures);
        totalSTD3DNeighsFeatures = table2cell(std3DNeighsFeatures);

        allGeneralInfo = [{fileName}, {surfaceRatio3D}, {numCells}];
        allNetworkFeatures = [{mean(coefCluster)}, {mean(betweennessCentrality)},{degreeNodesCorrelation} {std(coefCluster)},{std(betweennessCentrality)}];
        allHollowTissue3dFeatures = table2cell(hollowTissue3dFeatures);


        save(fullfile(path2save, 'global_3dFeatures.mat'), 'allGeneralInfo', 'totalMeanCellsFeatures','totalStdCellsFeatures', 'allLumens', 'allTissues', 'totalMean3DNeighsFeatures', 'totalSTD3DNeighsFeatures', 'allNetworkFeatures', 'allHollowTissue3dFeatures');
    else
        
        load(fullfile(path2save, 'global_3dFeatures.mat'), 'allGeneralInfo', 'totalMeanCellsFeatures','totalStdCellsFeatures', 'allLumens', 'allTissues', 'totalMean3DNeighsFeatures', 'totalSTD3DNeighsFeatures', 'allNetworkFeatures', 'allHollowTissue3dFeatures');
    end
    
    

end

