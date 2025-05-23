path = "/home/pedro/Escritorio/testCYST/";
tableName = 'smallVoronoi_stackedTables_3dInfoTable_filteredScutoids_20241219.xls';
savePath = "/home/pedro/Escritorio/testCYST/";
resultTableName = 'pentagonConnection_voronoi.xls';

%%
fullPath = strcat(path, tableName);
fullSavePath = strcat(savePath, resultTableName);

%%

table3dInfo_allTissues = readtable(fullPath);

uniqueTissues = unique(table3dInfo_allTissues.fileName);

% Initialize cell arrays to hold summary info
CystID_col = {};
totalPentagons_col = [];
numGroups_col = [];
groups_col = {};
totalCells = {};

for tissueIx = 1:length(uniqueTissues)
    fileName = uniqueTissues{tissueIx};
    table3dInfo = table3dInfo_allTissues(strcmp(table3dInfo_allTissues.fileName, fileName), :);
    
    % Extract numeric cell IDs from the first column
    numericCellIDs = [1:length(table3dInfo.id)];

    cellIDs = table3dInfo.id;
    colNames = table3dInfo.Properties.VariableNames;
    isBasalNeighsCol = contains(colNames, 'basalNeighs');
    basalNeighsCols = table3dInfo(:, isBasalNeighsCol);
    basalMatrix = table2array(basalNeighsCols);
    basal3dInfo = arrayfun(@(i) basalMatrix(i, ~isnan(basalMatrix(i, :))), ...
                       (1:size(basalMatrix, 1))', ...
                       'UniformOutput', false);
    table3dInfo.basal3dInfo = basal3dInfo;

    % Convert the basal3dInfo strings to numeric arrays of neighbors
    neighbors = cell(size(cellIDs));
    for i = 1:length(numericCellIDs)
        neighbors{i} = table3dInfo.basal3dInfo{i};
    end

    % Identify pentagon cells
    numNeighbors = cellfun(@numel, neighbors);
    pentagonIndices = find(numNeighbors == 5);
    pentagonIDs = numericCellIDs(pentagonIndices);
    totalPentagons = numel(pentagonIDs);

    % Initialize group information
    groupMembers = {};
    numGroups = 0;

    if totalPentagons > 0
        numPentagons = length(pentagonIDs);
        adjMatrix = zeros(numPentagons);

        % Create map from ID to index
        idToIdx = containers.Map(pentagonIDs, 1:numPentagons);

        % Fill adjacency matrix
        for i = 1:numPentagons
            realIdx = pentagonIndices(i);
            currentID = pentagonIDs(i);
            currentNeighbors = neighbors{realIdx};
            [isPent, loc] = ismember(currentNeighbors, pentagonIDs);
            pentNeighbors = currentNeighbors(isPent);
            if ~isempty(pentNeighbors)
                neighborIndices = arrayfun(@(x) idToIdx(x), pentNeighbors);
                adjMatrix(i, neighborIndices) = 1;
            end
        end

        % Make the graph and find connected components
        adjMatrix = max(adjMatrix, adjMatrix');
        G = graph(adjMatrix);
        [bins, ~] = conncomp(G);

        % Group pentagons by connected component
        uniqueBins = unique(bins);
        numGroups = length(uniqueBins);
        groupMembers = cell(numGroups, 1);

        for i = 1:numGroups
            groupMask = (bins == uniqueBins(i));
            groupMembers{i} = sort(pentagonIDs(groupMask));
        end
    end

    % Format the groups string
    groupStr = '';
    for i = 1:numGroups
        memberList = sprintf('%d,', groupMembers{i});
        memberList = ['[', memberList(1:end-1), ']']; % remove trailing comma
        groupStr = [groupStr, memberList]; %#ok<AGROW>
    end

    % Append to summary arrays
    CystID_col{end+1,1} = fileName;
    totalCells{end+1,1} = table3dInfo.nSeeds(1);
    totalPentagons_col(end+1,1) = totalPentagons;
    numGroups_col(end+1,1) = numGroups;
    groups_col{end+1,1} = groupStr;
end

% Create final summary table
summaryTable = table(CystID_col, totalCells, totalPentagons_col, numGroups_col, groups_col, ...
    'VariableNames', {'CystID', 'totalCells', 'totalPentagons', 'numGroups', 'groups'});

writetable(summaryTable, fullSavePath);
