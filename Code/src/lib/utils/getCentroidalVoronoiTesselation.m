function currentVoronoiCyst = getCentroidalVoronoiTesselation(principalAxis1, principalAxis2, principalAxis3, cellHeight, nCells, radiusThreshold, minimumSeparation, iters, savePath, saveName)

voronoiCyst = getSynthethicCyst(principalAxis1, principalAxis2, principalAxis3, cellHeight, nCells, radiusThreshold, minimumSeparation);

disp(strcat('Number of Cells: ', num2str(nCells)));
disp(strcat('principalAxis: ', num2str(principalAxis1), ' ', num2str(principalAxis2), ' ', num2str(principalAxis3)));
disp(strcat('cellHeight: ', num2str(cellHeight)));
disp(strcat('radiusThreshold: ', num2str(radiusThreshold)));
disp(strcat('minimumSeparation: ', num2str(minimumSeparation)));
disp(strcat('totalIter: ', num2str(iters)));

currentVoronoiCyst = voronoiCyst;
for currentIter=1:iters
    disp(strcat('Iteration #', num2str(currentIter)));
    centroids = regionprops3(currentVoronoiCyst, 'Centroid');
    centroidSeeds = zeros(size(currentVoronoiCyst));
    uniqueLabels = unique(currentVoronoiCyst);
    
    % check that everything is ok
    if length(uniqueLabels)~=length(unique(voronoiCyst))
       warning('smth wrong with seeds');
    end
    
    % assign labels/centroids
    for seedIx=1:length(uniqueLabels)-1
        centroidSeeds(round(centroids.Centroid(seedIx, 2)), round(centroids.Centroid(seedIx, 1)), round(centroids.Centroid(seedIx, 3))) = seedIx;
    end
    
    se = strel('sphere',5);
    currentVoronoiCyst = imdilate(centroidSeeds,se);
    currentVoronoiCyst = VoronoizateCells(voronoiCyst>0, currentVoronoiCyst);
    
    writeStackTif(double(currentVoronoiCyst./255), strcat(savePath, saveName, '_', num2str(currentIter), '.tif'));
    
end