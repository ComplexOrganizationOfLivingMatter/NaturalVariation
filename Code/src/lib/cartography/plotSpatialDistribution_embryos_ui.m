function plotSpatialDistribution_embryos_ui

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % plotSpatialDistribution_embryos_ui
    % 
    % Main code for plotting  spatial distribution (stamps)
    %
    % Fully automated just select:
    %
    % 1.- rgStack (.tif) path: raw confocal images
    % 2.- labels (.mat or .tif) path: labelled images
    % 3.- savePath: Path to save the results
    % 4.- variable to plot
    % 5.- file save name
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    addpath(genpath('D:\Jesus\tutorial\NaturalVariation-main\'));

%     labelsPath = uigetdir('D:\Jesus\tutorial', 'Select label images (.mat or .tif) path');
    labelsPath = '/media/pedro/6TB/jesus/NaturalVariation/LAURA/EMBRYOS/plot_stamps_embryo/Fixed_embryos_fail_/';
%     rgStackPath = uigetdir('D:\Jesus\tutorial', 'Select raw images (.tif) path');
    rgStackPath = '/media/pedro/6TB/jesus/NaturalVariation/LAURA/EMBRYOS/plot_stamps_embryo/rg_fail_/';
%     savePath = uigetdir('D:\Jesus\tutorial', 'Select save path');
    savePath = '/media/pedro/6TB/jesus/NaturalVariation/LAURA/EMBRYOS/plot_stamps_embryo/';
    %% select variable to plot
%     params = ["ID_Cell", "Volume", "EquivDiameter", "PrincipalAxisLength", "ConvexVolume", "Solidity", "SurfaceArea", "aspectRatio", "sphericity", "normalizedVolume", "irregularityShapeIndex", "apical_NumNeighs", "apical_Area", "basal_NumNeighs", "basal_Area", "cell_height", "lateral_NumNeighs", "lateral_Area", "average_cell_wall_Area", "std_cell_wall_Area", "scutoids", "apicoBasalTransitions", "surfaceRatio", "GRAY"];
% 
%     for idx = 1:length(params) 
%        param = params{idx};
%        struct.(param) = param;
%     end
% 
%     % Let the user pick some of the fields:
%     C = fieldnames(struct);
%     size_wind = [1 50; 1 50; 1 50; 1 50]; % Windows size
%     idx = listdlg('PromptString','Select variable to plot.',...
%                   'SelectionMode','single',...
%                   'ListString',C, 'ListSize',[550,250]);
% 
%     % Show the values of the fields that the user picked:
%     variable = [];
%     for k = 1:numel(idx)
%         variable = [variable, {struct.(C{idx(k)})}];
%     end
%     
    variable = ["basal_NumNeighs"];

    warning('THIS CODE IS OK JUST FOR BASAL NEIGHBOURS!!!');
    %% Ask for saveName
    prompt = 'Enter a saveName: ';
    saveName = input(prompt, 's');
    
    plotSpatialDistribution_embryos(rgStackPath, labelsPath, variable{1}, savePath, saveName)
end
