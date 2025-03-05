function rewriteImgWithInfo()

    % PATH 1 DONDE ESTÉN LAS IMAGENES FAKE SIN INFO
    path1 = 'D:\Laura\Models\Embryo_Model_tests\Embryo_model_16cells\test_D2_3_p_025\embryos_tif\';
    % PATH 2 DONDE SE VAN A GUARDAR CON INFO
    path2 = 'D:\Laura\Models\Embryo_Model_tests\Embryo_model_16cells\test_D2_3_p_025\embryos_with_info\';
    % IMG_INFO: ESE PATH ES UNA IMAGEN QUE TENGA INFO (DE MICROSCOPIO
    % NORMAL VAYA,PERO SIEMPRE LA MISMA)
    img_info = imfinfo('D:\Laura\Models\Embryo_Model_tests\Embryo_model_8cells\D2_3_p_05\011311_cdx2_Phalloidin_Series010_1.tif');
    % Y YA
    
    imgs_dir = dir(strcat(path1, '*', '.tif'));
    
    for n_file = 1:length(imgs_dir)
        img = readStackTif(strcat(path1, imgs_dir(n_file).name));
        imgSize = size(img);
        
        cleanName = strsplit(imgs_dir(n_file).name, '_ext');
         
        cleanName = cleanName{1};
        
%         img_info = imfinfo(strcat(path1_info, cleanName, '.tif'));
%         
        xResolution = img_info(1).XResolution;        
        zDescription = img_info(1).ImageDescription;
%         

        xResolution = 1;       

        splitInfo = strsplit(zDescription, 'images=');
        firstInfo = splitInfo{1};
        sliceInfo = splitInfo{2};
        sliceInfo = strsplit(zDescription, 'unit=');
        finalInfo = sliceInfo{2};
        
        finalInfo = strrep(finalInfo, 'spacing=2.01416207710464', 'spacing=1');
        finalInfo = strrep(finalInfo, 'min=40.0', 'min=0');
        finalInfo = strrep(finalInfo, 'max=1137.0', 'max=255');

        
        newzDescription = strcat(sprintf("\n"), "images=", num2str(imgSize(3)), sprintf("\n"), "slices=", num2str(imgSize(3)), sprintf("\n"), "unit=");        
        newzDescription = strcat(firstInfo, newzDescription, finalInfo);
        
        writeStackTifWithInfo(img, strcat(path2, imgs_dir(n_file).name), xResolution, newzDescription);
    end

end
