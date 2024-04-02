function givenXLScopyMAT(path2find, path2save)

path2find = '/media/pedro/6TB/jesus/NaturalVariation/';
path2save = '/media/pedro/6TB/jesus/NaturalVariation/voronoi_SELECTED/bySeeds/20/sphere/';

dir2findxls = dir(strcat(path2save, '/*.xls'));

dir2find = dir(strcat(path2find,'voro*/', '*.mat'));


for i = 1:length(dir2findxls)
    % Get the name of the current xls file
    xlsFileName = dir2findxls(i).name;

    % Find the corresponding mat file in dir2find
    matchingMatFile = [];
    for j = 1:length(dir2find)
        if strcmp(xlsFileName, strrep(dir2find(j).name, '.mat', '.xls'))
            matchingMatFile = dir2find(j);
            break;
        end
    end

    % If a matching mat file is found, copy it to path2save
    if ~isempty(matchingMatFile)
        src = fullfile(matchingMatFile.folder, matchingMatFile.name);
        dest = fullfile(path2save, matchingMatFile.name);
        copyfile(src, dest);
        disp(['Copied ' matchingMatFile.name ' to ' path2save]);
    else
        disp(['No matching .mat file found for ' xlsFileName]);
    end
end