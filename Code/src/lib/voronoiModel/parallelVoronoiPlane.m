function parallelVoronoiPlane()

savePath = '/media/pedro/6TB/jesus/NaturalVariation/voronoiModel_16_plane/';
cells = [500, 1000];
% axis1 = [75, 100];
lloyd = 10;
runs = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
numLayer = 0;
surfaceRatio = [8,2.45;16,2.08;20,1.91;30,1.52; 50,1.42;100,1.40; 500,1.15;1000,1.03];
nDots = [1000];

[ca, cb,  cc] = ndgrid(cells, runs, nDots);
combs = [ca(:), cb(:), cc(:)];

for index = 1:size(combs,1)
    currentData = combs(index, :);
    disp(strcat('working on: ', num2str(currentData)))
    currentSeeds = currentData(1);
    runId = currentData(2);
    currentNDots = currentData(3);
    currentSurfaceRatio = surfaceRatio(find(surfaceRatio(:,1)==currentSeeds), 2);
    
    try
        voronoiModelPlane(100, currentNDots, currentSeeds, lloyd, false, savePath, runId, numLayer, currentSurfaceRatio)
    catch
        disp(strcat('error with ', num2str(currentData)));
        disp('retrying ...')
        try
            voronoiModelPlane(100, currentNDots, currentSeeds, lloyd, false, savePath, runId, numLayer, currentSurfaceRatio)
            disp('retry successfull')
        catch
                    disp(strcat('error with ', num2str(currentData)));
        end
    end
    disp(strcat(num2str(currentData), ' DONE'))

end
