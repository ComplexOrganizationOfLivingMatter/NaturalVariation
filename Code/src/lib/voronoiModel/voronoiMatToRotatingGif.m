function voronoiMatToRotatingGif(path)
path = '/media/pedro/6TB/jesus/NaturalVariation/figura_forro_laura/voronoiModel_01-Mar-2024_03-43-37_principalAxisLength_100_100_100_nSeeds_500_nDots_750_lloydIters_5_runId_2_LAYER_0.mat';
savePathGif = '/media/pedro/6TB/jesus/NaturalVariation/figura_forro_laura/voronoiModel_01-Mar-2024_03-43-37_principalAxisLength_100_100_100_nSeeds_500_nDots_750_lloydIters_5_runId_2_LAYER_0.gif';
savePathImg = '/media/pedro/6TB/jesus/NaturalVariation/figura_forro_laura/voronoiModel_01-Mar-2024_03-43-37_principalAxisLength_100_100_100_nSeeds_500_nDots_750_lloydIters_5_runId_2_LAYER_0.png';

load(path);
% openfig(path)
ve = plot_fast_marching_mesh(vertex,faces, Q, [], options);
% camorbit(0, -60)
% camlight('headlight') 

camorbit(-90, 0,'data',[0 0 1])
camorbit(+10, 0,'data',[0 1 0])
fig = get(groot,'CurrentFigure');
frame = getframe(fig);
im = frame2im(frame);
imwrite(im,savePathImg)

%     camorbit(180, 0,'data',[aah 1 1 0])
% camlight('headlight') 

for degrees = 0:180
    fig = get(groot,'CurrentFigure');
    camorbit(2, 0,'data',[1 0 0])
%     camlight('headlight') 
    frame = getframe(fig);
    im = frame2im(frame);
    [imind,cm] = rgb2ind(im, 256);
    if degrees == 0
       imwrite(imind,cm,savePathGif, 'Loopcount',inf);
    else
       imwrite(imind,cm,savePathGif,'WriteMode','append','DelayTime', 0.05);
    end
end