function getCellSpatialData_allVars_multilayer_ui()

    addpath(genpath('D:\Github\NaturalVariation\'));

    %ui get path rgStack
    rgStackPath = uigetdir('F:\jesus', 'Select rgStack (.tif) path');
    rgStackPath = strcat(rgStackPath, '\');
%     rgStackPath = '/home/pedro/Escritorio/testEMB/testOrgP_ErrorAllvars/rgStack/';
    %ui get path labels
    labelsPath = uigetdir('F:\jesus', 'Select labels (.mat) path');
    labelsPath = strcat(labelsPath, '\');
%     labelsPath = '/home/pedro/Escritorio/testEMB/testOrgP_ErrorAllvars/fixed/';

    %ui get path to save
    savePath = uigetdir('F:\jesus', 'Select save path');
    savePath = strcat(savePath, '\');
%     savePath = '/home/pedro/Escritorio/testEMB/testOrgP_ErrorAllvars/';

    %% select variable to plot
    params = ["total3DNeighbours","Volume", "PrincipalAxisLength", "Solidity", "SurfaceArea", "aspectRatio", "sphericity", "normalizedVolume", "irregularityShapeIndex", "basal_NumNeighs", "basal_Area", "basalPerimeter", "basalNeighsOfNeighs", "totalBasalArea"];

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
        
    variables = variables;

    %% Ask for saveName
    prompt = 'Enter a saveName: ';
    saveName = input(prompt, 's');
    saveName= 'test';
    
    %create table
    for variableIx=1:length(variables)
        variable = variables(variableIx);
        disp(variable)
        getCellSpatialDataBulk_multilayer(rgStackPath, labelsPath, variable{1}, savePath, saveName);
    end
    
    %JOIN TABLES
    for varibaleIx=1:length(variables)
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
