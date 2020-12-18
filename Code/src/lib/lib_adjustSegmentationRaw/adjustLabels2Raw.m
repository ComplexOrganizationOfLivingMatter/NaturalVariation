%adjust image 2 raw sequence
load('Results/3d_layers_info.mat','labelledImage')
tipValue = 5;

imgWithOutTips = labelledImage(tipValue+1:end-tipValue,tipValue+1:end-tipValue,tipValue+1:end-tipValue);

imgDir = dir('*basal.tif');
imInfo = imfinfo(imgDir(1).name);
zSize = size(imInfo,1);
hSize = imInfo(1).Height;

zerosMask = zeros(hSize,hSize,zSize-size(imgWithOutTips,3));

imResize1 = imresize3(imgWithOutTips,[hSize,hSize,size(imgWithOutTips,3)],'nearest');

imgReconstructed = cat(3,imResize1,zerosMask);
imRotate = imrotate3(imgReconstructed,-90,[0 0 1],'nearest','loose');
labelledImageFinal = fliplr(imRotate);

% imRotate = imrotate3(imgReconstructed,180,[0 0 1],'nearest','loose');
% imRotate1 = imresize3(imRotate,[1024,1024,62],'nearest');
% im2 = fliplr(imRotate1);
% im3 = flipud(im2);

writeStackTif(uint16(labelledImageFinal),['Results/' strrep(imgDir(1).name,'.tif','1')])
%writeStackTif(double(labelledImage),['Results/' strrep(imgDir(1).name,'1.tif',[])])

%volumeSegmenter