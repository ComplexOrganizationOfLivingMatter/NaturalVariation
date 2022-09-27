function plotSpatialDistributionBULK_ui
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % plotSpatialDistributionBULK_ui
    % 
    % Main code for plotting "stamps" of all variables
    %
    % Fully automated, inputs:
    %
    % 1.- rgStackPath: raw confocal images
    % 2.- labelsPath: labelled (.mat or .tif) files
    % 3.- savePath: Path to save results
    % 4.- saveName: Desired name of output files
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    
    addpath(genpath('D:\Github\NaturalVariation\'));
    addpath(genpath('D:\Github\Processing3DSegmentation\'));

    rgStackPath = uigetdir('F:\Carmen\', 'Select rgStack (.tif) path');
    labelsPath = uigetdir('F:\Carmen\', 'Select labels (.mat or .tif) path');
    savePath = uigetdir('F:\Carmen\', 'Select save path');

    %% select variable to plot
    variables = ["Volume", "EquivDiameter", "ConvexVolume", "Solidity", "SurfaceArea", "aspectRatio", "sphericity", "normalizedVolume", "irregularityShapeIndex", "apical_NumNeighs", "apical_Area", "basal_NumNeighs", "basal_Area", "cell_height", "lateral_NumNeighs", "lateral_Area", "average_cell_wall_Area", "std_cell_wall_Area", "scutoids", "apicoBasalTransitions"];
%     variables = ["cell_height", "lateral_NumNeighs", "lateral_Area", "average_cell_wall_Area", "std_cell_wall_Area", "scutoids", "apicoBasalTransitions"];

    %% Ask for saveName
    prompt = 'Enter a saveName: ';
    saveName = input(prompt, 's');
    
    for variableIx = 1:length(variables)
        plotSpatialDistribution(rgStackPath, labelsPath, variables(variableIx), savePath, saveName)
    end
end
