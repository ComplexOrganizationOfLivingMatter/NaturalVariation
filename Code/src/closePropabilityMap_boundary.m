clear all

addpath(genpath('lib'))

selpath = uigetdir;
filePaths=dir([selpath '/*.tif']);

if isempty(filePaths)
    filePaths=dir([selpath '/*.tiff']);
end

nParallelThreads = 12;
sensitivity = 0.6; % <0.5 more convex, >0.5 close to concave
% delete(gcp('nocreate'))
% parpool(nParallelThreads)


path2save = fullfile(selpath,'closePropMap');
if ~exist(path2save,'dir')
    mkdir(path2save)
end

for nFile = 1: size(filePaths,1)

%     if ~exist(fullfile(path2save,filePaths(nFile).name),'file')
    
        img = readStackTif(fullfile(filePaths(nFile).folder,filePaths(nFile).name));

        BW = imbinarize(img,'global');

        L = bwlabeln(BW);
        volume = regionprops3(L,'Volume');
        [~,idLabel]=max(volume.Volume);
        BWCyst = L==idLabel;

        %get perim of segmented prob map (to reduce complexity)
        [x, y, z] = ind2sub(size(BWCyst), find(bwperim(BWCyst)));

        %Query points (all image coordinates)
        [xQ, yQ, zQ] = ind2sub(size(BWCyst), find(ones(size(BWCyst))));

        k = boundary([x,y,z],sensitivity);
    %     trisurf(k,x,y,z,'Facecolor','red','FaceAlpha',0.1)   

    
        %%Parallel loop to check if a point is into the boundary
        part=floor(length(xQ)/nParallelThreads);
        IN = cell(nParallelThreads,1);
        tic
        parfor nPar = 1:nParallelThreads
            if nPar==1
                IN{nPar} = inpolyhedron(k,[x,y,z],[xQ(1:part*nPar), yQ(1:part*nPar), zQ(1:part*nPar)])
            else
                if nPar==nParallelThreads
                    IN{nPar} = inpolyhedron(k,[x,y,z],[xQ(part*(nPar-1)+1:end), yQ(part*(nPar-1)+1:end), zQ(part*(nPar-1)+1:end)])
                else
                    IN{nPar} = inpolyhedron(k,[x,y,z],[xQ(part*(nPar-1)+1:part*(nPar)), yQ(part*(nPar-1)+1:part*(nPar)), zQ(part*(nPar-1)+1:part*(nPar))])
                end
            end
        end

        QIndexes = vertcat(IN{:});
        BWCyst2 = BWCyst;
        BWCyst2(QIndexes)=1;
        
        L = bwlabeln(BWCyst2);
        volume = regionprops3(L,'Volume');
        [~,idLabel]=max(volume.Volume);
        BWCyst2 = L==idLabel;

        %fill holes 2d
        for nZ = 1:size(BWCyst2,3)
            sliceZ = BWCyst2(:,:,nZ);
            BWCyst2(:,:,nZ) = imfill(sliceZ,'holes');
        end

        perimCystClosed = bwperim(BWCyst2);
        dilatedPerim = imdilate(perimCystClosed,strel('sphere',3));

        matchPerim = BWCyst2 & dilatedPerim & ~BW;
        img(matchPerim)=1;
   
        writeStackTif(img,fullfile(path2save,filePaths(nFile).name));
        disp(filePaths(nFile).name)
%     end
end