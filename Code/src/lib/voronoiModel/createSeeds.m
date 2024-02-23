function pstarts = createSeeds(nSeeds, vertex, minimumSeparation)

    %% distribute seeds respecting distances (euclidean) VERSION 2
    pstarts = [];
    seeds = [];
    randomSort = randperm(size(vertex, 2), size(vertex, 2));
    for i = 1:size(vertex,2)
        randomDotIx = randomSort(i);
        if randomDotIx == 0
            randomDotIx = randomDotIx+1;
        end
        randomDot = [vertex(1, randomDotIx), vertex(2, randomDotIx), vertex(3, randomDotIx)];
        
        if isempty(seeds)
            seeds = [seeds;randomDot];
            pstarts = [pstarts, randomDotIx];
        end
        
        if min(pdist2(randomDot,seeds)) <= minimumSeparation
            continue
        else
            seeds = [seeds;randomDot];
            pstarts = [pstarts, randomDotIx];
        end
        
        if size(seeds,1)==nSeeds
            break
        end
    end
    
    if size(seeds,1)<nSeeds
        msg = 'Error occurred with seed localization.';
        error(msg)
    end
        
    %% calculate areas to distribute seeds more equally VERSION 1
%     maxZ = max(Z(:));
%     minZ = min(Z(:));
%     
%     nRegions = 20;
%     nSlices = 100;
%     zAxis = linspace(minZ, maxZ, nSlices);
%     
%     totalArea = calculateArea(vertex, faces, [], []);
%     pstarts = [];
%     
%     for regionIx = 1:nRegions
%        zAxisEdgeUp = zAxis(floor((nSlices*regionIx)/(nRegions)));
%        if regionIx == 1
%            zAxisEdgeDown = zAxis(1);
%        else
%            zAxisEdgeDown = zAxis(floor((nSlices*(regionIx-1))/(nRegions)));
%        end
%        vertexRegionId = find((vertex(3, :) < zAxisEdgeUp) & (vertex(3, :) >= zAxisEdgeDown));
%        
%        facesRegionId = find(all(ismember(faces(:, :), vertexRegionId)));
%        vertexRegion = vertex(:, vertexRegionId);
%        facesRegion = faces(:, facesRegionId);
%        validVertexRegion = unique(facesRegion);
%        regionArea = calculateArea(vertex, facesRegion, [], []);
%        regionAreaPercentage = regionArea/totalArea;
%        regionSeeds = floor(nSeeds*regionAreaPercentage);
%        pstarts = [pstarts, vertexRegionId(randperm(size(vertexRegionId,2), regionSeeds))];
%        if regionIx == nRegions
%           leftOverSeedsNum = nSeeds-size(pstarts,2);
%           notSelectedDots = setdiff(1:size(vertex,2), pstarts);
%           leftOverSeeds = randsample(notSelectedDots, leftOverSeedsNum);
%           pstarts = [pstarts, leftOverSeeds];
%        end
%     end
% 
%     nvert = size(vertex,2);
%     options.start_points = pstarts;

    %% params for voronoi such as random seed positioning VERSION 0

%     nvert = size(vertex,2);
%     nstart = nSeeds;
%     pstarts = floor(randperm(nstart,1)*nvert)+1;
%     pstarts = randperm(nvert,nstart);
%     options.start_points = pstarts;