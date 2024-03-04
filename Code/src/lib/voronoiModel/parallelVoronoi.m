function parallelVoronoi()

savePath = '/media/pedro/6TB/jesus/NaturalVariation/voronoiModel_9/';
cells = [500, 750, 1000];
axis1 = [75, 100];
lloyd = 5;
runs = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
numLayer = 0;
cellHeight = 40;


[ca, cb, cc] = ndgrid(cells, axis1, runs);
combs = [ca(:), cb(:), cc(:)];

parfor index = 1:size(combs,1)
    currentData = combs(index, :);
    disp(strcat('working on: ', num2str(currentData)))
    currentSeeds = currentData(1);
    currentAxis = currentData(2);
    runId = currentData(3);
    try
        voronoiModel(currentAxis, 100, 100, 750, currentSeeds, lloyd, false, savePath, runId, numLayer, cellHeight)
    catch
        disp(strcat('error with ', num2str(currentData)));
        disp('retrying ...')
        try
            voronoiModel(currentAxis, 100, 100, 750, currentSeeds, lloyd, false, savePath, runId, numLayer, cellHeight)
            disp('retry successfull')
        catch
                    disp(strcat('error with ', num2str(currentData)));
        end
    end
    disp(strcat(num2str(currentData), ' DONE'))

end
