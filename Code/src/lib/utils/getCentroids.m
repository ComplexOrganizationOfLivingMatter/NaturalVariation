function [centroidsRaw,newCentroids]=getCentroids(labelledImage,apicalLayer,basalLayer)

    centroidsRaw = table2array(regionprops3(labelledImage,'Centroid'));
    centroidsRaw = round(centroidsRaw);
    %3. Get closest basal and apical coordinates from centroids (new
    %centroids)
    newCentroids = cell(size(centroidsRaw,1),1);
%     auxImage = apicalLayer>0;
    for nCell = 1:size(centroidsRaw,1)
        coordCell = centroidsRaw(nCell,:);
        if all(~isempty(coordCell) & ~isnan(coordCell))
           indApi = find(apicalLayer==nCell);
           [yApi,xApi,zApi]=ind2sub(size(apicalLayer),indApi);
           indBas = find(basalLayer==nCell);
           [yBas,xBas,zBas]=ind2sub(size(basalLayer),indBas);
       
           meanApiCoord = mean([xApi,yApi,zApi]);
           meanBasCoord = mean([xBas,yBas,zBas]);
           [~,idClosestApi]=min(pdist2(meanApiCoord,[xApi,yApi,zApi]));
           apiSeed = [xApi(idClosestApi),yApi(idClosestApi),zApi(idClosestApi)];
           
           [~,idClosestBas]=min(pdist2(meanBasCoord,[xBas,yBas,zBas]));
           basSeed = [xBas(idClosestBas),yBas(idClosestBas),zBas(idClosestBas)];
           
           [xApiCen,yApiCen,zApiCen] = Drawline3D(apiSeed(1),apiSeed(2),apiSeed(3),coordCell(1),coordCell(2),coordCell(3));
           [xCenBas,yCenBas,zCenBas] = Drawline3D(coordCell(1),coordCell(2),coordCell(3),basSeed(1),basSeed(2),basSeed(3));
           lineSeed = unique([[xApiCen;xCenBas],[yApiCen;yCenBas],[zApiCen;zCenBas]],'rows');
           newCentroids{nCell,:} = lineSeed;
%            auxImage = (apicalLayer==nCell)+(basalLayer==nCell);
%            ids = sub2ind(size(auxImage),lineSeed(:,2),lineSeed(:,1),lineSeed(:,3));
%            auxImage(ids)=1;
        end

    end
%     volumeViewer(auxImage)

end
