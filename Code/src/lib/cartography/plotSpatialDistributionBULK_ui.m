function plotSpatialDistributionBULK_ui
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % plotSpatialDistribution_ui
    % Plotting "estampitas" of all variables - user interface

    addpath(genpath('D:\Github\NaturalVariation\'));
    addpath(genpath('D:\Github\Processing3DSegmentation\'));

    rgStackPath = uigetdir('F:\Carmen\plotViolinScartter\4d\', 'Select rgStack (.tif) path');
    labelsPath = uigetdir('F:\Carmen\plotViolinScartter\4d\', 'Select labels (.mat) path');
    savePath = uigetdir('F:\Carmen\plotViolinScartter\4d\', 'Select save path');

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
