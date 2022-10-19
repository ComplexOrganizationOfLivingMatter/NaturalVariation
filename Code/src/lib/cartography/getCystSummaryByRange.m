function getCystSummaryByRange(tablePath, tableName, lowerRangeZ, higherRangeZ, lowerRangeVar, higherRangeVar)

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
opts = detectImportOptions(pathToTable);
opts = setvartype(opts, 'cystCurvature', 'string');  %or 'char' if you prefer
CellSpatialDataTable = readtable(pathToTable, opts);

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
sphereCysts = cellfun(@(cystShape) strcmp(cystShape, 'sphere'), CellSpatialDataTable.cystShape);

oblateCystsTable = CellSpatialDataTable(oblateCysts, :);
prolateCystsTable = CellSpatialDataTable(prolateCysts, :);
curvNegCystsTable = CellSpatialDataTable(curvNegCysts, :);
ellipsoidCystsTable = CellSpatialDataTable(ellipsoidCysts, :);
sphereCystsTable = CellSpatialDataTable(sphereCysts, :);

%% Filter by range

% oblate

oblateZRange = [oblateCystsTable.normZPos>=lowerRangeZ].*[oblateCystsTable.normZPos<higherRangeZ];
oblateVarRange = [oblateCystsTable.normVariableData>=lowerRangeVar].*[oblateCystsTable.normVariableData<higherRangeVar];
oblateRange = logical(oblateVarRange.*oblateZRange);

oblateCystsFiltered = oblateCystsTable(oblateRange, :);

% prolate
prolateZRange = [prolateCystsTable.normZPos>=lowerRangeZ].*[prolateCystsTable.normZPos<higherRangeZ];
prolateVarRange = [prolateCystsTable.normVariableData>=lowerRangeVar].*[prolateCystsTable.normVariableData<higherRangeVar];
prolateRange = logical(prolateVarRange.*prolateZRange);

prolateCystsFiltered = prolateCystsTable(prolateRange, :);

% curvNeg
curvNegZRange = [curvNegCystsTable.normZPos>=lowerRangeZ].*[curvNegCystsTable.normZPos<higherRangeZ];
curvNegVarRange = [curvNegCystsTable.normVariableData>=lowerRangeVar].*[curvNegCystsTable.normVariableData<higherRangeVar];
curvNegRange = logical(curvNegVarRange.*curvNegZRange);

curvNegCystsFiltered = curvNegCystsTable(curvNegRange, :);

% ellipsoid

ellipsoidZRange = [ellipsoidCystsTable.normZPos>=lowerRangeZ].*[ellipsoidCystsTable.normZPos<higherRangeZ];
ellipsoidVarRange = [ellipsoidCystsTable.normVariableData>=lowerRangeVar].*[ellipsoidCystsTable.normVariableData<higherRangeVar];
ellipsoidRange = logical(ellipsoidVarRange.*ellipsoidZRange);

ellipsoidCystsFiltered = ellipsoidCystsTable(ellipsoidRange, :);

% sphere

sphereZRange = [sphereCystsTable.normZPos>=lowerRangeZ].*[sphereCystsTable.normZPos<higherRangeZ];
sphereVarRange = [sphereCystsTable.normVariableData>=lowerRangeVar].*[sphereCystsTable.normVariableData<higherRangeVar];
sphereRange = logical(sphereVarRange.*sphereZRange);

sphereCystsFiltered = ellipsoidCystsTable(sphereRange, :);

%% Separate by experiment

uniqueCysts = unique(CellSpatialDataTable.cystID);

cystSummaryTable = table();

for cystIDx = 1:length(uniqueCysts)
    
    cystID = uniqueCysts(cystIDx);
    cystID = cystID{1};

    oblateCystFileteredCount = sum(cellfun(@(cystID_) strcmp(cystID_, cystID), oblateCystsFiltered.cystID));
    prolateCystFileteredCount = sum(cellfun(@(cystID_) strcmp(cystID_, cystID), prolateCystsFiltered.cystID));
    curvNegCystFileteredCount = sum(cellfun(@(cystID_) strcmp(cystID_, cystID), curvNegCystsFiltered.cystID));
    ellipsoidCystFileteredCount = sum(cellfun(@(cystID_) strcmp(cystID_, cystID), ellipsoidCystsFiltered.cystID));
    sphereCystFileteredCount = sum(cellfun(@(cystID_) strcmp(cystID_, cystID), sphereCystsFiltered.cystID));

    oblateCystCount = sum(cellfun(@(cystID_) strcmp(cystID_, cystID), oblateCystsTable.cystID));
    prolateCystCount = sum(cellfun(@(cystID_) strcmp(cystID_, cystID), prolateCystsTable.cystID));
    curvNegCystCount = sum(cellfun(@(cystID_) strcmp(cystID_, cystID), curvNegCystsTable.cystID));
    ellipsoidCystCount = sum(cellfun(@(cystID_) strcmp(cystID_, cystID), ellipsoidCystsTable.cystID));
    sphereCystCount = sum(cellfun(@(cystID_) strcmp(cystID_, cystID), sphereCystsTable.cystID));

    oblatePercentage = oblateCystFileteredCount/oblateCystCount*100;
    prolatePercentage = prolateCystFileteredCount/prolateCystCount*100;
    curvNegPercentage = curvNegCystFileteredCount/curvNegCystCount*100;
    ellipsoidPercentage = ellipsoidCystFileteredCount/ellipsoidCystCount*100;
    spherePercentage = sphereCystFileteredCount/sphereCystCount*100;



    if cystIDx == 1
        cystSummaryTable = table({cystID}, oblateCystCount, oblateCystFileteredCount, oblatePercentage, prolateCystCount, prolateCystFileteredCount, prolatePercentage, curvNegCystCount, curvNegCystFileteredCount, curvNegPercentage, ellipsoidCystCount, ellipsoidCystFileteredCount, ellipsoidPercentage, sphereCystCount, sphereCystFileteredCount, spherePercentage);
    else
        cystSummaryTable = [cystSummaryTable; table({cystID}, oblateCystCount, oblateCystFileteredCount, oblatePercentage, prolateCystCount, prolateCystFileteredCount, prolatePercentage, curvNegCystCount, curvNegCystFileteredCount, curvNegPercentage, ellipsoidCystCount, ellipsoidCystFileteredCount, ellipsoidPercentage, sphereCystCount, sphereCystFileteredCount, spherePercentage)];
        
    end

end

%% add table names
cystSummaryTable.Properties.VariableNames = [{'cystID'}, {'oblateCystCount'}, {'oblateCystFilteredCount'}, {'oblatePercentage'}, {'prolateCystCount'}, {'prolateCystFilteredCount'}, {'prolatePercentage'}, {'curvNegCystCount'}, {'curvNegCystFilteredCount'}, {'curvNegPercentage'}, {'ellipsoidCystCount'}, {'ellipsoidCystFilteredCount'}, {'ellipsoidPercentage'},{'sphereCystCount'}, {'sphereCystFilteredCount'}, {'spherePercentage'}]

%% New xls to write // write
dotInfo = find(tableName == '.', 1, 'last');
saveName = tableName(1:dotInfo-1);
saveName = strcat(saveName, '_cystSummary_', date, '.xls');

disp(strcat('Saving as: ', saveName));

savePath = strcat(tablePath, saveName);

writetable(cystSummaryTable, savePath)

disp(strcat('Succesfully saved at: ', tablePath))