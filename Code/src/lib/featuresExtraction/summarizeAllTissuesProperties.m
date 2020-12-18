function summarizeAllTissuesProperties(allGeneralInfo,allTissues,allLumens,allHollowTissue3dFeatures,allNetworkFeatures,totalMeanCellsFeatures,totalStdCellsFeatures,totalMean3DNeighsFeatures,totalSTD3DNeighsFeatures,path2save)


    allGeneralInfo = cell2table(allGeneralInfo, 'VariableNames', {'ID_Glands', 'SurfaceRatio3D', 'SurfaceRatio2D', 'NCells'});
    allTissues = cell2table(allTissues, 'VariableNames', {'ID_Cell','Volume','EquivDiameter','PrincipalAxisLength','ConvexVolume','Solidity','SurfaceArea','aspectRatio','sphericity','normalizedVolume','basalNumNeighs','basal_area_cells2D','basal_area_cells3D', 'apicalNumNeighs','apical_area_cells2D','apical_area_cells3D','percentageScutoids','totalNeighs','apicoBasalTransitions','apical_triangles','apical_squares','apical_pentagons','apical_hexagons','apical_heptagons','apical_octogons','apical_nonagons','apical_decagons','basal_triangles','basal_squares','basal_pentagons','basal_hexagons','basal_heptagons','basal_octogons','basal_nonagons','basal_decagons', 'total_triangles','total_squares','total_pentagons','total_hexagons','total_heptagons','total_octogons','total_nonagons','total_decagons'});
    allLumens = cell2table(allLumens, 'VariableNames', {'ID_Cell','Volume','EquivDiameter','PrincipalAxisLength','ConvexVolume','Solidity','SurfaceArea','aspectRatio','sphericity','normalizedVolume','basalNumNeighs','basal_area_cells2D','basal_area_cells3D', 'apicalNumNeighs','apical_area_cells2D','apical_area_cells3D','percentageScutoids','totalNeighs','apicoBasalTransitions'});
    allHollowTissue3dFeatures = cell2table(allHollowTissue3dFeatures, 'VariableNames',  {'ID_Cell','Volume','EquivDiameter','PrincipalAxisLength','ConvexVolume','Solidity','SurfaceArea','aspectRatio','sphericity','normalizedVolume','basalNumNeighs','basal_area_cells2D','basal_area_cells3D', 'apicalNumNeighs','apical_area_cells2D','apical_area_cells3D','percentageScutoids','totalNeighs','apicoBasalTransitions'});
    allNetworkFeatures= cell2table(allNetworkFeatures, 'VariableNames', {'Coeficient_Cluster', 'Betweenness_Centrality', 'Assortativity', 'coeficient_Cluster_STD','Betweenness_Centrality_STD'});
    totalMeanCellsFeatures = cell2table(totalMeanCellsFeatures, 'VariableNames', {'Fun_Volume','Fun_EquivDiameter','Fun_PrincipalAxisLength','Fun_ConvexVolume','Fun_Solidity','Fun_SurfaceArea','Fun_aspectRatio','Fun_sphericity','Fun_normalizedVolume','Fun_apicalNumNeighs','Fun_apical_area_cells2D','Fun_apical_area_cells3D','Fun_basalNumNeighs','Fun_basal_area_cells2D','Fun_basal_area_cells3D','Fun_percentageScutoids','Fun_totalNeighs','Fun_apicoBasalTransitions'});
    totalStdCellsFeatures = cell2table(totalStdCellsFeatures, 'VariableNames', {'Fun_Volume','Fun_EquivDiameter','Fun_PrincipalAxisLength','Fun_ConvexVolume','Fun_Solidity','Fun_SurfaceArea','Fun_aspectRatio','Fun_sphericity','Fun_normalizedVolume','Fun_apicalNumNeighs','Fun_apical_area_cells2D','Fun_apical_area_cells3D','Fun_basalNumNeighs','Fun_basal_area_cells2D','Fun_basal_area_cells3D','Fun_percentageScutoids','Fun_totalNeighs','Fun_apicoBasalTransitions'});
    totalMean3DNeighsFeatures = cell2table(totalMean3DNeighsFeatures, 'VariableNames', {'Fun_Apical_sides','Fun_Basal_sides','Fun_Total_neighbours','Fun_Apicobasal_neighbours','Fun_Scutoids','Fun_apicoBasalTransitions'});
    totalSTD3DNeighsFeatures = cell2table(totalSTD3DNeighsFeatures, 'VariableNames', {'Fun_Apical_sides','Fun_Basal_sides','Fun_Total_neighbours','Fun_Apicobasal_neighbours','Fun_Scutoids','Fun_apicoBasalTransitions'});
    
    allTissues.Properties.VariableNames = cellfun(@(x) strcat('Tissue_', x), allTissues.Properties.VariableNames, 'UniformOutput', false);
    allHollowTissue3dFeatures.Properties.VariableNames = cellfun(@(x) strcat('HollowTissue_', x), allHollowTissue3dFeatures.Properties.VariableNames, 'UniformOutput', false);
    allLumens.Properties.VariableNames = cellfun(@(x) strcat('Lumen_', x), allLumens.Properties.VariableNames, 'UniformOutput', false);
    totalMeanCellsFeatures.Properties.VariableNames = cellfun(@(x) strcat('AverageCell_', x(5:end)), totalMeanCellsFeatures.Properties.VariableNames, 'UniformOutput', false);
    totalStdCellsFeatures.Properties.VariableNames = cellfun(@(x) strcat('STDCell_', x(5:end)), totalStdCellsFeatures.Properties.VariableNames, 'UniformOutput', false);
    
    totalMean3DNeighsFeatures.Properties.VariableNames = cellfun(@(x) strcat('AverageCell_3D', x(5:end)), totalMean3DNeighsFeatures.Properties.VariableNames, 'UniformOutput', false);
    totalSTD3DNeighsFeatures.Properties.VariableNames = cellfun(@(x) strcat('STDCell_3D', x(5:end)), totalSTD3DNeighsFeatures.Properties.VariableNames, 'UniformOutput', false);

    allFeatures = [allGeneralInfo,totalMeanCellsFeatures,totalStdCellsFeatures, allTissues, allLumens, totalMean3DNeighsFeatures, totalSTD3DNeighsFeatures];
    % The order of the head is the following: nCell, (Basal, apical area and SR 2D), (Basal, apical area and SR 3D), (Basal, apical and
    % apicobasal N-2D), (basal apical and apicobasal N-3D),Scutoids2D and 3D,apicobasalTransition 2D and 3D, 2D poligon
    % distribution, (Volumen,ConvexVolume and Solidity Cells),(Surface Area cell, 
    % Sphericity cells), AxisLength cells, AspectRatio cells, (Volumen,ConvexVolume and Solidity Gland),SurfaceArea and sphericity Gland, AxisLength Gland, AspectRatio Gland
    % (Volumen,ConvexVolume and Solidity Lumen), SurfaceArea and sphericity Lumen, 
    % AxisLength Lumen, AspectRatio Lumen,percentageLumenSpace,hollowGland Features, networkFeatures(coeficient clustering,betweenness centrality and assortativity)
    PercentageLumenSpace = table(table2array(allFeatures(:,85)) ./ table2array(allFeatures(:,42))); 
    PercentageLumenSpace.Properties.VariableNames = {'PercentageLumenSpace'};
    FeaturesPerCell=array2table([table2array(allFeatures(:,42))./ table2array(allFeatures(:,4)), table2array(allHollowTissue3dFeatures(:,2))./ table2array(allFeatures(:,4)), table2array(allFeatures(:,85))./ table2array(allFeatures(:,4))]); 
    FeaturesPerCell.Properties.VariableNames = {'GlandVolume_perCell','HollowGlandVolume_perCell','LumenVolume_perCell'};
    
    finalTable = [allFeatures(:,1), allFeatures(:,4),allFeatures(:,15), allFeatures(:,18), allFeatures(:,3),allFeatures(:,16), allFeatures(:,19),allFeatures(:,2),allFeatures(:,14),allFeatures(:,17),allFeatures(:,21),totalMean3DNeighsFeatures(:,1),totalMean3DNeighsFeatures(:,2), totalMean3DNeighsFeatures(:,4), allFeatures(:,20),totalMean3DNeighsFeatures(:,5),allFeatures(:,22),totalMean3DNeighsFeatures(:,6), allFeatures(:,60:83),allFeatures(:,5),allFeatures(:,8:10),allFeatures(:,12),allFeatures(:,7),allFeatures(:,11),allFeatures(:,42),allFeatures(:,45:47),allFeatures(:,49),allFeatures(:,44), allFeatures(:,48),allFeatures(:,85),allFeatures(:,88:90),allFeatures(:,92),allFeatures(:,87),allFeatures(:,91),PercentageLumenSpace,allHollowTissue3dFeatures(:,2),allHollowTissue3dFeatures(:,5:7),allHollowTissue3dFeatures(:,9),allHollowTissue3dFeatures(:,4),allHollowTissue3dFeatures(:,8),FeaturesPerCell,allNetworkFeatures(:,1:3)];
    finalSTDTable = ([totalStdCellsFeatures(:,12),totalStdCellsFeatures(:,15),totalSTD3DNeighsFeatures(:,1:2),totalSTD3DNeighsFeatures(:,4:5),allNetworkFeatures(:,4:5),totalStdCellsFeatures(:,1),totalStdCellsFeatures(:,4:5),totalStdCellsFeatures(:,6),totalStdCellsFeatures(:,8),totalStdCellsFeatures(:,3),totalStdCellsFeatures(:,7)]);
    
    writetable(finalTable, fullfile(path2save,'global_3dFeatures.xls'),'Range','B2');
    writetable(finalSTDTable, fullfile(path2save,'global_3dFeatures.xls'),'Sheet', 2,'Range','B2');
    
    %%Global parameters
    %
    %%Celullar parameters
    
    %%Std parameters

end

