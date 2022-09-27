function [voronoiCyst] = enlargeLumenVolume(labelledImage)
    

    %Get binary version of labelled image 
    binaryLabelledImage = labelledImage>0;
    
    
    %fill hollow tissue
    fullCyst = imfill(binaryLabelledImage, 'holes');
    
    %find lumen
    lumen = labelledImage==0 & fullCyst;
    
    %Dilate 2 px
    se = strel('disk',2);
    dilatedLumen = imdilate(lumen, se);
    
    %Multiply dilated x lumen to keep eroded inner wall and discard the
    %outter one
    erodedInnerWall = fullCyst==1 & dilatedLumen==0;
%     erodedInnerWall = fullCyst-dilatedLumen;
    
    voronoiCyst = uint16(erodedInnerWall).*labelledImage;
    
end
