function plotVoronoiPolytone3D(pos,vorvx)
    col = colorcube(length(vorvx));
    figure;
    for i = 1:size(pos,1)
        K = convhulln(vorvx{i});
        trisurf(K,vorvx{i}(:,1),vorvx{i}(:,2),vorvx{i}(:,3),'FaceColor',col(i,:),'FaceAlpha',0.5,'EdgeAlpha',1)
        hold on;
    end
        scatter3(pos(:,1),pos(:,2),pos(:,3),'Marker','o','MarkerFaceColor',[0 .75 .75], 'MarkerEdgeColor','k');
        axis('equal')
        set(gca,'FontSize',16);
        xlabel('X');ylabel('Y');zlabel('Z');
        
end