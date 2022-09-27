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
    params = ["Volume", "EquivDiameter", "PrincipalAxisLength", "ConvexVolume", "Solidity", "SurfaceArea", "aspectRatio", "sphericity", "normalizedVolume", "irregularityShapeIndex", "apical_NumNeighs", "apical_Area", "basal_NumNeighs", "basal_Area", "cell_height", "lateral_NumNeighs", "lateral_Area", "average_cell_wall_Area", "std_cell_wall_Area", "scutoids", "apicoBasalTransitions", "surfaceRatio", "coefCluster", "betCentrality"];

        
    %% Ask for saveName
    prompt = 'Enter a saveName: ';
    saveName = input(prompt, 's');
    
    %create table
    for variableIx=1:length(params)
        variable = params(variableIx);
        getCellSpatialDataBulk(rgStackPath, labelsPath, variable, savePath, saveName)
    end
        
end