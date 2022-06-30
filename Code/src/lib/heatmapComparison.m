function heatmapComparison(tablePath, variables, variablesCorr)
    % heatmapComparison creates a heatmap using an xls file
    % 
    %heatmapComparison(tablePath, variables, variablesCorr)
    %
    %tablePath is the full path to the xls file.
    %
    % The xls file must have the following form:
    %   condition | id_glands | hollowTissue_solidity | N_Cells |...
    %       10d.HX3 | 10d.1HX3.1|                  0.95 |     157 |...
    %       7d.none |  7d.4C.1.2|                  0.88 |      89 |...
    %           ... |        ...|                   ... |     ... |...
    %
    %variables is the list of variables for the heatmapComparison
    %variablesCorr is the list of variables for the correlation matrix
    %
    %variables and variablesCorr must have the following form:
    %variables = {'hollowTissue_solidity', 'N_Cells', ...};
    %
    % Example:
%         tablePath = '/home/pedro/Descargas/cyst20X_0.5%_global_3dFeatures_09-Sep-2021.xls';
%         variables = {'NCells_total', 'Tissue_PrincipalAxisLength_1', 'TissueVolume_perCell'};
%         variablesCorr = {'NCells_total', 'NCells_valid', 'Tissue_PrincipalAxisLength_1'};
%         heatmapComparison(tablePath, variables, variablesCorr)
    
    %% Read Table
    dataTable = readtable(tablePath);

    %% Sort data table by days, condition and id
    dataTable = sortrows(dataTable, {'condition', 'ID_Cysts'}); 

    %% Variable Selection for heatMapComparison
    %Check is all variables exist
    for variable=1:length(variables)
        if ~any(strcmp(dataTable.Properties.VariableNames,variables{variable}))
            error('Variable %s is not one in dataTable', variables{variable})
        end
    end
    
    dataTableConditionsHeatmap = dataTable(:, variables);
    
    %% Variable Selection for corr Matrix
    %Check is all variables exist
    for variable=1:length(variablesCorr)
        if ~any(strcmp(dataTable.Properties.VariableNames,variablesCorr{variable}))
            error('Variable %s is not one in dataTable', variablesCorr{variable})
        end
    end
    
    dataTableCorrleation = dataTable(:, variablesCorr);
    
    %% Variable to aggregate
    [uniqueConditions, ~, dataTable.condition_numeric] = unique(dataTable.condition);
    
%     dataTable.condition_and_day = cellfun(@(x) str2double(strrep(x, ' ', '')), cellstr(strcat(num2str(dataTable.condition_numeric), num2str(dataTable.days))));
%     tags = cellstr(strcat(num2str(dataTable.days), 'd-', dataTable.condition));
%     uniqueTags = unique(tags);
%     [uniqueConditionAndDay, ~, condition_and_day] = unique(dataTable.condition_and_day);
    
    
    %% Values to map (heatMap)
    mappingValues = dataTableConditionsHeatmap{:, :};
    
    %% Condition maps
    conditionCorrMaps = zeros(length(variablesCorr), length(variablesCorr), length(uniqueConditions));
    
    for condition=1:length(uniqueConditions)
        singleCondition = dataTable(dataTable.condition_numeric == condition, variablesCorr);
        singleConditionMap = singleCondition{:, :};
        singleConditionNorm = splitapply(@zscore,singleConditionMap,1:size(singleConditionMap,2));
        conditionCorrMaps(:, :, condition) = corrcoef(singleConditionNorm); 
    end
    
    %% Values to map (corr)
    mappingValuesCorr = dataTableCorrleation{:, :};
    
    %% Z-Score normalization (heatmap)
    normMappingValues = splitapply(@zscore,mappingValues,1:size(mappingValues,2));
   
    %% Z-Score normalization (corr)
    normMappingValuesCorr = splitapply(@zscore,mappingValuesCorr,1:size(mappingValuesCorr,2));
    
    %% Z-Score normalization (corr) without split by condition
    allCondition = dataTable(dataTable.condition_numeric > 0, variablesCorr);
    allConditionMap = allCondition{:, :};
    allConditionNorm = splitapply(@zscore,allConditionMap,1:size(allConditionMap,2));
    allConditionCorrMaps = corrcoef(allConditionNorm); 

    %% Aggregate
    aggregatedMap=cell2mat(arrayfun(@(x) accumarray(dataTable.condition_numeric,normMappingValues(:,x), [], @median),1:size(normMappingValues,2),'un',0));
    
    %% Export Z-score tables
    tableVariables = array2table(aggregatedMap,'VariableNames',variables);
    tableConditions = cell2table(uniqueConditions);
    tableZscore=[tableConditions tableVariables];
    zScoreName=strsplit(tablePath,'.xls');
    writetable(tableZscore,[zScoreName{1},'_zScoreFeatures.xls'],'Sheet', 'zScore','Range','B2');

    for nConditions = 1:size(uniqueConditions,1)
        tableVariablesCorr = array2table(conditionCorrMaps(:,:,nConditions),'VariableNames',variablesCorr);
        tableNameVariablesCorr = cell2table(variablesCorr','VariableNames',{uniqueConditions{nConditions,1}});
        tableZscoreCorr=[tableNameVariablesCorr tableVariablesCorr];
        writetable(tableZscoreCorr,[zScoreName{1},'_zScoreFeatures.xls'],'Sheet', strcat('zScoreCorr_',uniqueConditions{nConditions,1}),'Range','B2');
    end

    tableVariablesCorrAllCond = array2table(allConditionCorrMaps,'VariableNames',variablesCorr);
    tableNameVariablesCorrAllCond = cell2table(variablesCorr','VariableNames',{'All conditions'});
    tableZscoreCorrAllCond=[tableNameVariablesCorrAllCond tableVariablesCorrAllCond];
    writetable(tableZscoreCorrAllCond,[zScoreName{1},'_zScoreFeatures.xls'],'Sheet', 'zScoreCorrAllConditions','Range','B2');
    
    %% Colormap
    franceColormap = [linspace(0,1,100)', linspace(0, 1, 100)', linspace(1,1,100)'];
    franceColormap = [franceColormap; [linspace(1,1,100)', linspace(1, 0, 100)', linspace(1,0,100)']];
    %% Plot heatmap
    figure
    hmap_1 = heatmap( uniqueConditions, cellfun(@(x) strrep(x, '_', '-'), variables, 'UniformOutput', false), aggregatedMap');
    hmap_1.Colormap = franceColormap;
    axs_1 = struct(gca); 
    cbar_1 = axs_1.Colorbar;
    maxAxis = max(max(aggregatedMap(:)), abs(min(aggregatedMap(:))));
    caxis([-maxAxis, maxAxis]);
    ylabel(cbar_1, 'Z-Score')
    
    %% Calcualte corr matrix
    corrMatrix = corrcoef(normMappingValuesCorr);
    
    %% Plot corr matrix heatmap
    figure
    hmap_2 = heatmap(cellfun(@(x) strrep(x, '_', '-'), variablesCorr, 'UniformOutput', false), cellfun(@(x) strrep(x, '_', '-'), variablesCorr, 'UniformOutput', false), corrMatrix, 'Title', 'General Correlation Matrix');
    hmap_2.Colormap = franceColormap;
    axs_2 = struct(gca); 
    caxis([-1, 1]);
    cbar_2 = axs_2.Colorbar;
    ylabel(cbar_2, 'Pearson Coefficient')
    
    %% Correlation map of each condition
    for condition=1:length(uniqueConditions)
        figure
        hmap_aux = heatmap(cellfun(@(x) strrep(x, '_', '-'), variablesCorr, 'UniformOutput', false), cellfun(@(x) strrep(x, '_', '-'), variablesCorr, 'UniformOutput', false), conditionCorrMaps(:, :, condition));
        hmap_aux.Colormap = franceColormap;
        axs = struct(gca); 
        cbar = axs.Colorbar;
        caxis([-1, 1]);
        ylabel(cbar, 'Pearson Coefficient')
        title(strcat(uniqueConditions{condition}, ' correlation'));
    end
    
end