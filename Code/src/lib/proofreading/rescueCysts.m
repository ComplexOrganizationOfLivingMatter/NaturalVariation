function rescueCysts(path, tableName)
    path = '/media/pedro/6TB/jesus/NaturalVariation/crops/restore_cysts_20211015/05-Jul-2021/';
    tableName = 'voronoiCystWarnings_05-Jul-2021.xls';
    
    matFilesPath = strcat(path, 'validateCysts/');
    rgFilesPath = strcat(path, 'rg/');
    
    matFilesDirectory = dir(strcat(matFilesPath, '*.mat'));
    
    tableWarnings = readtable(strcat(path, tableName));

    for nfile = 1:length(matFilesDirectory)
        fileName = matFilesDirectory(nfile).name;
        load(strcat(matFilesPath, fileName));
        
        name = strsplit(fileName, '.mat');
        name = strcat(name{1}, '.tif');
        
        rgStackImg = readStackTif(strcat(rgFilesPath, name));
        
        se = strel('sphere',1);
        dilatedlabelledImage = imdilate(labelledImage, se);
        [apicalLayer,basalLayer,lateralLayer,lumenImage] = getApicalBasalLateralAndLumenFromPlantSeg(dilatedlabelledImage, '');
        binaryLabel = bwlabeln(dilatedlabelledImage);

        voronoiCyst = VoronoizateCells(binaryLabel, dilatedlabelledImage);

        labelledImage =  reduceLumenVolume(voronoiCyst);
%         labelledImage = voronoiCyst;
        
        filename = fullfile(strcat(path, 'newMatFiles/'), fileName);
        save(filename, 'rgStackImg', 'labelledImage');
%         save(strcat(path, 'newMatFiles/', fileName))
    end
        
end
