function [voronoiCyst] = getSynthethicCyst_mask(mask, nCells, minimumSeparation)

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % INPUTS
    % mask: binary image where seeds will be located
    % nCells: Number of cells
    % minimumSeparation: Percentage of cellHeight between the 2 closest
    % seeds. PIXELS, NOT PERCENTAGE.
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    mask = readStackTif('/media/pedro/6TB/jesus/SEASTAR/forceInference/tree/512/animal wt/stk_0016_20190806_miniata_rasGFP_H2BRFP_pos3_32cells_to_hatch_lgn_8bit-1_itkws.tiff');
    mask = mask>2; %% is lumen labeled as 0, 1, 2... background ???
    
    aux_mask = mask; 
    
    
    se = strel('sphere',8);                             %% PARAMETER
    mask = imerode(mask, se);
    
    nCells = 269;                                       %% PARAMETER
    
    % xyz positions inside mask
    [x,y,z] = ind2sub(size(mask),find(mask==1));
    seeds = [];
    seedMatrix = zeros(size(mask));
    minimumSeparation = 10; %% half of the cell height? ? ?   %% PARAMETER
    
    iters = size(x, 1);
    
    % locate random seeds and check if it's inside the mask
    for i = 1:iters
        randomDotIx = round(rand(1)*size(x, 1));
        if randomDotIx == 0
            randomDotIx = randomDotIx+1;
        end
        randomDot = [x(randomDotIx), y(randomDotIx), z(randomDotIx)];
        x(randomDotIx) = [];
        y(randomDotIx) = [];
        z(randomDotIx) = [];
        if isempty(seeds)
            seeds = [seeds;randomDot];
        end
        if min(pdist2(randomDot,seeds)) <= minimumSeparation
            continue
        else
            seeds = [seeds;randomDot];
            seedMatrix((randomDot(1)), randomDot(2), randomDot(3))=1;  %!! DO NOT CHANGE X Y Z IS CORRECT
        end
        
        if size(seeds,1)==nCells
            break
        end
            
    end
    
    %%
    
    seeds_bw = bwlabeln(seedMatrix);
    se = strel('sphere',5);
    seeds_bw = imdilate(seeds_bw,se);
        
    %Voronoi from mask and seeds
    voronoiCyst = VoronoizateCells(aux_mask,seeds_bw);
    
    
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
    

