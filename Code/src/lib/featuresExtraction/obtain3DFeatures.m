function [cells3dFeatures, tissue3dFeatures, lumen3dFeatures,hollowTissue3dFeatures, polygon_distribution_apical, polygon_distribution_basal, cellularFeaturesAllCells, numCells, surfaceRatio3D, validCells, polygon_distribution_total,apicoBasalNeighs] = obtain3DFeatures(labelledImage,apicalLayer,basalLayer,lumenImage,validCells,path2save)

    if ~exist(fullfile(path2save, 'morphological3dFeatures.mat'),'file')
       
        %% Cellular features
        [apical3dInfo] = calculateNeighbours3D(apicalLayer, 2, apicalLayer == 0);
        apical3dInfo = apical3dInfo.neighbourhood';

        [basal3dInfo] = calculateNeighbours3D(basalLayer, 2, basalLayer == 0);
        basal3dInfo = basal3dInfo.neighbourhood';

        totalCells = 1:size(regionprops3(labelledImage,'Volume'),1);
        noValidCells = setdiff(totalCells,validCells);

        %% Obtain cells descriptors
        % get apical, basal and total sides cells. Areas and cell Volume
        [cellularFeaturesValidCells,cellularFeaturesAllCells,surfaceRatio3D,apicoBasalNeighs,polygon_distribution] = calculate_CellularFeatures(apical3dInfo,basal3dInfo,apicalLayer,basalLayer,labelledImage,noValidCells,validCells);
        %%Extract each cell and calculate 3D features
        [cells3dFeatures] = extract3dDescriptors(labelledImage, validCells');
        
        polygon_distribution_basal= polygon_distribution.Basal;
        polygon_distribution_apical = polygon_distribution.Apical;
        basalInfo = table(cellularFeaturesValidCells.Basal_sides, cellularFeaturesValidCells.Basal_area);
        apicalInfo = table(cellularFeaturesValidCells.Apical_sides, cellularFeaturesValidCells.Apical_area);
        polygon_distribution_total = calculate_polygon_distribution(cellfun(@(x,y) length(unique([x;y])), apical3dInfo, basal3dInfo), validCells);
        cells3dFeatures = horzcat(cells3dFeatures, apicalInfo, basalInfo);

        %% Obtain Lumen descriptors
        [lumen3dFeatures] = extract3dDescriptors(lumenImage>0, 1);
        lumen3dFeatures.ID_Cell = 'Lumen';

        %% Obtain Tissue descriptors
        [hollowTissue3dFeatures] = extract3dDescriptors(labelledImage>0, 1);
        hollowTissue3dFeatures.ID_Cell = 'Tissue';

        %% Obtain Tissue + Lumen descriptors
        [tissue3dFeatures] = extract3dDescriptors(labelledImage>0|lumenImage>0, 1);
        tissue3dFeatures.ID_Cell = 'Tissue and Lumen';

        numCells = length(validCells);

        %% Save variables
        save(fullfile(path2save, 'morphological3dFeatures.mat'), 'cells3dFeatures', 'tissue3dFeatures', 'lumen3dFeatures', 'polygon_distribution_apical', 'polygon_distribution_basal', 'cellularFeaturesValidCells','cellularFeaturesAllCells', 'numCells', 'surfaceRatio3D', 'polygon_distribution_total','apicoBasalNeighs', 'hollowTissue3dFeatures');

    else
        load(fullfile(path2save, 'morphological3dFeatures.mat'), 'cells3dFeatures', 'tissue3dFeatures', 'lumen3dFeatures', 'polygon_distribution_apical', 'polygon_distribution_basal', 'cellularFeaturesValidCells','cellularFeaturesAllCells', 'numCells', 'surfaceRatio3D', 'polygon_distribution_total','apicoBasalNeighs', 'hollowTissue3dFeatures');
    end
end

