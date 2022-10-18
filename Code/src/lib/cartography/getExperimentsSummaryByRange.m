function getExperimentsSummaryByRange(tablePath, tableName, lowerRangeZ, higherRangeZ, lowerRangeVar, higherRangeVar)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     getExperimentsSummaryByRange(...)       %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Using getCellSpatialData tables, counts the
% number of cells inside a user-determined
% range by experiment.
%
% input_1: tablePath
% input_2: tableName
% input_3: lowerRangeZ
% input_4: higherRangeZ
% input_5: lowerRangeVar
% input_6: higherRangeVar

% example
% lowerRangeZ = 0;
% higherRangeZ = 0.15;
% lowerRangeVar = 0;
% higherRangeVar = 0.5;
% 
% pathToTable = '/media/pedro/6TB/jesus/methodology_naturalVariation/statisticsTest/7d_CellHeight_06_10_cell_height_spatialData.xls';

%% Read table
pathToTable = strcat(tablePath, tableName);

CellSpatialDataTable = readtable(pathToTable);

%% Clean experiment names for future convenience (replace '_' by '.')

CellSpatialDataTable.cystID = cellfun(@(cystID) strrep(cystID, '_', '.'), CellSpatialDataTable.cystID, 'UniformOutput', false);

%% Negative Curvature as shape

% find negative curvature cysts

negativeCurvatureCysts = ~cellfun(@isempty, CellSpatialDataTable.cystCurvature);

% replace cyst shape by 'curvNeg' in curvNeg Cysts

CellSpatialDataTable(negativeCurvatureCysts, 'cystShape') = {'curvNeg'};

%% Experiment IDs

dotPosition = cellfun(@(cystID) find(cystID == '.', 2, 'last'), CellSpatialDataTable.cystID, 'UniformOutput', false);

CellSpatialDataTable.experimentIDs = cellfun(@(cystID, dotPos) cystID(1:dotPos(1)-1),CellSpatialDataTable.cystID, dotPosition, 'UniformOutput', false);

%% Separate different cyst shapes

oblateCysts = cellfun(@(cystShape) strcmp(cystShape, 'oblate'), CellSpatialDataTable.cystShape);
prolateCysts = cellfun(@(cystShape) strcmp(cystShape, 'prolate'), CellSpatialDataTable.cystShape);
curvNegCysts = cellfun(@(cystShape) strcmp(cystShape, 'curvNeg'), CellSpatialDataTable.cystShape);
ellipsoidCysts = cellfun(@(cystShape) strcmp(cystShape, 'ellipsoid'), CellSpatialDataTable.cystShape);

oblateCystsTable = CellSpatialDataTable(oblateCysts, :);
prolateCystsTable = CellSpatialDataTable(prolateCysts, :);
curvNegCystsTable = CellSpatialDataTable(curvNegCysts, :);
ellipsoidCystsTable = CellSpatialDataTable(ellipsoidCysts, :);

%% Filter by range

% oblate

oblateZRange = [oblateCystsTable.normZPos>=lowerRangeZ].*[oblateCystsTable.normZPos<=higherRangeZ];
oblateVarRange = [oblateCystsTable.normVariableData>=lowerRangeVar].*[oblateCystsTable.normVariableData<=higherRangeVar];
oblateRange = logical(oblateVarRange.*oblateZRange);

oblateCystsFiltered = oblateCystsTable(oblateRange, :);

% prolate
prolateZRange = [prolateCystsTable.normZPos>=lowerRangeZ].*[prolateCystsTable.normZPos<=higherRangeZ];
prolateVarRange = [prolateCystsTable.normVariableData>=lowerRangeVar].*[prolateCystsTable.normVariableData<=higherRangeVar];
prolateRange = logical(prolateVarRange.*prolateZRange);

prolateCystsFiltered = prolateCystsTable(prolateRange, :);

% curvNeg
curvNegZRange = [curvNegCystsTable.normZPos>=lowerRangeZ].*[curvNegCystsTable.normZPos<=higherRangeZ];
curvNegVarRange = [curvNegCystsTable.normVariableData>=lowerRangeVar].*[curvNegCystsTable.normVariableData<=higherRangeVar];
curvNegRange = logical(curvNegVarRange.*curvNegZRange);

curvNegCystsFiltered = curvNegCystsTable(curvNegRange, :);

% ellipsoid

ellipsoidZRange = [ellipsoidCystsTable.normZPos>=lowerRangeZ].*[ellipsoidCystsTable.normZPos<=higherRangeZ];
ellipsoidVarRange = [ellipsoidCystsTable.normVariableData>=lowerRangeVar].*[ellipsoidCystsTable.normVariableData<=higherRangeVar];
ellipsoidRange = logical(ellipsoidVarRange.*ellipsoidZRange);

ellipsoidCystsFiltered = ellipsoidCystsTable(ellipsoidRange, :);

%% Separate by experiment

uniqueExperiments = unique(CellSpatialDataTable.experimentIDs);

experimentSummaryTable = table();

for experimentIDx = 1:length(uniqueExperiments)
    
    experimentID = uniqueExperiments(experimentIDx);
    experimentID = experimentID{1};

    oblateCystFileteredCount = sum(cellfun(@(experimentIDs) strcmp(experimentIDs, experimentID), oblateCystsFiltered.experimentIDs));
    prolateCystFileteredCount = sum(cellfun(@(experimentIDs) strcmp(experimentIDs, experimentID), prolateCystsFiltered.experimentIDs));
    curvNegCystFileteredCount = sum(cellfun(@(experimentIDs) strcmp(experimentIDs, experimentID), curvNegCystsFiltered.experimentIDs));
    ellipsoidCystFileteredCount = sum(cellfun(@(experimentIDs) strcmp(experimentIDs, experimentID), ellipsoidCystsFiltered.experimentIDs));

    oblateCystCount = sum(cellfun(@(experimentIDs) strcmp(experimentIDs, experimentID), oblateCystsTable.experimentIDs));
    prolateCystCount = sum(cellfun(@(experimentIDs) strcmp(experimentIDs, experimentID), prolateCystsTable.experimentIDs));
    curvNegCystCount = sum(cellfun(@(experimentIDs) strcmp(experimentIDs, experimentID), curvNegCystsTable.experimentIDs));
    ellipsoidCystCount = sum(cellfun(@(experimentIDs) strcmp(experimentIDs, experimentID), ellipsoidCystsTable.experimentIDs));


    if experimentIDx == 1
        experimentSummaryTable = table({experimentID}, oblateCystCount, oblateCystFileteredCount, prolateCystCount, prolateCystFileteredCount, curvNegCystCount, curvNegCystFileteredCount, ellipsoidCystCount, ellipsoidCystFileteredCount);
    else
        experimentSummaryTable = [experimentSummaryTable; table({experimentID}, oblateCystCount, oblateCystFileteredCount, prolateCystCount, prolateCystFileteredCount, curvNegCystCount, curvNegCystFileteredCount, ellipsoidCystCount, ellipsoidCystFileteredCount)];
        
    end

end

%% add table names
experimentSummaryTable.Properties.VariableNames = [{'experimentID'}, {'oblateCystCount'}, {'oblateCystFilteredCount'}, {'prolateCystCount'}, {'prolateCystFilteredCount'}, {'curvNegCystCount'}, {'curvNegCystFilteredCount'}, {'ellipsoidCystCount'}, {'ellipsoidCystFilteredCount'}]

%% New xls to write // write
dotInfo = find(tableName == '.', 1, 'last');
saveName = tableName(1:dotInfo-1);
saveName = strcat(saveName, '_experimentSummary_', date, '.xls');

disp(strcat('Saving as: ', saveName));

savePath = strcat(tablePath, saveName);

writetable(experimentSummaryTable, savePath)

disp(strcat('Succesfully saved at: ', tablePath))