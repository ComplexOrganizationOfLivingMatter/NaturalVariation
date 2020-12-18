function [apicalLayer,basalLayer,lumenImage] = getApicalBasalAndLumenFromCyst(labelledImage)
    basalLayer = zeros(size(labelledImage));
    apicalLayer = zeros(size(labelledImage));

    apicoBasalLayer = bwlabeln(bwperim(labelledImage>0));
    basalLayer(apicoBasalLayer==1) = labelledImage(apicoBasalLayer==1);
    apicalLayer(apicoBasalLayer==2) = labelledImage(apicoBasalLayer==2);
    lumenImage = bwlabeln(labelledImage==0)==2;
end