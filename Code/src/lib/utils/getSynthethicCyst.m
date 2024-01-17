function [voronoiCyst] = getSynthethicCyst(principalAxis1, principalAxis2, principalAxis3, cellHeight, nCells, radiusThreshold, minimumSeparation)

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % INPUTS
    % principalAxisX: Principal axis from bigger to lower
    % cellHeight: Difference between apical and basal layers
    % nCells: Number of cells
    % radiusThreshold: Percentage of variation allowed around the mid
    % ellipsoid. 0.05 works nice
    % minimumSeparation: Percentage of cellHeight between the 2 closest
    % seeds. 0.50-0.75 works nice
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % full cyst axis
    principalAxis1 = round(principalAxis1/2);
    principalAxis2 = round(principalAxis2/2);
    principalAxis3 = round(principalAxis3/2);

    % lumen axis

    principalAxis1_lumen = principalAxis1-cellHeight;
    principalAxis2_lumen = principalAxis2-cellHeight;
    principalAxis3_lumen = principalAxis3-cellHeight;

    seeds = [];
    seedMatrix = zeros([512,512,512]);
    
    % I generate a seed and check if it is inside the ellipsoid of interest (in this
    % case, the one in the middle of the lumen ellipsoid and the apical ellipsoid)
    % with some margin on the principal axes (this makes it easier to satisfy the
    % equation, and we already include the variation in height). Then, I also check
    % if it is at a distance greater than cellHeight/4 from all of them, and that's
    % when I keep it. We repeat this process until we have nCells.

    pAxis1_midpoint = principalAxis1_lumen + (principalAxis1-principalAxis1_lumen)/2;
    pAxis2_midpoint = principalAxis2_lumen + (principalAxis2-principalAxis2_lumen)/2;
    pAxis3_midpoint = principalAxis3_lumen + (principalAxis3-principalAxis3_lumen)/2;

    % Radius threshold is to generate seeds around the ellipsoid of
    % interest (percentage)

    for i = 1:100000
        x = -(1+radiusThreshold)*pAxis1_midpoint + 2*(1+radiusThreshold)*pAxis1_midpoint*rand(1);
        y = -(1+radiusThreshold)*pAxis2_midpoint + 2*(1+radiusThreshold)*pAxis2_midpoint*rand(1);
        z = -(1+radiusThreshold)*pAxis3_midpoint + 2*(1+radiusThreshold)*pAxis3_midpoint*rand(1);   
        if (x^2/((1-radiusThreshold)*pAxis1_midpoint)^2 + y^2/((1-radiusThreshold)*pAxis2_midpoint)^2 + z^2/((1-radiusThreshold)*pAxis3_midpoint)^2) > 1 && (x^2/((1+radiusThreshold)*pAxis1_midpoint)^2 + y^2/((1+radiusThreshold)*pAxis2_midpoint)^2 + z^2/((1+radiusThreshold)*pAxis3_midpoint)^2) < 1
            seed_new = [x,y,z];
            if isempty(seeds)
                seeds = [seeds;seed_new];
            end
            if min(pdist2(seed_new,seeds)) <= minimumSeparation*cellHeight
                continue
            else
                seeds = [seeds;seed_new];
                seedMatrix(round((y+255)),round((x+255)),round((z+255)))=1;  %!! DO NOT CHANGE Y X Z IS CORRECT
            end
            
        end
    
        if size(seeds,1) == nCells
            break
        end
    end
    
    %%
    
    voronoiSpaceCyst = zeros([512, 512, 512]);
    [meshX,meshY,meshZ] = meshgrid(-255:256);

    cystSphere = (meshX./principalAxis1).^2 + (meshY./principalAxis2).^2 + (meshZ./principalAxis3).^2 <= 1;
    voronoiSpaceCyst(cystSphere) = 1; % set to zero
    
    voronoiSpaceLumen = zeros([512, 512, 512]);
    lumenSphere = (meshX./principalAxis1_lumen).^2 + (meshY./principalAxis2_lumen).^2 + (meshZ./principalAxis3_lumen).^2 <= 1;
    voronoiSpaceLumen(lumenSphere) = 1; % set to zero
    
    cellSpace = voronoiSpaceCyst-voronoiSpaceLumen;
    seeds_bw = bwlabeln(seedMatrix);
    
    se = strel('sphere',5);
    seeds_bw = imdilate(seeds_bw,se);
        
    %Voronoi from mask and seeds
    voronoiCyst = VoronoizateCells(cellSpace,seeds_bw);
    
    
    %resize and save
%     voronoiCyst = imresize3(voronoiCyst, [255, 255, 255], 'nearest');
    
%     writeStackTif(voronoiCyst, '/media/pedro/6TB/jesus/voronoiBasedGenerativeModel/voronoiModelCyst.tif')
%     
%     outlines = getCellOutlines(voronoiCyst);
%     
%     writeStackTif(outlines, '/media/pedro/6TB/jesus/voronoiBasedGenerativeModel/voronoiModelCystOutlines.tif')
% 
%     
%     volumeSegmenter(voronoiCyst, voronoiCyst);
%     %%
%     
%     voronoiSpace = imdilate(voronoiSpace, strelCyst);
%     voronoiSpace_aux = imdilate(voronoiSpace_aux, strelLumen);
%     
%     cellSpace = voronoiSpace-voronoiSpace_aux;

    


    
end
    

