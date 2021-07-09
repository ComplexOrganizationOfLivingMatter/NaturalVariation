function [ verticesInfo] = getVertices3D( L_img, neighbours, invalidRegion)
% With a labelled image as input, the objective is get all vertex for each
% cell

ratio=3;

ball = strel('sphere', ratio);

neighboursVertices = buildTripletsOfNeighs( neighbours );%intersect dilatation of each cell of triplet
vertices = cell(size(neighboursVertices, 1), 1);

initBorderImg = L_img==0;

if exist('invalidRegion', 'var') >0
    initBorderImg(invalidRegion) = 0; 
end

% We first calculate the perimeter of the cell to improve efficiency
% If the image is small, is better not to use bwperim
% For larger images it improves a lot the efficiency
    
    

for numTriplet = 1 : size(neighboursVertices,1)
    
    BW1=zeros(size(L_img));
    BW2=zeros(size(L_img));
    BW3=zeros(size(L_img));
    
    BW1(L_img==neighboursVertices(numTriplet, 1))=1;
    BW2(L_img==neighboursVertices(numTriplet, 2))=1;
    BW3(L_img==neighboursVertices(numTriplet, 3))=1;
 
    BW1_dilate = imdilate(bwperim(BW1),ball);
    BW2_dilate = imdilate(bwperim(BW2),ball);
    BW3_dilate = imdilate(bwperim(BW3),ball);

    %It is better use '&' than '.*' in this function
    indices = find(BW1_dilate & BW2_dilate & BW3_dilate & initBorderImg);
    [xPx, yPx, zPx] = ind2sub(size(BW1_dilate), indices);
    
    if length(xPx)>1
        vertices{numTriplet} = round(mean([xPx, yPx, zPx]));
    else
        vertices{numTriplet} = [xPx, yPx , zPx];
    end
end

verticesInfo.verticesPerCell = vertices;
verticesInfo.verticesConnectCells = neighboursVertices;
end

