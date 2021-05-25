function cell_heights = calculateCellHeight(apicalLayer, basalLayer)

    tic
    
    centroidsApical = table2array(regionprops3(apicalLayer,'Centroid'));
   	centroidsBasal = table2array(regionprops3(basalLayer,'Centroid'));
    
    centroidsApicalAux = centroidsApical;
    centroidsBasalAux = centroidsBasal;
    
    cell_heights = nan(size(centroidsApical,1),1);
       

    for idCell = 1:length(cell_heights)
        if ~isnan(centroidsApical(idCell,1)) && ~isnan(centroidsBasal(idCell,1))
            %get all apical cell voxels
            idsApical = find(apicalLayer==idCell);
            [rowApical, colApical, zApical] = ind2sub(size(apicalLayer),idsApical);
            
            %calculate the closest apical pixel to the calculated apical centroid
            for nIdApical = 1:length(idsApical)
                distCoord = pdist2([colApical,rowApical, zApical],centroidsApical(idCell,:));
                [~,idSeedMin]=min(distCoord);
                centroidsApicalAux(idCell,:)= [colApical(idSeedMin),rowApical(idSeedMin), zApical(idSeedMin)];
            end
            
            %get all basal cell voxels
            idsBasal = find(basalLayer==idCell);
            [rowBasal, colBasal, zBasal] = ind2sub(size(basalLayer),idsBasal);
            
            %calculate the closest basal voxel to the calculated basal centroid
            for nIdBasal = 1:length(idsBasal)
                distCoord = pdist2([colBasal,rowBasal, zBasal],centroidsBasal(idCell,:));
                [~,idSeedMin]=min(distCoord);
                centroidsBasalAux(idCell,:)= [colBasal(idSeedMin),rowBasal(idSeedMin), zBasal(idSeedMin)];
            end
            
            %measure distance between the two "centroids" to infere the
            %cell height
            cell_heights(idCell) = pdist2(centroidsApicalAux(idCell,:),centroidsBasalAux(idCell,:));
            
        end
        
    end
    
    toc
    
end