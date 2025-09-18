function plotEmbryos_crucetas(path, name, colours, labelledImage_save, uniqueLabels, labelledImage)

% 
% ax1 = gca;
% camPos    = ax1.CameraPosition;
% camTarget = ax1.CameraTarget;
% camUp     = ax1.CameraUpVector;
% camAngle  = ax1.CameraViewAngle;

% path = '/media/pedro/6TB/jesus/NaturalVariation/LAURA/EMBRYOS/crucetas/';
% name = '020711_16cell_EP1488_YAP561_Phall647_DAPI_Series013';

for smoothFactor = 1:4
% 
%     colours = [
%     0.7    0.7    0.7   % dark red 020711_16cell_EP1488_YAP561_Phall647_DAPI_Series013
%     0.7    0.7    0.7   % light gray
%     0.7    0.7    0.7
%     0.7    0.7    0.7
%     0.7    0.7    0.7
%     0.7    0.7    0.7
%     0.7    0.7    0.7
%     0.7    0.7    0.7
%     0.7    0.7    0.7
%     0.7    0.7    0.7
%     0.5    0.0    0.0   % dark red (row 11 in your version)
%     0.7    0.7    0.7
%     0.7    0.7    0.7
%     0.7    0.7    0.7
%     0.7    0.7    0.7
%     0.7    0.7    0.7
%     ];
% % 
% colours = [    0.2039    0.4000    0.9961
%     0.9961    0.3961         0
%     0.5020         0    0.5020
%     0.2039    0.4000    0.9961
%     0.2039    0.4000    0.9961
%     0.2039    0.4000    0.9961
%     0.2039    0.4000    0.9961
%          0    0.5961         0
%          0    0.5961         0
%          0    0.5961         0
%     0.2039    0.4000    0.9961
%     0.5020         0    0.5020
%     0.5020         0    0.5020
%     0.9961    0.3961         0
%          0    0.5961         0
%     0.5020         0    0.5020]


% colours = [
% 0.7    0.7    0.7   % dark red  011311_cdx2_Phalloidin2_Series013_1
% 0.7    0.7    0.7  % light gray
% 0.7    0.7    0.7
% 0.7    0.7    0.7
% 0.7    0.7    0.7
% 0.7    0.7    0.7
% 0.7    0.7    0.7
% 0.5    0.0    0.0
% 0.7    0.7    0.7
% 0.7    0.7    0.7
% 0.7    0.7    0.7   % dark red (row 11 in your version)
% 0.7    0.7    0.7
% 0.7    0.7    0.7
% 0.7    0.7    0.7
% 0.7    0.7    0.7
% 0.7    0.7    0.7
% ];
% 

% colours = [0.5020         0    0.5020
%     0.9961    0.3961         0
%     0.2039    0.4000    0.9961
%     0.2039    0.4000    0.9961
%     0.2039    0.4000    0.9961
%          0    0.5961         0
%     0.2039    0.4000    0.9961
%     0.9961    0.3961         0
%     0.2039    0.4000    0.9961
%          0    0.5961         0
%     0.2039    0.4000    0.9961
%     0.2039    0.4000    0.9961
%     0.9961    0.3961         0
%     0.9961    0.3961         0
%     0.9961    0.3961         0
%          0    0.5961         0]
%     
%  
%     colours = [
%     0.7    0.7    0.7   % dark red E19_t177_2
% %     0.5    0.    0.5   % A
%     0.7    0.7    0.7  % A out
%     0.7    0.7    0.7
%     0.7    0.7    0.7
%     0.7    0.7    0.7
%     0.7    0.7    0.7
%     0.7    0.7    0.7
%     0.7    0.7    0.7
%     0.7    0.7    0.7
%     0.7    0.7    0.7
% %     0.5    0.0    0.0   % A
%     0.7    0.7    0.7 % A out
%     0.0    0.5    0.0   % B
% %     0.7    0.7    0.7  % B out
%     0.7    0.7    0.7
%     0.7    0.7    0.7
%     0.0    0.0    0.5   % B
% %     0.7    0.7    0.7  % B out
%     0.7    0.7    0.7
%     ];

    figure
    paint3D(labelledImage, uniqueLabels, colours, 3, smoothFactor);
    
    ax = gca;  % get current axes
    objs = ax.Children;  % all children objects

%     for i = 1:length(objs)
%         % Check if the object has 'FaceColor' property (i.e., a patch/surface)
%         if isprop(objs(i), 'FaceColor')
%             fc = objs(i).FaceColor;
% 
%             % If the color is gray [0.7 0.7 0.7], set alpha to 0.5
%             if isequal(fc, [0.7 0.7 0.7])
%                 objs(i).FaceAlpha = 0.3;
%             else
%                 objs(i).FaceAlpha = 1;  % dark red stays opaque
%             end
%         end
%     end



%     ax2 = gca;
%     ax2.CameraPosition  = camPos;
%     ax2.CameraTarget    = camTarget;
%     ax2.CameraUpVector  = camUp;
%     ax2.CameraViewAngle = camAngle;

    material([0.5 0.2 0.0 10 1])
    fig = get(groot,'CurrentFigure');
    fig.Color = [1 1 1];
    delete(findall(gcf,'Type','light'));
    camlight('headlight', 'infinite');
    camlight('headlight', 'infinite');
    camlight('headlight', 'infinite');

    savepath = strcat(path, name, '_', 'SMOOTHFACTOR_', num2str(smoothFactor));
    savefig(strcat(savepath, '.fig'))
    
    close all
%     saveas(gcf, strcat(savepath, '.png'))
end
