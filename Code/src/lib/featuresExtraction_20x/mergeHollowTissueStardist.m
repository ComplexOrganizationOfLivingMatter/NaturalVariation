% Result Directory
resultDir = '/media/pedro/6TB/jesus/CYSTS/40X/merge_mask_stardist';

% Add path for reading
addpath('../');
addpath('../featuresExtraction/');
addpath '/home/pedro/Escritorio/jesus/NaturalVariation/Code/src/lib'
addpath '/home/pedro/Escritorio/jesus/NaturalVariation/Code/src/lib/featuresExtraction_20x'

% Stardist 40x results
stardistMapDir = '/media/pedro/6TB/jesus/CYSTS/40X/stardist_40x/';
probabilityMapFormat = '.tif';
probabilityMapFiles = dir(strcat(stardistMapDir, '*', probabilityMapFormat));

% Hollow Tissue Mask
hollowTissueDir = '/media/pedro/6TB/jesus/CYSTS/40X/predicted_20x_40x/';
hollowTissueFormat = '.tif';
hollowTissueFiles = dir(strcat(hollowTissueDir, '*', hollowTissueFormat));

origDir = '/media/pedro/6TB/jesus/CYSTS/40X/to_predict_green_resampled_norm';
origFormat = '.tif';
origFiles = dir(strcat(origDir, '*', origFormat));

for n_file = 1:length(hollowTissueFiles)
    try
        hollowTissueFilename = hollowTissueFiles(n_file).name;
        hollowTissueFullFilename = fullfile(hollowTissueDir, hollowTissueFilename);
        [~, fileName, ~] = fileparts(hollowTissueFullFilename);

        stardistStackImg = readStackTif(fullfile(stardistMapDir, fileName));

        hollowTissueStackImg = readStackTif(fullfile(hollowTissueDir, strcat(fileName, hollowTissueFormat)));
        
        origStackImg = readStackTif(fullfile(origDir, fileName));

        croppedStardistImg = cropUsingMask(stardistStackImg, hollowTissueStackImg, 0.5, 1, 0.85, true); 

        volumeSegmenter(origStackImg, croppedStardistImg)
        
        writeStackTif(merge_2/255, strcat(resultDir, strcat(fileName, '.tif')))

    catch
    end

end

disp('Writting table . . .');

disp('End');
