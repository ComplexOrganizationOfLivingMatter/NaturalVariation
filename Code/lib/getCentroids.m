function [centroidsRaw,newCentroids]=getCentroids(labelledImage,apicalLayer,basalLayer)

    centroidsRaw = table2array(regionprops3(labelledImage,'Centroid'));

    %3. Get closest basal and apical coordinates from centroids (new
    %centroids)
    newCentroids = zeros(size(centroidsRaw));
    for nCell = 1:size(centroidsRaw,1)
        coordCell = centroidsRaw(nCell,:);
        if ~isempty(coordCell)
           indApi = find(apicalLayer==nCell);
           [yApi,xApi,zApi]=ind2sub(size(apicalLayer),indApi);
           indBas = find(basalLayer==nCell);
           [yBas,xBas,zBas]=ind2sub(size(basalLayer),indBas);
       
           meanApiCoord = mean([xApi,yApi,zApi]);
           meanBasCoord = mean([xBas,yBas,zBas]);
           newCentroids(nCell,:) = round(mean([meanApiCoord;meanBasCoord]));
%            auxImage = (apicalLayer==nCell)+(basalLayer==nCell);
%            auxImage(newCentroids(nCell,2),newCentroids(nCell,1),newCentroids(nCell,3))=1;
%            volumeViewer(auxImage)
        end

    end
    
    centroidsRaw = round(centroidsRaw);

    
end