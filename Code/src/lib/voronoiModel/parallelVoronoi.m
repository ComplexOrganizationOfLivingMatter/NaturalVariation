function parallelVoronoi()

savePath = '/media/pedro/6TB/jesus/NaturalVariation/voronoiModel/';
cells = [8, 16, 20, 30];
axis1 = [75, 100];
lloyd = 5;
runs = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20];
numLayer = 2;
surfaceRatio = [8,2.45;16,2.08;20,1.91;30,1.52; 50,1.42;100,1.40; 500,1.15;1000,1.03];


[ca, cb, cc] = ndgrid(cells, axis1, runs);
combs = [ca(:), cb(:), cc(:)];

parfor index = 1:size(combs,1)
    currentData = combs(index, :);
    disp(strcat('working on: ', num2str(currentData)))
    currentSeeds = currentData(1);
    currentAxis = currentData(2);
    runId = currentData(3);
    currentSurfaceRatio = surfaceRatio(find(surfaceRatio(:,1)==currentSeeds), 2);
    
    try
        voronoiModel(currentAxis, 100, 100, 750, currentSeeds, lloyd, false, savePath, runId, numLayer, currentSurfaceRatio)
        disp(strcat(num2str(currentData), ' DONE'))
    catch
        disp(strcat('error with ', num2str(currentData)));
        disp('retrying ...')
        try
            voronoiModel(currentAxis, 100, 100, 750, currentSeeds, lloyd, false, savePath, runId, numLayer, currentSurfaceRatio)
            disp('retry successfull')
            disp(strcat(num2str(currentData), ' DONE'))

        catch
            disp(strcat(num2str(currentData), ' ERROR!!!!!!!!!'))
        end
    end
end