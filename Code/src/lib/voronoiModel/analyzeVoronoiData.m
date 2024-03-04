% analyzeVoronoiData()

path = '/media/pedro/6TB/jesus/NaturalVariation/voronoiModel_8/';

directory = dir(strcat(path, '*.xls'));

nonagonsArray = [];
octagonsArray = [];
heptagonsArray = [];
hexagonsArray = [];
pentagonsArray = [];
squareArray = [];
trianglesArray = [];
dotsArray = [];
seedsArray = [];
lloydItersArray = [];
runIdArray = [];
principalAxis1Array = [];

for ix = 1:numel(directory)
    
    fileName = directory(ix).name;
    dataTable = readtable(strcat(path, fileName));
    
    dots = strsplit(fileName, 'nDots_');
    dots = strsplit(dots{2}, '_');
    dots = str2num(dots{1});
    dotsArray = [dotsArray; dots];
    
    seeds = strsplit(fileName, 'nSeeds_');
    seeds = strsplit(seeds{2}, '_');
    seeds = str2num(seeds{1});
    seedsArray = [seedsArray; seeds];

    lloydIters = strsplit(fileName, 'lloydIters_');
    lloydIters = strsplit(lloydIters{2}, '_');
    lloydIters = str2num(lloydIters{1});
    lloydItersArray = [lloydItersArray; lloydIters];

    runId = strsplit(fileName, 'runId_');
    runId = strsplit(runId{2}, '_');
    runId = str2num(runId{1});
    runIdArray = [runIdArray; runId];
    
    principalAxis1 = strsplit(fileName, 'principalAxisLength_');
    principalAxis1 = strsplit(principalAxis1{2}, '_');
    principalAxis1 = str2num(principalAxis1{1});
    principalAxis1Array = [principalAxis1Array; principalAxis1];
    
    
    nonagonsPercentage = sum(dataTable.numNeighs==9)/seeds;
    octagonsPercentage = sum(dataTable.numNeighs==8)/seeds;
    heptagonsPercentage = sum(dataTable.numNeighs==7)/seeds;
    hexagonsPercentage = sum(dataTable.numNeighs==6)/seeds;
    pentagonsPercentage = sum(dataTable.numNeighs==5)/seeds;
    squaresPercentage = sum(dataTable.numNeighs==4)/seeds;
    trianglesPercentage = sum(dataTable.numNeighs==3)/seeds;

    nonagonsArray = [nonagonsArray; nonagonsPercentage];
    octagonsArray = [octagonsArray; octagonsPercentage];
    heptagonsArray = [heptagonsArray; heptagonsPercentage];
    hexagonsArray = [hexagonsArray; hexagonsPercentage];
    pentagonsArray = [pentagonsArray; pentagonsPercentage];
    squareArray = [squareArray; squaresPercentage];
    trianglesArray = [trianglesArray; trianglesPercentage];
end

summaryTable = table(principalAxis1Array, dotsArray, seedsArray, lloydItersArray, runIdArray, trianglesArray, squareArray, pentagonsArray, hexagonsArray, heptagonsArray, octagonsArray, nonagonsArray);
summaryTable.Properties.VariableNames = {'principalAxis1', 'dots', 'seeds', 'lloyd', 'runId', 'triangles', 'squares', 'pentagons', 'hexagons', 'heptagons', 'octagons', 'nonagons'};
writetable(summaryTable, strcat(path, 'summaryTable.xls'));
