function parallelVoronoi()

savePath = '/media/pedro/6TB/jesus/NaturalVariation/voronoiModel/';
cells = [10, 50, 200, 500, 1000];
axis1 = [75, 50];
lloyd = 10;
runs = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];

[ca, cb, cc] = ndgrid(cells, axis1, runs);
combs = [ca(:), cb(:), cc(:)];

parfor index = 1:size(combs,1)
    currentData = combs(index, :);
    disp(strcat('working on: ', num2str(currentData)))
    currentSeeds = currentData(1);
    currentAxis = currentData(2);
    runId = currentData(3);
    try
        voronoiModel(currentAxis, 100, 100, 500, currentSeeds, lloyd, false, savePath, runId)
    catch
        disp(strcat('error with ', num2str(currentData)));
        disp('retrying ...')
        try
            voronoiModel(currentAxis, 100, 100, 1000, currentSeeds, lloyd, false, savePath, runId)
            disp('retry successfull')
        catch
                    disp(strcat('error with ', num2str(currentData)));
        end
    end
    disp(strcat(num2str(currentData), ' DONE'))

end