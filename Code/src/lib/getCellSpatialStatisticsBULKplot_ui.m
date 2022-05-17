function getCellSpatialStatisticsBULKplot_ui()
    %ui get path rgStack
    rgStackPath = uigetdir('/media/pedro/6TB/jesus/NaturalVariation/plotVariableDistributions/', 'Select rgStack (.tif) path');
    rgStackPath = strcat(rgStackPath, '/');
    %ui get path labels
    labelsPath = uigetdir('/media/pedro/6TB/jesus/NaturalVariation/plotVariableDistributions/', 'Select labels (.mat) path');
    labelsPath = strcat(labelsPath, '/');

    %ui get path to save
    savePath = uigetdir('/media/pedro/6TB/jesus/NaturalVariation/plotVariableDistributions/', 'Select save path');
    savePath = strcat(savePath, '/');

    variable = 'cell_height';
    
    %% Ask for saveName
    prompt = 'Enter a saveName: ';
    saveName = input(prompt, 's');
    
    %create table
    getCellSpatialStatisticsBULK(rgStackPath, labelsPath, variable, strcat(savePath, '_', saveName, '_', 'variable.xls'))
    
    %launch plotviolin
    
end