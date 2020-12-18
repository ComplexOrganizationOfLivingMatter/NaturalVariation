function writeStackTif(img,fileName)

%write a Tiff file, appending each image as a new page
    for ii = 1 : size(img, 3)
        imwrite(img(:,:,ii) ,fileName, 'WriteMode' , 'append') ;
    end

end