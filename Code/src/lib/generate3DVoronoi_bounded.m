function [labelledImageVoronoi] = generate3DVoronoi_bounded(seeds,validRegion)

    labelledImageVoronoi = zeros(size(validRegion));
    %Get bounded valid pixels
    ids = find(validRegion==1);
    [row, col, z] = ind2sub(size(validRegion),ids);
    labelPerId = zeros(size(ids));
    
    if iscell(seeds)
        totalLabels=num2cell([1:length(seeds)]');
        idsSeeds = cellfun(@(x,y) repmat(y,[size(x,1),1]), seeds, totalLabels,'UniformOutput',false);
        seeds = vertcat(seeds{:});
        seedsLabels = vertcat(idsSeeds{:});
    else
        seedsLabels=[1:length(seeds)]';
        
    end

    [rowNan,~]=find(isnan(seeds));
    seeds(unique(rowNan),:)=[];
    seedsLabels(unique(rowNan),:)=[];
    
    %From valid pixels get closest seed (add this value)
    %tic
    display('generating 3D Voronoi')
    parfor nId = 1:length(ids)
        distCoord = pdist2([col(nId),row(nId), z(nId)],seeds);
        [~,idSeedMin]=min(distCoord);
        labelPerId(nId) = seedsLabels(idSeedMin);
    end
    %toc
    
    labelledImageVoronoi(ids)=labelPerId;
    
%     volumeViewer(labelledImageVoronoi)


end

