function writeStackTifWithInfo(img,fileName, xyPixel, newZDescription)

%write a Tiff file, appending each image as a new page
    for ii = 1 : size(img, 3)
        imwrite(uint8(img(:,:,ii)) ,fileName, "Resolution", [xyPixel xyPixel], "Description", newZDescription, 'WriteMode' , 'append') ;
    end

end