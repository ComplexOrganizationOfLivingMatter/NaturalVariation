function [surfaceArea, perim] = calculateArea(vertex, faces, Q, cellId)

    %https://es.mathworks.com/matlabcentral/answers/184234-how-do-i-determine-the-surface-area-of-a-2-d-surface-in-a-3-d-space
    
    
    if isempty(cellId)
        tri = faces';
    else
        %% check faces in cellId
        dotsInCell = find(Q==cellId);

        tri = faces(:, all(ismember(faces, dotsInCell)))';
        
    end
    
    xcoord = vertex(1, :)';
    ycoord = vertex(2, :)';
    zcoord = vertex(3, :)';
    
    tri3D = triangulation(tri,[xcoord,ycoord,zcoord]);
    
    boundary = tri3D.freeBoundary;
    
    calculatePerimFun = @(dotIx) pdist2(vertex(:, boundary(dotIx,1))', vertex(:, boundary(dotIx,2))');
    perim = arrayfun(calculatePerimFun, 1:size(boundary, 1), 'UniformOutput', true);
    perim = sum(perim);
    
    tri = tri3D.ConnectivityList;
    
    P = [xcoord,ycoord,zcoord];

    v1 = P(tri(:,2), :) - P(tri(:,1), :);
    v2 = P(tri(:,3), :) - P(tri(:,2), :);
    


    cp = 0.5*cross(v1,v2);

    surfaceArea = sum(sqrt(dot(cp, cp, 2)));