function rewriteImgWithInfo()

    path1 = '/media/pedro/6TB/jesus/Belmonte/extImgs/';
    path1_info = '/media/pedro/6TB/jesus/Belmonte/rg_norm/';
    path2 = '/media/pedro/6TB/jesus/Belmonte/extImgsWithInfo/';
    
    imgs_dir = dir(strcat(path1, '*', '.tif'));
    
    for n_file = 1:length(imgs_dir)
        img = readStackTif(strcat(path1, imgs_dir(n_file).name));
        imgSize = size(img);
        
        cleanName = strsplit(imgs_dir(n_file).name, '_ext');
         
        cleanName = cleanName{1};
        
        img_info = imfinfo(strcat(path1_info, cleanName, '.tif'));
        
        xResolution = img_info(1).XResolution;        
        zDescription = img_info(1).ImageDescription;
        
        splitInfo = strsplit(zDescription, 'images=');
        firstInfo = splitInfo{1};
        sliceInfo = splitInfo{2};
        sliceInfo = strsplit(zDescription, 'unit=');
        finalInfo = sliceInfo{2};
        
        newzDescription = strcat(sprintf("\n"), "images=", num2str(imgSize(3)), sprintf("\n"), "slices=", num2str(imgSize(3)), sprintf("\n"), "unit=");        
        newzDescription = strcat(firstInfo, newzDescription, finalInfo);
        
        writeStackTifWithInfo(img, strcat(path2, imgs_dir(n_file).name), xResolution, newzDescription);
    end

end
