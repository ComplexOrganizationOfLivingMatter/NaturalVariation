function [apicalPerimeters, basalPerimeters, apicalNeighsOfNeighs, basalNeighsOfNeighs, lateralNeighsOfNeighs] = calculatePerimeters(validCells, apicalLayer, apical3dInfo, basalLayer, basal3dInfo, lateralLayer, lateral3dInfo_total)

    binaryLateralLayer = lateralLayer>0;
    se = strel('sphere', 1);
    binaryLateralLayer = imdilate(binaryLateralLayer, se);

    apicalPerimeters = [];
    apicalNeighsOfNeighs = [];
    allCells = unique(validCells);
    for cellIx = 1:length(allCells)  % 2 to avoid 0 (background)
        cellId = allCells(cellIx);
        perimLayer = (apicalLayer==cellId).*binaryLateralLayer;
        perimeter = sum(perimLayer(:));
        apicalPerimeters = [apicalPerimeters; perimeter];
        neighs = apical3dInfo{cellId};
        numNeighsList = [];
        for neighIx = 1:length(neighs)
            neighId = neighs(neighIx);
            numNeighs = apical3dInfo{neighId};
            numNeighsList = [numNeighsList, length(numNeighs)];
        end
        apicalNeighsOfNeighs = [apicalNeighsOfNeighs; mean(numNeighsList)];
    end
    
    basalPerimeters = [];
    basalNeighsOfNeighs = [];
    allCells = unique(validCells);
    for cellIx = 1:length(allCells)  % 2 to avoid 0 (background)
        cellId = allCells(cellIx);
        perimLayer = (basalLayer==cellId).*binaryLateralLayer;
        perimeter = sum(perimLayer(:));
        basalPerimeters = [basalPerimeters; perimeter];
        neighs = basal3dInfo{cellId};
        numNeighsList = [];
        for neighIx = 1:length(neighs)
            neighId = neighs(neighIx);
            numNeighs = basal3dInfo{neighId};
            numNeighsList = [numNeighsList, length(numNeighs)];
        end
        basalNeighsOfNeighs = [basalNeighsOfNeighs; mean(numNeighsList)];
    end
    
    lateralNeighsOfNeighs = [];
    allCells = unique(validCells);
    for cellIx = 1:length(allCells)  % 2 to avoid 0 (background)
        cellId = allCells(cellIx);
        neighs = lateral3dInfo_total{cellId};
        numNeighsList = [];
        for neighIx = 1:length(neighs)
            neighId = neighs(neighIx);
            numNeighs = lateral3dInfo_total{neighId};
            numNeighsList = [numNeighsList, length(numNeighs)];
        end
        lateralNeighsOfNeighs = [lateralNeighsOfNeighs; mean(numNeighsList)];
    end
end