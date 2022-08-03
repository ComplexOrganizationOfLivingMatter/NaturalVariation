function correlateVariableWithScutoids_ui()

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % correlateVariableWithScutoids_ui
    % User interface for correlateViariableWithScutoids
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    %ui get path rgStack
    rgStackPath = uigetdir('F:\Carmen\DataSetMethod_4_7_10d', 'Select rgStack (.tif) path');
    rgStackPath = strcat(rgStackPath, '\');
    %ui get path labels
    labelsPath = uigetdir('F:\Carmen\DataSetMethod_4_7_10d', 'Select labels (.mat) path');
    labelsPath = strcat(labelsPath, '\');

    %ui get path to save
    savePath = uigetdir('F:\Carmen\DataSetMethod_4_7_10d', 'Select save path');
    savePath = strcat(savePath, '\');

    %% select variable to plot
    params = ["ID_Cell", "Volume", "EquivDiameter", "PrincipalAxisLength", "ConvexVolume", "Solidity", "SurfaceArea", "aspectRatio", "sphericity", "normalizedVolume", "irregularityShapeIndex", "apical_NumNeighs", "apical_Area", "basal_NumNeighs", "basal_Area", "cell_height", "lateral_NumNeighs", "lateral_Area", "average_cell_wall_Area", "std_cell_wall_Area", "scutoids", "apicoBasalTransitions", "surfaceRatio", "coefCluster", "betCentrality"];

    for idx = 1:length(params) 
       param = params{idx};
       struct.(param) = param;
    end

    % Let the user pick some of the fields:
    C = fieldnames(struct);
    size_wind = [1 50; 1 50; 1 50; 1 50]; % Windows size
    idx = listdlg('PromptString','Select variable to plot.',...
                  'SelectionMode','single',...
                  'ListString',C, 'ListSize',[550,250]);

    % Show the values of the fields that the user picked:
    variable = [];
    for k = 1:numel(idx)
        variable = [variable, {struct.(C{idx(k)})}];
    end
        
    
    statsQuest = questdlg('Norm by cyst?', ...
	'NORM BY CYST QUEST', ...
	'NO','YES', 'YES');
    
    %% Ask for saveName
    prompt = 'Enter a saveName: ';
    saveName = input(prompt, 's');
    
    %correlateVariableWithScutoids
    correlateVariableWithScutoidsBULK(rgStackPath, labelsPath, variable, savePath, saveName, statsQuest)
    
end
