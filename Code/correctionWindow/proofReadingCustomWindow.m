function [labelledImage,lumenImage,apicalLayer,basalLayer] = proofReadingCustomWindow(rawImg,labelledImage,lumenImage,apicalLayer,basalLayer,colours,notFoundCellsSurfaces,cellWithStrangeSurface,outputDir)

    outputDir='';
    resizeImg=1;
    tipValue=0;
    glandOrientation = 0;
    if isempty(colours)
        nLabels = max(labelledImage(:));
        randOrder = randperm(nLabels);
        colours=colorcube(nLabels);
        colours=colours(randOrder,:);
    end
    
    
    answer='Yes';
    while isequal(answer, 'Yes')
        %volumeViewer(vertcat(labelledImage>0, lumenImage))
        [h, labelledImage_Temp, lumenImage_Temp, colours_Temp] = window(rawImg, outputDir, labelledImage, lumenImage, resizeImg, tipValue, glandOrientation, colours, notFoundCellsSurfaces, cellWithStrangeSurface);

        savingResults = saveResults();

        if isequal(savingResults, 'Yes')
            %% Get info from window
            labelledImage = labelledImage_Temp;
            lumenImage = lumenImage_Temp;
            colours = colours_Temp;

            close all
            [apicalLayer,basalLayer,lateralLayer,lumenImage] = getApicalBasalLateralAndLumenFromPlantSeg(labelledImage,path2saveLayers);
           
            %% Save apical and basal 3d information
            save(outputDir, 'labelledImage', 'basalLayer', 'apicalLayer', 'lateralLayer', 'lumenImage', 'colours', '-v7.3')
               
            %setappdata(0,'labelledImage',labelledImage);
            %setappdata(0,'lumenImage',lumenImage);
        else
            [answer] = isEverythingCorrect();
        end
        %volumeViewer close

    end



end

