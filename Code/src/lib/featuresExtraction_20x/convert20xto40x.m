
% Unet lumen Directory
predicted20xDirectory = '/media/pedro/6TB/jesus/CYSTS/40X/stardist_40x_20x/';
predicted20xFileFormat = '.tif';
predicted20xFiles = dir(strcat(predicted20xDirectory, '*', predicted20xFileFormat));

origImgDirectory = '/media/pedro/6TB/jesus/CYSTS/40X/to_predict_red_resampled_norm/';
origImgFileFormat = '.tif';
origImgFiles = dir(strcat(origImgDirectory, '*', origImgFileFormat));

for n_file = 1:length(predicted20xFiles)
    
    predicted20xFilename = predicted20xFiles(n_file).name;
    predicted20xFullFilename = fullfile(predicted20xDirectory, predicted20xFilename);
    [~, fileName, ~] = fileparts(predicted20xFullFilename);

    origImgStackImg = readStackTif(fullfile(origImgDirectory, strcat(fileName, origImgFileFormat)));

    fprintf(1, 'Processing %s\n', fileName);

    % Pixel - Micron
    x_pixel_20x = 0.6151658;
    y_pixel_20x = 0.6151658;
    z_pixel_20x = 0.7;

    x_pixel_40x = 0.0672858;
    y_pixel_40x = 0.0672858;
    z_pixel_40x = 0.5;

    predicted20xStackImg = readStackTif(predicted20xFullFilename);
    %Resize
%     shape = size(predicted20xStackImg);
%     numRows = round(shape(1)*(x_pixel_20x/x_pixel_40x));
%     numCols = round(shape(2)*(y_pixel_20x/y_pixel_40x));
%     numSlices = round(shape(3)*(z_pixel_20x/z_pixel_40x));
    shape = size(origImgStackImg);

    predicted20xStackImg = imresize3(predicted20xStackImg,[shape(1) shape(2) shape(3)], 'nearest');
    
    writeStackTif(predicted20xStackImg/255, strcat('/media/pedro/6TB/jesus/CYSTS/40X/stardist_40x/',strcat(fileName, '.tif')));

end