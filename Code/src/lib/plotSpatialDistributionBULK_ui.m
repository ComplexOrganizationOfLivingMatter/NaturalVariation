function plotSpatialDistributionBULK_ui
    
    addpath(genpath('/home/pedro/Escritorio/jesus/processing3DSegmentation/'));
    addpath(genpath('/home/pedro/Escritorio/jesus/NaturalVariation/'));

    rgStackPath = uigetdir('./', 'Select rgStack (.tif) path');
    labelsPath = uigetdir('./', 'Select labels (.mat) path');
    savePath = uigetdir('./', 'Select save path');

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
