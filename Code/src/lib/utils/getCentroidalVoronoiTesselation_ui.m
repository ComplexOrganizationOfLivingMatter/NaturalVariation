function getCentroidalVoronoiTesselation_ui()

data = inputdlg({'savePath', 'saveName', 'principalAxis_1','principalAxis_2','principalAxis_3', 'cellHeight', 'nCells', 'radiusThreshold', 'minimumSeparation', 'iters'},...
              'Input data', [1 50;1 50; 1 50; 1 50; 1 50;1 50; 1 50; 1 50;1 50;1 50], {pwd, 'imageName', '200', '200', '200', '10', '100', '0.05', '0.5', '10'}); 

         
getCentroidalVoronoiTesselation(str2num(data{3}), str2num(data{4}), str2num(data{5}), str2num(data{6}), str2num(data{7}), str2num(data{8}), str2num(data{9}),str2num(data{10}), strcat(data{1}, '/'), data{2})
