function [meanFeatures,stdFeatures, tissue3dFeatures, lumen3dFeatures,hollowTissue3dFeatures] = convertPixelsToMicrons(meanFeatures,stdFeatures, tissue3dFeatures, lumen3dFeatures,hollowTissue3dFeatures,pixelScale)
    %UNTITLED Summary of this function goes here
    %   Detailed explanation goes here
    volumeSubstring={'Volume','volume'};
    areaSubstring={'Area', 'area'};
    lengthSubstring={'length','Length'};
    heightSubstring={'height','Height'};
    perimeterSubstring={'perimeter','Perimeter'};


    %% VolumeFeatures
    CellsFeaturesVolumeIndexs = contains(meanFeatures.Properties.VariableNames,volumeSubstring);
    TissueFeaturesVolumeIndexs = contains(tissue3dFeatures.Properties.VariableNames,"Volume");

    meanFeatures(:,CellsFeaturesVolumeIndexs) = splitvars(table(table2array(meanFeatures(:,CellsFeaturesVolumeIndexs)) * pixelScale^3),1);
    stdFeatures(:,CellsFeaturesVolumeIndexs) = splitvars(table(table2array(stdFeatures(:,CellsFeaturesVolumeIndexs)) * pixelScale^3),1);
    tissue3dFeatures(:,TissueFeaturesVolumeIndexs) = splitvars(table(table2array(tissue3dFeatures(:,TissueFeaturesVolumeIndexs)) * pixelScale^3),1);
    lumen3dFeatures(:,TissueFeaturesVolumeIndexs) = splitvars(table(table2array(lumen3dFeatures(:,TissueFeaturesVolumeIndexs)) * pixelScale^3),1);
    hollowTissue3dFeatures(:,TissueFeaturesVolumeIndexs) = splitvars(table(table2array(hollowTissue3dFeatures(:,TissueFeaturesVolumeIndexs)) * pixelScale^3),1);

    %% Area Features
    CellsFeaturesAreaIndexs = contains(meanFeatures.Properties.VariableNames,areaSubstring);
    TissueFeaturesAreaIndexs = contains(tissue3dFeatures.Properties.VariableNames,areaSubstring);

    meanFeatures(:,CellsFeaturesAreaIndexs) = splitvars(table(table2array(meanFeatures(:,CellsFeaturesAreaIndexs)) * pixelScale^2),1);
    stdFeatures(:,CellsFeaturesAreaIndexs) = splitvars(table(table2array(stdFeatures(:,CellsFeaturesAreaIndexs)) * pixelScale^2),1);
    tissue3dFeatures(:,TissueFeaturesAreaIndexs) = splitvars(table(table2array(tissue3dFeatures(:,TissueFeaturesAreaIndexs)) * pixelScale^2),1);
    lumen3dFeatures(:,TissueFeaturesAreaIndexs) = splitvars(table(table2array(lumen3dFeatures(:,TissueFeaturesAreaIndexs)) * pixelScale^2),1);
    hollowTissue3dFeatures(:,TissueFeaturesAreaIndexs) = splitvars(table(table2array(hollowTissue3dFeatures(:,TissueFeaturesAreaIndexs)) * pixelScale^2),1);

    %% Length Features
    CellsFeaturesLengthIndexs = contains(meanFeatures.Properties.VariableNames,lengthSubstring);
    CellsFeaturesHeightIndexs = contains(meanFeatures.Properties.VariableNames,heightSubstring);
    TissueFeaturesLengthIndexs = contains(tissue3dFeatures.Properties.VariableNames,lengthSubstring);

    meanFeatures(:,CellsFeaturesLengthIndexs) = table(table2array(meanFeatures(:,CellsFeaturesLengthIndexs)) * pixelScale);
    stdFeatures(:,CellsFeaturesLengthIndexs) = table(table2array(stdFeatures(:,CellsFeaturesLengthIndexs)) * pixelScale);

    if sum(CellsFeaturesHeightIndexs)~=0
        meanFeatures(:,CellsFeaturesHeightIndexs) = table(table2array(meanFeatures(:,CellsFeaturesHeightIndexs)) * pixelScale);
        stdFeatures(:,CellsFeaturesHeightIndexs) = table(table2array(stdFeatures(:,CellsFeaturesHeightIndexs)) * pixelScale);
    end

    tissue3dFeatures(:,TissueFeaturesLengthIndexs) = table(table2array(tissue3dFeatures(:,TissueFeaturesLengthIndexs)) * pixelScale);
    lumen3dFeatures(:,TissueFeaturesLengthIndexs) = table(table2array(lumen3dFeatures(:,TissueFeaturesLengthIndexs)) * pixelScale);
    hollowTissue3dFeatures(:,TissueFeaturesLengthIndexs) = table(table2array(hollowTissue3dFeatures(:,TissueFeaturesLengthIndexs)) * pixelScale);
    
    %% Perimeter Features
    CellsFeaturesPerimeterIndexs = contains(meanFeatures.Properties.VariableNames,perimeterSubstring);

    meanFeatures(:,CellsFeaturesPerimeterIndexs) = splitvars(table(table2array(meanFeatures(:,CellsFeaturesPerimeterIndexs)) * pixelScale));
    stdFeatures(:,CellsFeaturesPerimeterIndexs) = splitvars(table(table2array(stdFeatures(:,CellsFeaturesPerimeterIndexs)) * pixelScale));



end

