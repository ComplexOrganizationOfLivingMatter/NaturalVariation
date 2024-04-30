function findOptimalNeighboursThresholdGivenMAT()

path = '/media/pedro/6TB/jesus/NaturalVariation/voronoiModel_19_findOptimalNeighboursThreshold/';

matDir = dir(strcat(path, '*.mat'));

for dirIx = 1:numel(matDir)
    name = matDir(dirIx).name;
    load(strcat(path, name))
    
    %%neighbours 1
    
    %% Neighs and area
    [sortedDjj, SortedDjjIndices] = sort(Djj, 2);
    uniqueVe = unique(ve, 'rows');
    veInVertexBool = ismember(vertex', ve(1:3,:)', 'rows');
    neighs = SortedDjjIndices(veInVertexBool, 1:2);

    neighsmat = neighs;

    meanNeighsArray = [];
    
    for neighboursThreshold = [0,1,2,3,4,5,6]
        numNeighs = [];
        neighsArray = [];
        labels  = unique(pstarts, 'stable');

        for cellIx = 1:length(labels)
            cellId = cellIx;
            possibleNeighs = unique([(unique(neighsmat(neighsmat(:, 1)==cellId, 2))); unique(neighsmat(neighsmat(:, 2)==cellId, 1))]);
            counts1 = histc(neighsmat(neighsmat(:, 1)==cellId, 2), possibleNeighs);
            counts2 = histc(neighsmat(neighsmat(:, 2)==cellId, 1), possibleNeighs);
            countsTotal = counts1+counts2;
            thresholdedNeighbours = countsTotal>=neighboursThreshold;
            currentNeighs = possibleNeighs(thresholdedNeighbours);
            numNeighs = [numNeighs; length(currentNeighs)];
            neighsArray = [neighsArray, {currentNeighs}];
            
        end
        %% remove borders
        nonValidCells = unique(SortedDjjIndices(nonValidDots,1));
        validRows = true(1, max(size(pstarts)));
        validRows(nonValidCells) = false;
        meanNeighsArray = [meanNeighsArray; mean(numNeighs(validRows'))];
    end
    
    %%voronoi
    %% COMPARE W/ PLANE VORONOI DELAUNUAY
    meanNumNeighsDelaunuay = compareWithKnownVoronoi(pstarts, vertex, nSeeds);
    
    % Read the Excel file
    comparisonData = readtable('/media/pedro/6TB/jesus/NaturalVariation/voronoiModel_19_findOptimalNeighboursThreshold/findOptimalNeighboursThreshold.xls');

    % Find the next empty row
    next_empty_row = size(comparisonData,1)+1;

    % If the file is empty, start from the first row
    if isempty(next_empty_row)
        next_empty_row = 1;
    end
    
    error = abs(meanNeighsArray-meanNumNeighsDelaunuay);
    optimalThresholdIx = find(error==min(error),1);
    
    comparisonData(next_empty_row, 1) = {min(error)};
    comparisonData(next_empty_row, 2) = {nSeeds};
    comparisonData(next_empty_row, 3) = {dirIx};
    comparisonData(next_empty_row, 4) = {meanNeighsArray(optimalThresholdIx)};
    comparisonData(next_empty_row, 5) = {meanNumNeighsDelaunuay};
    comparisonData(next_empty_row, 6) = {optimalThresholdIx-1};

    % Write back to the Excel file
    writetable(comparisonData, '/media/pedro/6TB/jesus/NaturalVariation/voronoiModel_19_findOptimalNeighboursThreshold/findOptimalNeighboursThreshold.xls');
    
    clearvars -except matDir path dirIx
    %%neighs 1
    
    %%neighs 2
    
    %%compare
    
    %%xls
    
    
    
end