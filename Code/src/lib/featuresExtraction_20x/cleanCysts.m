% Voronoi .mat files path
matFiles = '/home/pedro/Escritorio/jesus/featuresExtraction_20x_images/matFiles/';
matFilesFolders = dir(matFiles);
for folderIx = 3:length(matFilesFolders)
    folder = matFilesFolders(folderIx).name;
    folderDir = strcat(matFiles, folder, '/');
    folderDirFiles = dir(folderDir);
    
    for fileIx = 3:length(folderDirFiles)
        name = folderDirFiles(fileIx).name;
        name = strrep(name, '.mat', '');
        if ismember(name, cleanCystsSelection.d1A14_1tif)
            disp('member')
            fullDir = strcat(folderDir, name, '.mat');
            fullNewDir = strcat('/home/pedro/Escritorio/jesus/featuresExtraction_20x_images/cleanMatFiles/', folder, '/');
            movefile(fullDir,fullNewDir)
        end
    end
    

end
