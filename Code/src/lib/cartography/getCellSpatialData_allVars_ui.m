function getCellSpatialData_allVars_ui()

    addpath(genpath('D:\Github\NaturalVariation\'));

    %ui get path rgStack
    rgStackPath = uigetdir('F:\jesus', 'Select rgStack (.tif) path');
    rgStackPath = strcat(rgStackPath, '\');
    %ui get path labels
    labelsPath = uigetdir('F:\jesus', 'Select labels (.mat) path');
    labelsPath = strcat(labelsPath, '\');

    %ui get path to save
    savePath = uigetdir('F:\jesus', 'Select save path');
    savePath = strcat(savePath, '\');

    %% select variable to plot
    params = ["Volume", "PrincipalAxisLength", "Solidity", "SurfaceArea", "aspectRatio", "sphericity", "normalizedVolume", "irregularityShapeIndex", "apical_NumNeighs", "apical_Area", "basal_NumNeighs", "basal_Area", "cell_height", "lateral_NumNeighs", "lateral_Area", "apicalPerimeters", "basalPerimeters", "apicalNeighsOfNeighs", "basalNeighsOfNeighs", "lateralNeighsOfNeighs","average_cell_wall_Area", "std_cell_wall_Area", "scutoids", "apicoBasalTransitions", "surfaceRatio","totalApicalArea","totalBasalArea"];

    for idx = 1:length(params) 
       param = params{idx};
       struct.(param) = param;
    end
    
    
    % Let the user pick some of the fields:
    C = fieldnames(struct);
    size_wind = [1 50; 1 50; 1 50; 1 50]; % Windows size
    idx = listdlg('PromptString','Select variable to plot.',...
                  'SelectionMode','m',...
                  'ListString',C, 'ListSize',[550,250]);
  
    % Show the values of the fields that the user picked:
    variables = [];
    for k = 1:numel(idx)
        variables = [variables, {struct.(C{idx(k)})}];
    end
        
    %% Ask for saveName
    prompt = 'Enter a saveName: ';
    saveName = input(prompt, 's');
    
    %create table
    for variableIx=1:length(variables)
        variable = variables(variableIx);
        getCellSpatialDataBulk(rgStackPath, labelsPath, variable{1}, savePath, saveName)
    end
    
    %JOIN TABLES
    for variableIx=1:length(variables)
        if variableIx == 1
            variable = variables(variableIx);
            variable = variable{1};
            allVarsTable = readtable(strcat(savePath, saveName, '_', variable, '_spatialData.xls'));
        else
            variable = variables(variableIx);
            variable = variable{1};
            auxTable = readtable(strcat(savePath, saveName, '_', variable, '_spatialData.xls'));
            auxTable = auxTable(strcmp(auxTable.cystID, allVarsTable.cystID),  {char(variable), char(strcat(variable, '_norm')), char(strcat(variable, '_mean')), char(strcat(variable, '_mean_norm'))});
            allVarsTable(:, size(allVarsTable, 2)+1:size(allVarsTable, 2)+4) = auxTable;
            allVarsTable.Properties.VariableNames = [allVarsTable.Properties.VariableNames(1:size(allVarsTable,2)-4), auxTable.Properties.VariableNames];
        end

    fileName = strcat(savePath, saveName, '_allVars_spatialData.xls');
    writetable(allVarsTable,fileName);
    
    end
    
        
end
