function prepareForShape2Img()

path = '/media/pedro/6TB/jesus/NaturalVariation/voronoi_SELECTED/bySeeds/';

dirPathFolders = dir(path);

table3Dinfo = table();

for folderIx = 3:numel(dirPathFolders)
    
    currentFolder = dirPathFolders(folderIx).name;
    
    disp(currentFolder);
    
    dirPathShape = dir(strcat(path, currentFolder, '/'));
    
    for subfolderIx = 3:numel(dirPathShape)
            
        currentFolderShape = dirPathShape(subfolderIx).name;

        
        dirPathMat = dir(strcat(path, currentFolder, '/', currentFolderShape, '/*.mat'));
        
        for matfileIx = 1:numel(dirPathMat)
            fileName_Voronoi = dirPathMat(matfileIx).name;
            
            %% APICAL
            
            load(strcat(path, currentFolder, '/', currentFolderShape, '/', fileName_Voronoi));
            
            [sortedDjj, SortedDjjIndices] = sort(Djj, 2);
            uniqueVe = unique(ve, 'rows');
            veInVertexBool = ismember(vertex', ve(1:3,:)', 'rows');
            neighsApical = SortedDjjIndices(veInVertexBool, 1:2);
            veInVertexApical = vertex(:, veInVertexBool');

            %% BASAL           
            fileNameBasal = strrep(fileName_Voronoi, '.mat', 'BASAL.mat');
            load(strcat(path, currentFolder, '/', currentFolderShape, '/', fileNameBasal));
            
            [sortedDjj, SortedDjjIndices] = sort(Djj, 2);
            uniqueVe = unique(ve, 'rows');
            veInVertexBool = ismember(vertex2', ve(1:3,:)', 'rows');
            neighsBasal = SortedDjjIndices(veInVertexBool, 1:2);

            veInVertexBasal = vertex2(:, veInVertexBool');

            %% all
            neighsTotal = [neighsApical; neighsBasal];
            veInVertexTotal = [veInVertexApical, veInVertexBasal];
            
            uniqueCells = unique(neighsTotal);
            
            cellIdArray = [];
            coordsArray = [];
            
            for cellIx = 1:numel(uniqueCells)

                cellId = uniqueCells(cellIx);
                rowsWhereCellAppears = any(neighsTotal == cellId, 2);
                edgeCoords = veInVertexTotal(:, rowsWhereCellAppears);

                cellIdArray = [cellIdArray, cellId];
                coordsArray = [coordsArray, {edgeCoords'}];
            end
                        
            save(strcat(path, currentFolder, '/', currentFolderShape, '/', strrep(fileName_Voronoi, '.mat', 'edgeCoords.mat')), 'cellIdArray', 'coordsArray','-v7.3')
            
        end
    end
end
