function plotSpatialDistribution_ui

    statQuest = questdlg('just statistics?', ...
	'just spatial statistics table', ...
	'NO','YES', 'YES');
    
    addpath(genpath('/home/pedro/Escritorio/jesus/processing3DSegmentation/'));
    addpath(genpath('/home/pedro/Escritorio/jesus/NaturalVariation/'));

    rgStackPath = uigetdir('/media/pedro/6TB/jesus/NaturalVariation/plotVariableDistributions', 'Select rgStack (.tif) path');
    labelsPath = uigetdir('/media/pedro/6TB/jesus/NaturalVariation/plotVariableDistributions', 'Select labels (.mat) path');
    savePath = uigetdir('/media/pedro/6TB/jesus/NaturalVariation/plotVariableDistributions', 'Select save path');

    %% select variable to plot
    params = ["ID_Cell", "Volume", "EquivDiameter", "PrincipalAxisLength", "ConvexVolume", "Solidity", "SurfaceArea", "aspectRatio", "sphericity", "normalizedVolume", "irregularityShapeIndex", "apical_NumNeighs", "apical_Area", "basal_NumNeighs", "basal_Area", "cell_height", "lateral_NumNeighs", "lateral_Area", "average_cell_wall_Area", "std_cell_wall_Area", "scutoids", "apicoBasalTransitions", "surfaceRatio"];

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
    
    %% Ask for saveName
    prompt = 'Enter a saveName: ';
    saveName = input(prompt, 's');
    
    plotSpatialDistribution(rgStackPath, labelsPath, variable{1}, savePath, saveName, statQuest)
end