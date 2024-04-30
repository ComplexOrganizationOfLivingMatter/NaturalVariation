function check3DInfo()

% path = '/media/pedro/6TB/jesus/NaturalVariation/voronoi_SELECTED/bySeeds/';
path = '/media/pedro/6TB/jesus/NaturalVariation/voronoi_SELECTED/bySeeds/30/';

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

        full3DInfoPath = strcat(folder, '/', nameClean, '3D_info', '.xls');
            
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

           dataTable = table(tableLayerApical.id, tableLayerApical.cell_area, tableLayerBasal.cell_area, tableLayerApical.perim_area, tableLayerBasal.perim_area, tableLayerApical.total_ellipsoid_area, tableLayerBasal.total_ellipsoid_area, tableLayerApical.numNeighs, tableLayerBasal.numNeighs, apicoBasalTransitionsArray, scutoidArray, apicalNeighsArray, basalNeighsArray);
           dataTable.Properties.VariableNames = {'id', 'apicalCellArea', 'basalCellArea', 'apicalPerim', 'basalPerim', 'apicalTotalArea', 'basalTotalArea', 'apicalNumNeighs', 'basalNumNeighs', 'apicoBasalTransitions', 'scutoid', 'apicalNeighs', 'basalNeighs'};           

           writetable(dataTable, full3DInfoPath);
        else
           disp(strcat('smth wrong with_ ', nameClean))

        end
    catch
        continue
    end
           
end