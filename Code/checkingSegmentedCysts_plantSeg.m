pathCysts = dir('/media/pedro/6TB/jesus/NaturalVariation/fixedCysts_CARMEN/validateCysts_17_feb/reducedLumen/*.tiff');

warning('off','all')
cystToCheck = cell(size(pathCysts,1),2);

for nCyst = 1:size(pathCysts,1)

    disp(pathCysts(nCyst).name)
    
%     load(fullfile(pathCysts(nCyst).folder,pathCysts(nCyst).name))
%     img = labelledImage;
    img=readStackTif(fullfile(pathCysts(nCyst).folder,pathCysts(nCyst).name));
    
    %% Relabel 
    idLabels = unique(img(:));
    imgRelabel = zeros(size(img));
    for id = 1:length(idLabels)-1
        imgRelabel(img==idLabels(id+1))= id;
    end
    
    %% Create Voronoi cells from stardist cells
    [apicalLayer,basalLayer,lateralLayer,lumenImage] = getApicalBasalLateralAndLumenFromPlantSeg(imgRelabel,fullfile(pathCysts(nCyst).folder,strrep(pathCysts(nCyst).name,'_itkws.tiff','.mat')));

    %generate warning because possible under-detected cells "holes";
    %multilayer or cells not touching  any surface
    apicalLabels = unique(apicalLayer(apicalLayer>0));
    basalLabels = unique(basalLayer(basalLayer>0));

    splitFolder = strsplit(pathCysts(nCyst).folder,'\');
    kindOfError='';
    if ~isequal(apicalLabels,basalLabels) 
        %disp([num2str(setxor(apicalLabels,basalLabels))  'cells not touching both apical and basal surfaces'])
        if sum(lumenImage(:))==0
            kindOfError= 'OPEN cyst';
        else
            kindOfError= num2str(setxor(apicalLabels,basalLabels)');
        end
    end
    
    cystToCheck{nCyst,1}=[strrep(splitFolder{end},'_probMap','/'),pathCysts(nCyst).name];            
    cystToCheck{nCyst,2} = kindOfError;
    

end

writetable(cell2table(cystToCheck,'VariableNames',{'name','cellsNoBothSurfaces'}),fullfile(pathCysts(1).folder,['voronoiCystWarnings_' date '.xls']))
