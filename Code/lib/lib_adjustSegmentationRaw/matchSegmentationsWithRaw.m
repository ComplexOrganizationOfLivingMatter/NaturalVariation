%% Match segmented cyst and raw image
pathRoot = 'E:\Pedro\Cysts\3D segmentation\';

pathRawImages = dir([pathRoot '/*/*/*.tif']);
pathSegmentedImages = dir([pathRoot '/*/*/Results/3d_layers_info.mat']);

%% Resized cyst