function [cells3dFeatures, tissue3dFeatures, lumen3dFeatures,hollowTissue3dFeatures, polygon_distribution_apical, polygon_distribution_basal, polygon_distribution_lateral, numValidCells,numTotalCells, surfaceRatio3D, validCells, apicoBasalNeighs] = obtain3DFeatures(labelledImage,apicalLayer,basalLayer,lateralLayer,lumenImage,validCells,path2save,contactThreshold)

    if ~exist(fullfile(path2save, 'morphological3dFeatures.mat'),'file')
       
      
        [lateral3dInfo,totalLateralCellsArea,absoluteLateralContacts] = getLateralContacts(lateralLayer,3,contactThreshold);
        %lateral3dInfo = lateral3dInfo.neighbourhood';

        %% Cellular features
        [apical3dInfo] = calculateNeighbours3D(apicalLayer, 3, apicalLayer == 0);
        apical3dInfo = cellfun(@(x,y) intersect(x,y),lateral3dInfo,apical3dInfo.neighbourhood','UniformOutput',false);
        
        [basal3dInfo] = calculateNeighbours3D(basalLayer, 3, basalLayer == 0);
        basal3dInfo = cellfun(@(x,y) intersect(x,y),lateral3dInfo,basal3dInfo.neighbourhood','UniformOutput',false);

        totalCells = 1:length(lateral3dInfo);
        noValidCells = setdiff(totalCells,validCells);

        %% Obtain cells descriptors
        % get apical, basal and lateral sides cells. Areas and cell Volume
        [cellularFeaturesValidCells,CellularFeaturesAllCells,surfaceRatio3D,apicoBasalNeighs,polygon_distribution] = calculate_CellularFeatures(apical3dInfo,basal3dInfo,lateral3dInfo,apicalLayer,basalLayer,labelledImage,totalLateralCellsArea,absoluteLateralContacts,noValidCells,validCells);
        %%Extract each cell and calculate 3D features
        [cells3dFeatures] = extract3dDescriptors(labelledImage, validCells);
        
        polygon_distribution_basal= polygon_distribution.Basal;
        polygon_distribution_apical = polygon_distribution.Apical;
        polygon_distribution_lateral = polygon_distribution.Lateral;
        
        %% Obtain Lumen descriptors
        [lumen3dFeatures] = extract3dDescriptors(lumenImage>0, 1);
        lumen3dFeatures.ID_Cell = 'Lumen';

        %% Obtain Tissue descriptors
        [hollowTissue3dFeatures] = extract3dDescriptors(labelledImage>0, 1);
        hollowTissue3dFeatures.ID_Cell = 'Tissue';

        %% Obtain Tissue + Lumen descriptors
        [tissue3dFeatures] = extract3dDescriptors(labelledImage>0|lumenImage>0, 1);
        tissue3dFeatures.ID_Cell = 'Tissue and Lumen';

        numValidCells = length(validCells);
        numTotalCells = length(totalCells);
        
        %refactor purely voxels measurement to be compared with the surface
        %area extraction 
        sumApicalAreas = sum(CellularFeaturesAllCells.Apical_area);
        sumBasalAreas = sum(CellularFeaturesAllCells.Basal_area);
        refactorBasalAreas = sumBasalAreas/tissue3dFeatures.SurfaceArea;
        refactorApicalAreas = sumApicalAreas/lumen3dFeatures.SurfaceArea;
        
        lateralAreas = cells3dFeatures.SurfaceArea - (cellularFeaturesValidCells.Apical_area./refactorApicalAreas) - (cellularFeaturesValidCells.Basal_area./refactorBasalAreas);
        refactorLateralAreas = cellularFeaturesValidCells.Lateral_area./lateralAreas;
        
        cellAreaNeighsInfo = table(cellularFeaturesValidCells.Apical_sides, cellularFeaturesValidCells.Apical_area./refactorApicalAreas,cellularFeaturesValidCells.Basal_sides, cellularFeaturesValidCells.Basal_area./refactorBasalAreas,cellularFeaturesValidCells.Lateral_sides, cellularFeaturesValidCells.Lateral_area./refactorLateralAreas,cellularFeaturesValidCells.Average_cell_wall_area./refactorLateralAreas,cellularFeaturesValidCells.Std_cell_wall_area./refactorLateralAreas,'VariableNames',{'apical_NumNeighs','apical_Area','basal_NumNeighs','basal_Area','lateral_NumNeighs','lateral_Area','average_cell_wall_Area','std_cell_wall_Area'});
        cells3dFeatures = horzcat(cells3dFeatures, cellAreaNeighsInfo,table(cellularFeaturesValidCells.Scutoids, cellularFeaturesValidCells.apicoBasalTransitions,'VariableNames',{'scutoids','apicoBasalTransitions'}));

        %% Save variables
        save(fullfile(path2save, 'morphological3dFeatures.mat'), 'cells3dFeatures', 'tissue3dFeatures', 'lumen3dFeatures', 'polygon_distribution_apical', 'polygon_distribution_basal','polygon_distribution_lateral', 'cellularFeaturesValidCells', 'numValidCells','numTotalCells', 'surfaceRatio3D', 'polygon_distribution_lateral','apicoBasalNeighs', 'hollowTissue3dFeatures');

    else
        load(fullfile(path2save, 'morphological3dFeatures.mat'), 'cells3dFeatures', 'tissue3dFeatures', 'lumen3dFeatures', 'polygon_distribution_apical', 'polygon_distribution_basal','polygon_distribution_lateral', 'cellularFeaturesValidCells', 'numValidCells','numTotalCells', 'surfaceRatio3D', 'polygon_distribution_lateral','apicoBasalNeighs', 'hollowTissue3dFeatures');
    end
end

