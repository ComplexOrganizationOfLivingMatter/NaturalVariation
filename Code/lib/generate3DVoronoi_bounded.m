function [labelledImageVoronoi] = generate3DVoronoi_bounded(seeds,validRegion)

    labelledImageVoronoi = zeros(size(validRegion));
      
    %Get bounded valid pixels
    ids = find(validRegion==1);
    [row, col, z] = ind2sub(size(validRegion),ids);
    
    labelPerId = zeros(size(ids));
    
    [rowNan,~]=find(isnan(seeds));
    seeds(unique(rowNan),:)=[];
   
    %From valid pixels get closest seed (add this value)
    tic
    display('generating 3D Voronoi')
    parfor nId = 1:length(ids)
        distCoord = pdist2([row(nId), col(nId), z(nId)],seeds);
        [~,idSeedMin]=min(distCoord);
        labelPerId(nId) = idSeedMin;
    end
    toc
    
    labelledImageVoronoi(ids)=labelPerId;
    
    


end

