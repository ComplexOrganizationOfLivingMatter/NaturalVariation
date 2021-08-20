function [allGeneralInfo,allTissues,allLumens,allHollowTissue3dFeatures,allNetworkFeatures,totalMeanCellsFeatures,totalStdCellsFeatures]=calculate3DMorphologicalFeatures(labelledImage,apicalLayer,basalLayer,lateralLayer,lumenImage,path2save,fileName,pixelScale,contactThreshold,validCells,noValidCells)

    if ~exist(path2save,'dir')
        mkdir(path2save)
    end
    
    if ~exist(fullfile(path2save, 'global_3dFeatures.mat'),'file')
        %defining all cells as valid cells
        if isempty(validCells)
            validCells = find(table2array(regionprops3(labelledImage,'Volume'))>0);
            noValidCells = [];
        end

        %% Obtain 3D features from Cells, Tissue, Lumen and Tissue+Lumen
        [cells3dFeatures, tissue3dFeatures, lumen3dFeatures,hollowTissue3dFeatures, polygon_distribution_apical, polygon_distribution_basal,polygon_distribution_lateral, numValidCells,numTotalCells, surfaceRatio3D, validCells, apicoBasalNeighs] = obtain3DFeatures(labelledImage,apicalLayer,basalLayer,lateralLayer,lumenImage,validCells,noValidCells,path2save,contactThreshold);
        
        %% Calculate Network features
        [degreeNodesCorrelation,coefCluster,betweennessCentrality] = obtainNetworksFeatures(apicoBasalNeighs,validCells, fullfile(path2save, 'network3dFeatures.mat'));
        allNetworkFeatures = cell2table([{mean(coefCluster)}, {mean(betweennessCentrality)},{degreeNodesCorrelation} {std(coefCluster)},{std(betweennessCentrality)}],'VariableNames',{'mean_coefCluster','mean_betCentrality','degreeNodesCorrelation','std_coefCluster','std_betCentrality'});

        
        %% Calculate mean and std of 3D features
        cells3dFeatures((cells3dFeatures.ID_Cell == "Lumen" | cells3dFeatures.ID_Cell == "Tissue and Lumen"),:)=[];
        meanCellsFeatures = varfun(@(x) mean(x),cells3dFeatures(:, 2:end-2));
        stdCellsFeatures = varfun(@(x) std(x),cells3dFeatures(:, 2:end-2));

        % Voxels/Pixels to Micrometers
        [totalMeanCellsFeatures,totalStdCellsFeatures, tissue3dFeatures, allLumens,allHollowTissue3dFeatures] = convertPixelsToMicrons(meanCellsFeatures,stdCellsFeatures, tissue3dFeatures, lumen3dFeatures,hollowTissue3dFeatures,pixelScale);

        allTissues = [tissue3dFeatures, cell2table(polygon_distribution_apical(2, :), 'VariableNames', strcat('apical_', polygon_distribution_apical(1, :))), cell2table(polygon_distribution_basal(2, :), 'VariableNames', strcat('basal_', polygon_distribution_basal(1, :))), cell2table(polygon_distribution_lateral(2, :), 'VariableNames', strcat('lateral_', polygon_distribution_lateral(1, :)))];
        allGeneralInfo = cell2table([{fileName}, {surfaceRatio3D}, {numValidCells},{numTotalCells},{mean(cells3dFeatures.scutoids)},{mean(cells3dFeatures.apicoBasalTransitions)}],'VariableNames', {'ID_Glands', 'SurfaceRatio3D_areas', 'NCells_valid','NCells_total','Scutoids','ApicoBasalTransitions'});

        save(fullfile(path2save, 'global_3dFeatures.mat'), 'allGeneralInfo', 'totalMeanCellsFeatures','totalStdCellsFeatures', 'allLumens', 'allTissues', 'allNetworkFeatures', 'allHollowTissue3dFeatures');
    else
        
        load(fullfile(path2save, 'global_3dFeatures.mat'), 'allGeneralInfo', 'totalMeanCellsFeatures','totalStdCellsFeatures', 'allLumens', 'allTissues', 'allNetworkFeatures', 'allHollowTissue3dFeatures');
    end
    
    

end

