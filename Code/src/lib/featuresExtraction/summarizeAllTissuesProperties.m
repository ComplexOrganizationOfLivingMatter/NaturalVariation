function summarizeAllTissuesProperties(allGeneralInfo,allTissues,allLumens,allHollowTissue3dFeatures,allNetworkFeatures,totalMeanCellsFeatures,totalStdCellsFeatures,path2save)


    allGeneralInfo = vertcat(allGeneralInfo{:});
    allTissues = vertcat(allTissues{:});
    allLumens = vertcat(allLumens{:});
    allHollowTissue3dFeatures = vertcat(allHollowTissue3dFeatures{:});
    allNetworkFeatures= vertcat(allNetworkFeatures{:});
    totalMeanCellsFeatures = vertcat(totalMeanCellsFeatures{:});
    totalStdCellsFeatures = vertcat(totalStdCellsFeatures{:});

    
    allTissues.Properties.VariableNames = cellfun(@(x) strcat('Tissue_', x), allTissues.Properties.VariableNames, 'UniformOutput', false);
    allHollowTissue3dFeatures.Properties.VariableNames = cellfun(@(x) strcat('HollowTissue_', x), allHollowTissue3dFeatures.Properties.VariableNames, 'UniformOutput', false);
    allLumens.Properties.VariableNames = cellfun(@(x) strcat('Lumen_', x), allLumens.Properties.VariableNames, 'UniformOutput', false);
    totalMeanCellsFeatures.Properties.VariableNames = cellfun(@(x) strcat('AverageCell_', x(5:end)), totalMeanCellsFeatures.Properties.VariableNames, 'UniformOutput', false);
    totalStdCellsFeatures.Properties.VariableNames = cellfun(@(x) strcat('STDCell_', x(5:end)), totalStdCellsFeatures.Properties.VariableNames, 'UniformOutput', false);
    

    PercentageLumenSpace = table(allLumens.Lumen_Volume./allTissues.Tissue_Volume,'VariableNames',{'PercentageLumenSpace'});
    FeaturesPerCell=table(allTissues.Tissue_Volume./allGeneralInfo.NCells, allHollowTissue3dFeatures.HollowTissue_Volume./allGeneralInfo.NCells, allLumens.Lumen_Volume./allGeneralInfo.NCells,'VariableNames',{'TissueVolume_perCell','HollowTissueVolume_perCell','LumenVolume_perCell'});
    
    
    %%Global parameters
    globalFeatures = [allGeneralInfo(:,[1,3]),allTissues(:,[4,8]),allHollowTissue3dFeatures(:,2),PercentageLumenSpace(:,1),allGeneralInfo(:,[2,4,5]),allTissues(:,[6,2,5,7,9,11]),FeaturesPerCell,allLumens(:,[6,2,5,7,9,4,8,11]),allHollowTissue3dFeatures(:,[6,7,9,4,8])];
    writetable(globalFeatures, [path2save,'global_3dFeatures' date '.xls'],'Sheet', 'globalFeatures','Range','B2');
    %%Polygon distribtutions
    polDistributions = [allGeneralInfo(:,1),allTissues(:,12:35)];
    writetable(polDistributions, [path2save,'global_3dFeatures' date '.xls'],'Sheet', 'polygonDistributions','Range','B2');
    %%Celullar parameters
    cellularParameter_mean = [allGeneralInfo(:,1),totalMeanCellsFeatures(:,[12,14,16,17,18,1,11,13,15,4,5,6,8,3,7,10]),allNetworkFeatures(:,[1,2])];
    writetable(cellularParameter_mean, [path2save,'global_3dFeatures' date '.xls'],'Sheet', 'meanCellParameters','Range','B2');

    %%Std parameters
    cellularParameter_std = [allGeneralInfo(:,1),totalStdCellsFeatures(:,[12,14,16,17,18,1,11,13,15,4,5,6,8,3,7,10]),allNetworkFeatures(:,[4,5])];
    writetable(cellularParameter_std, [path2save,'global_3dFeatures' date '.xls'],'Sheet', 'stdCellParameters','Range','B2');


    
end

