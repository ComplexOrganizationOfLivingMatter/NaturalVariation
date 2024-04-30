function meanNumNeighs = compareWithKnownvoronoi(pstarts, vertex, nSeeds)

% nvert = size(vertex,2);
% nstart = 1000;
% pstarts = floor(rand(nstart,1)*nvert)+1;

xyz = vertex(:, pstarts)';

DT = delaunayTriangulation(xyz(:, 1), xyz(:,2));
triOfInterest = DT.ConnectivityList;

verticesTRI = DT.circumcenter; 

%delete vertices out of the image region 2 avoid repeatition in
%border cells
indVertOut = verticesTRI(:,2)<=-100 | verticesTRI(:,2)>=100;
verticesTRI(indVertOut,:) = [];
triOfInterest(indVertOut,:) = [];   

vertIn = [verticesTRI(:,1) >= -100] & [verticesTRI(:,1) < 100];

noValidCells = unique(triOfInterest(~vertIn,:));

validCells = setxor([1:nSeeds],noValidCells);

neighs = calculateNeighboursDelaunay(triOfInterest);

numNeighs = cellfun(@length, neighs);

meanNumNeighs = mean(numNeighs(validCells));
