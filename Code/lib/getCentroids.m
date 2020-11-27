function [centroidsRaw,newCentroids]=getCentroids(labelledImage,apicalLayer,basalLayer)

    centroidsRaw = table2array(regionprops3(labelledImage,'Centroid'));

    %3. Get closest basal and apical coordinates from centroids (new
    %centroids)
    newCentroids = zeros(size(centroidsRaw));
    for nCell = 1:size(centroidsRaw,1)
        coordCell = centroidsRaw(nCell,:);
        if ~isempty(coordCell)
           indApi = find(apicalLayer==nCell);
           [xApi,yApi,zApi]=ind2sub(size(apicalLayer),indApi);
           distancesApi = pdist2(coordCell,[xApi,yApi,zApi]);
           [~,idMinApi]=min(distancesApi);
           coordMinApi = [xApi(idMinApi),yApi(idMinApi),zApi(idMinApi)];

           indBas = find(basalLayer==nCell);
           [xBas,yBas,zBas]=ind2sub(size(basalLayer),indBas);
           distancesBas = pdist2(coordCell,[xBas,yBas,zBas]);
           [~,idMinBas]=min(distancesBas);
           coordMinBas = [xBas(idMinBas),yBas(idMinBas),zBas(idMinBas)];
           newCentroids(nCell,:) = round(mean([coordMinApi;coordMinBas]));

%            auxImage = (apicalLayer==nCell)+(basalLayer==nCell);
%            auxImage(newCentroids(nCell,2),newCentroids(nCell,1),newCentroids(nCell,3))=1;
%            volumeViewer(auxImage)
        end

    end
    
    centroidsRaw = round(centroidsRaw);

    
end