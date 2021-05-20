% Result Directory
resultDir = '/media/pedro/6TB/jesus/CYSTS/40X/mergeOrigHollowTissue/';

% Add path for reading
addpath('../');
addpath('../featuresExtraction/');
addpath '/home/pedro/Escritorio/jesus/NaturalVariation/Code/src/lib'


% Prob Map/
probabilityMapDir = '/media/pedro/6TB/jesus/CYSTS/40X/to_predict_green_resampled_norm/';
probabilityMapFormat = '.tif';
probabilityMapFiles = dir(strcat(probabilityMapDir, '*', probabilityMapFormat));

% Hollow Tissue Mask
hollowTissueDir = '/media/pedro/6TB/jesus/CYSTS/40X/hollowTissue_40x/';
hollowTissueFormat = '.tif';
hollowTissueFiles = dir(strcat(hollowTissueDir, '*', hollowTissueFormat));

% % Warning if different file number
% if (length(probabilityMapFiles) ~= length(hollowTissueFiles))
%        warning('Different number of files.');
% end

% for loop on files (using lumen files as reference)
for n_file = 1:length(hollowTissueFiles)
    try
        hollowTissueFilename = hollowTissueFiles(n_file).name;
        hollowTissueFullFilename = fullfile(hollowTissueDir, hollowTissueFilename);
        [~, fileName, ~] = fileparts(hollowTissueFullFilename);

        probabilityMap = readStackTif(fullfile(probabilityMapDir,  fileName));

        hollowTissue = readStackTif(fullfile(hollowTissueDir,  strcat(fileName, hollowTissueFormat)));
        
        hollowTissueNorm = hollowTissue/255;
        binaryHollowTissue = imbinarize(hollowTissueNorm);
        complementaryHollowTissue = imbinarize(1-hollowTissueNorm);
% 
%         %Gradient [70%]
%         se = strel('sphere',3); 
%         overlap = imdilate(binaryHollowTissue, se).*imdilate(complementaryHollowTissue, se);
%         relIntensity_1 = 0.4;
%         
%         overlap = overlap.*255*relIntensity_1;
%         merge_1 = overlap;
%         merge_1(overlap~=255*relIntensity_1)=probabilityMap(overlap~=255*relIntensity_1);
%         
%         %Gradient [80%]
%         se = strel('sphere',2); 
%         overlap = imdilate(binaryHollowTissue, se).*imdilate(complementaryHollowTissue, se);
%         relIntensity_2 = 0.65;
%         
%         overlap = overlap.*255*relIntensity_2;
%         merge_2 = overlap;
%         merge_2(overlap~=255*relIntensity_2)=merge_1(overlap~=255*relIntensity_2);
%         
%         %Gradient [100%]
%         se = strel('sphere',1); 
%         overlap = imdilate(binaryHollowTissue, se).*imdilate(complementaryHollowTissue, se);
%         relIntensity_3 = 0.8;
%         
%         overlap = overlap.*255*relIntensity_3;
%         merge_3 = overlap;
%         merge_3(overlap~=255*relIntensity_3)=merge_2(overlap~=255*relIntensity_3);

%         writeStackTif(merge_3/255, strcat(resultDir, strcat(fileName, '.tif')))

    perim = bwperim(binaryHollowTissue);
    merge_1 = perim*255;
    merge_1(perim~=1)=probabilityMap(perim~=1);
    merge_1 = imgaussfilt3(merge_1, 2);
    
    se = strel('sphere',4); 
    perimMask = imdilate(perim, se);
    merge_2 = double(merge_1.*perimMask);
    merge_2(perimMask~=1) = probabilityMap(perimMask~=1);
    
    writeStackTif(merge_2/255, strcat(resultDir, strcat(fileName, '.tif')))

    catch
    end

end

disp('Writting table . . .');

disp('End');
