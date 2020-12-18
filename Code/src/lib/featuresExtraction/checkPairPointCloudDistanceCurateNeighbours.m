function neighCuration = checkPairPointCloudDistanceCurateNeighbours(imgLayer3D,neighs, performPerimOfCells)

    neighCuration = neighs;
    setPtClouds = cell(1,length(neighs));
    for nCells = 1 : length(neighs)
        if exist('performPerimOfCells', 'var')
            [allX1,allY1,allZ1] = ind2sub(size(imgLayer3D),find(bwperim(imgLayer3D==nCells)));
        else
            [allX1,allY1,allZ1] = ind2sub(size(imgLayer3D),find(imgLayer3D==nCells));
        end
        setPtClouds{nCells} = pointCloud([allX1,allY1,allZ1]);
    end
    
    for nCells = 1 : length(neighs)
        ptCloud1 = setPtClouds{nCells};
        
        neighCells = neighs{nCells};
        neighCellsRefact = neighs{nCells};
        
        for nNeigh = 1:length(neighCells)
            ptCloud2 = setPtClouds{neighCells(nNeigh)};
            minDist = inf;
            for i = 1 : ptCloud1.Count
                point = ptCloud1.Location(i,:);
                [~,dist] = findNearestNeighbors(ptCloud2,point,1);
                if dist < minDist 
                    minDist = dist;
                end
                
                if minDist <= 3
                    break
                end
            end
            
            if minDist > 3
               neighCellsRefact(neighCellsRefact == neighCells(nNeigh)) = [];
            end
            
        end
        
        neighCuration{nCells} = neighCellsRefact;
        
    end


end

