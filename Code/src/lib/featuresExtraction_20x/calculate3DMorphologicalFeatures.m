function [allGeneralInfo,allTissues,allLumens,allHollowTissue3dFeatures,allNetworkFeatures,totalMeanCellsFeatures,totalStdCellsFeatures]=calculate3DMorphologicalFeatures(labelledImage,apicalLayer,basalLayer,lateralLayer,lumenImage,path2save,fileName,pixelScale,contactThreshold,validCells,noValidCells, dilatedVx)
    % calculate3DMorphologicalFeatures calculates all 3D morphological
    % features needed
    %
    % inputs:
    %
    %   labelledImage: 3D labels (instances)
    %
    %   apicalLayer, basalLayer, lateralLayer, lumenImage: Outputs of
    %   the function called getApicalBasalLateralAndLumenFromCyst
    %
    %   path2save: Path to save the features as mat files. Be careful, if
    %   the directory exists the features will be loaded from the mat file
    %   instead of calculated
    %
    %   fileName: ID of the analyzed sample. Eg: '10d.3C.2_2'
    %
    %   pixelScale: micron/pixel relation.
    %
    %   contactThreshold: Deafult is 0.5 meaning that at least the 0.5%
    %   of lateral membrane contacting with other cell to be1 considered
    %   as neighbor.
    %
    %   validCells and noValidCells: You can leave them empty (eg: []) 
    %   and the function will calculate both valid and not-valid cells.
    %
    %   dilatedVx: dilate factor used in getLateralContacts inside
    %   obtain3DFeatures. 4 is default for glands.


    if ~exist(path2save,'dir') && ~isempty(path2save) 
        mkdir(path2save)
    end
    
    if (~exist(fullfile(path2save, 'global_3dFeatures.mat'),'file') || isempty(path2save))
        %defining all cells as valid cells
        if isempty(validCells)
            validCells = find(table2array(regionprops3(labelledImage,'Volume'))>0);
            noValidCells = [];
        end

        %% Obtain 3D features from Cells, Tissue, Lumen and Tissue+Lumen
        [cells3dFeatures, tissue3dFeatures, lumen3dFeatures,hollowTissue3dFeatures, polygon_distribution_apical, polygon_distribution_basal,polygon_distribution_lateral, numValidCells,numTotalCells, surfaceRatio3D, validCells, apicoBasalNeighs] = obtain3DFeatures(labelledImage,apicalLayer,basalLayer,lateralLayer,lumenImage,validCells,noValidCells,path2save,contactThreshold, dilatedVx);
        
        %% Calculate Network features
        [degreeNodesCorrelation,coefCluster,betweennessCentrality] = obtainNetworksFeatures(apicoBasalNeighs,validCells, fullfile(path2save, 'network3dFeatures.mat'));
        allNetworkFeatures = cell2table([{mean(coefCluster)}, {mean(betweennessCentrality)},{degreeNodesCorrelation} {std(coefCluster)},{std(betweennessCentrality)}],'VariableNames',{'mean_coefCluster','mean_betCentrality','degreeNodesCorrelation','std_coefCluster','std_betCentrality'});

        
        %% Calculate mean and std of 3D features
        cells3dFeatures((cells3dFeatures.ID_Cell == "Lumen" | cells3dFeatures.ID_Cell == "Tissue and Lumen"),:)=[];
        meanCellsFeatures = varfun(@(x) mean(x, 'omitnan'),cells3dFeatures(:, 2:end-2));
        meanCellsFeatures.Properties.VariableNames = cellfun(@(x) strrep(x, 'Fun', 'mean_cell'), meanCellsFeatures.Properties.VariableNames, 'UniformOutput', false);    

        stdCellsFeatures = varfun(@(x) std(x, 'omitnan'),cells3dFeatures(:, 2:end-2));
        stdCellsFeatures.Properties.VariableNames = cellfun(@(x) strrep(x, 'Fun', 'std_cell'), stdCellsFeatures.Properties.VariableNames, 'UniformOutput', false);    

        % Voxels/Pixels to Micrometers
        [totalMeanCellsFeatures,totalStdCellsFeatures, tissue3dFeatures, allLumens,allHollowTissue3dFeatures] = convertPixelsToMicrons(meanCellsFeatures,stdCellsFeatures, tissue3dFeatures, lumen3dFeatures,hollowTissue3dFeatures,pixelScale);

        allTissues = [tissue3dFeatures, cell2table(polygon_distribution_apical(2, :), 'VariableNames', strcat('apical_', polygon_distribution_apical(1, :))), cell2table(polygon_distribution_basal(2, :), 'VariableNames', strcat('basal_', polygon_distribution_basal(1, :))), cell2table(polygon_distribution_lateral(2, :), 'VariableNames', strcat('lateral_', polygon_distribution_lateral(1, :)))];
        allGeneralInfo = cell2table([{fileName}, {surfaceRatio3D}, {numValidCells},{numTotalCells},{mean(cells3dFeatures.scutoids)},{mean(cells3dFeatures.apicoBasalTransitions)}],'VariableNames', {'ID_Glands', 'SurfaceRatio3D_areas', 'NCells_valid','NCells_total','Scutoids','ApicoBasalTransitions'});

        if ~isempty(path2save)
            save(fullfile(path2save, 'global_3dFeatures.mat'), 'allGeneralInfo', 'totalMeanCellsFeatures','totalStdCellsFeatures', 'allLumens', 'allTissues', 'allNetworkFeatures', 'allHollowTissue3dFeatures');
        end
    else
        load(fullfile(path2save, 'global_3dFeatures.mat'), 'allGeneralInfo', 'totalMeanCellsFeatures','totalStdCellsFeatures', 'allLumens', 'allTissues', 'allNetworkFeatures', 'allHollowTissue3dFeatures');
    end
    
    

end

