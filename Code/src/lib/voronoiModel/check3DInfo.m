function check3DInfo()

% path = '/media/pedro/6TB/jesus/NaturalVariation/voronoi_SELECTED/bySeeds/';
path = '/media/pedro/6TB/jesus/NaturalVariation/voronoi_SELECTED/bySeeds/1000/';

% matDir = dir(strcat(path, '*/*/*.mat'));
matDir = dir(strcat(path, '*/*.mat'));

surfaceRatioList = [8,2.45;16,2.08;20,1.91;30,1.52; 50,1.42;100,1.40; 500,1.15;1000,1.03];

numLayers = 2;

for dirIx = 1:numel(matDir)
    try
        name = matDir(dirIx).name;
        folder = matDir(dirIx).folder;

        nameClean = strsplit(name, '.mat');
        nameClean = nameClean{1};
        disp(strcat('working with ', nameClean))
        
        fullapicalxlsPath =  strcat(folder, '/', nameClean, '.xls');
        fullapicalmatPath = strcat(folder, '/', name);

        fullbasalxlsWritePath = strcat(folder, '/', nameClean, 'BASAL', '.xls');
        fullbasalmatWritePath = strcat(folder, '/', nameClean, 'BASAL', '.mat');

        full3DInfoPath = strcat(folder, '/', nameClean, '3D_info_filteredScutoids', '.xls');
            
        if exist(full3DInfoPath, 'file')==2 | exist(strrep(full3DInfoPath, 'BASAL', ''), 'file')==2
            disp(strcat('skipping ', nameClean))
            continue
        elseif exist(fullapicalxlsPath, 'file')==2 & exist(fullbasalxlsWritePath, 'file')==2
            
           tableLayerApical = readtable(fullapicalxlsPath);
           tableLayerBasal = readtable(fullbasalxlsWritePath);

           apicalNeighsArray = [];
           basalNeighsArray= [];
           apicoBasalTransitionsArray = [];
           scutoidArray = [];

           for cellIx=1:size(tableLayerApical,1)
%                 disp(cellIx)
                apicalNeighs = tableLayerApical(cellIx, contains(tableLayerApical.Properties.VariableNames, 'neighs_'));
                basalNeighs = tableLayerBasal(cellIx, contains(tableLayerBasal.Properties.VariableNames, 'neighs_'));
                
                apicalNeighs = table2array(apicalNeighs);
                basalNeighs = table2array(basalNeighs);
%                 apicalNeighs = tableLayerApical(cellIx, 6:end).Variables;
%                 basalNeighs = tableLayerBasal(cellIx, 7:end).Variables;

                apicalNeighs = apicalNeighs(~isnan(apicalNeighs));
                basalNeighs = basalNeighs(~isnan(basalNeighs));

                apicoBasalTransitions = length(horzcat(setdiff(basalNeighs,apicalNeighs), setdiff(apicalNeighs,basalNeighs)));
                scutoid = apicoBasalTransitions>0;

                apicalNeighsArray = [apicalNeighsArray; {apicalNeighs}];
                basalNeighsArray = [basalNeighsArray; {basalNeighs}];
                apicoBasalTransitionsArray = [apicoBasalTransitionsArray; apicoBasalTransitions];
                scutoidArray = [scutoidArray; scutoid];
           end
           
            %% filter scutoids
           scutoidPosition = find(scutoidArray>0);
           
            % 3D neighs (lateral neighs)
            current3DNeighsArray = [];
            apicoBasalTransitionsLabels = [];
            for rowIx = 1:size(tableLayerApical,1)
                
                currentApicalNeighs = table2array(tableLayerApical(rowIx, contains(tableLayerApical.Properties.VariableNames, 'neighs_')));
                currentBasalNeighs = table2array(tableLayerBasal(rowIx, contains(tableLayerBasal.Properties.VariableNames, 'neighs_')));
                currentApicalNeighs = currentApicalNeighs(~isnan(currentApicalNeighs));
                currentBasalNeighs = currentBasalNeighs(~isnan(currentBasalNeighs));
                
                current3DNeighs = [currentApicalNeighs, currentBasalNeighs];
                current3DNeighs = current3DNeighs(~isnan(current3DNeighs));
                current3DNeighs = unique(current3DNeighs);
                current3DNeighsArray = [current3DNeighsArray; {current3DNeighs'}];
                
                currentApicoBasalTransitionsLabels = setxor(currentApicalNeighs, currentBasalNeighs);
                apicoBasalTransitionsLabels = [apicoBasalTransitionsLabels, {currentApicoBasalTransitionsLabels}];

            end
            
           newScutoids_cells = zeros(size(scutoidArray));
           for scutoidIx = 1:numel(scutoidPosition)
                scutoidId = scutoidPosition(scutoidIx);
                currentScutoidApicalNeighs = apicalNeighsArray{scutoidId};
                currentScutoidBasalNeighs = basalNeighsArray{scutoidId};
                                
                intersections = arrayfun(@(x) intersect(current3DNeighsArray{x}, current3DNeighsArray{scutoidId}), apicoBasalTransitionsLabels{scutoidId}, 'UniformOutput', false);
                intersectionsLengths = cellfun(@(x) length(x), intersections)';

                crossedIntersections = cellfun(@(x) arrayfun(@(y) intersect(apicoBasalTransitionsLabels{y}, x), x, 'UniformOutput', false), intersections, 'UniformOutput', false);
                [crossedIntersectionsNonEmpty] = cellfun(@(x) sum(cell2mat(x)), crossedIntersections)';
                
                scutoidCondition = arrayfun(@(x, y) x>=1 && y>=2, crossedIntersectionsNonEmpty, intersectionsLengths);

                if sum(scutoidCondition)>=1
                    newScutoids_cells(scutoidId) = 1;
                end
                
           end
            
           %% replace fixed scutoids but saving the old data
           oldScutoidArray = scutoidArray;
           scutoidArray = newScutoids_cells;
           
           %% fix neighbours of scutoids that were removed
            wrongScutoids=arrayfun(@(x, y) setdiff(x,y), oldScutoidArray, scutoidArray, 'UniformOutput', false);

            for scuIx=1:length(wrongScutoids)
                if wrongScutoids{scuIx}==1
                   difference = setxor(apicalNeighsArray{scuIx},basalNeighsArray{scuIx});
                   if size(apicalNeighsArray{scuIx},2) < size(basalNeighsArray{scuIx},2)
                       
                       basalNeighsArray{scuIx}=apicalNeighsArray{scuIx};
                       
                       for cellIxDiff = 1:length(difference)
                           cellIdDiff =  difference(cellIxDiff);
                           oldValues = basalNeighsArray{cellIdDiff};
                           basalNeighsArray{cellIdDiff} = oldValues(oldValues~=scuIx);
                       end
%                      lateral3dInfo_total{scuIx}=apicalNeighsArray{scuIx};

                   elseif size(apicalNeighsArray{scuIx},2) > size(basalNeighsArray{scuIx},2)
                       apicalNeighsArray{scuIx}=basalNeighsArray{scuIx};
%                        lateral3dInfo_total{scuIx}=basalNeighsArray{scuIx};

                       for cellIxDiff = 1:length(difference)
                           cellIdDiff =  difference(cellIxDiff);
                           oldValues = apicalNeighsArray{cellIdDiff};
                           apicalNeighsArray{cellIdDiff} = oldValues(oldValues~=scuIx);
                       end
                       
                   else
                      for cellIxDiff = 1:length(difference)
                          cellIdDiff = difference(cellIxDiff);
                          oldValues = apicalNeighsArray{scuIx};
                          apicalNeighsArray{scuIx} = oldValues(oldValues~=cellIdDiff);
                          basalNeighsArray{scuIx} = oldValues(oldValues~=cellIdDiff);
                      end
                      
                      for cellIxDiff = 1:length(difference)
                           cellIdDiff =  difference(cellIxDiff);
                           oldValues = basalNeighsArray{cellIdDiff};
                           basalNeighsArray{cellIdDiff} = oldValues(oldValues~=scuIx);
                      end
                      
                      for cellIxDiff = 1:length(difference)
                           cellIdDiff =  difference(cellIxDiff);
                           oldValues = apicalNeighsArray{cellIdDiff};
                           apicalNeighsArray{cellIdDiff} = oldValues(oldValues~=scuIx);
                      end 
                      
                   end
                   
                end
            end           
           
            apicalNumNeighs = cellfun(@(x) size(x,2), apicalNeighsArray, 'UniformOutput', false);
            basalNumNeighs = cellfun(@(x) size(x,2), basalNeighsArray, 'UniformOutput', false);
            
            %% apicoBasalTransitions
            apicoBasalTransitionsArray = cellfun(@(x,y) length(setxor(x, y)), apicalNeighsArray, basalNeighsArray, 'UniformOutput', false);
            apicoBasalTransitionsArray = cell2mat(apicoBasalTransitionsArray);
           %%

           dataTable = table(tableLayerApical.id, tableLayerApical.cell_area, tableLayerBasal.cell_area, tableLayerApical.perim_area, tableLayerBasal.perim_area, tableLayerApical.total_ellipsoid_area, tableLayerBasal.total_ellipsoid_area, apicalNumNeighs, basalNumNeighs, apicoBasalTransitionsArray, scutoidArray, apicalNeighsArray, basalNeighsArray);
           dataTable.Properties.VariableNames = {'id', 'apicalCellArea', 'basalCellArea', 'apicalPerim', 'basalPerim', 'apicalTotalArea', 'basalTotalArea', 'apicalNumNeighs', 'basalNumNeighs', 'apicoBasalTransitions', 'scutoid', 'apicalNeighs', 'basalNeighs'};           

           writetable(dataTable, full3DInfoPath);
        else
           disp(strcat('smth wrong with_ ', nameClean))

        end
    catch
        continue
    end
           
end