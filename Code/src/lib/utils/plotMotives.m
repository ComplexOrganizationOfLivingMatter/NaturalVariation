% [segmentedImage2]=readStackTif('D:\Antonio\seaStar\seaStar_segmentation\voronoiModels\512\1.5\embryo5_20211130_pos2\voronoi_stk_0005_20211130_pm_mYFP_H2BRFP_PEGDA_4_cells_to_19hpf_pos2_lg_8bit-1.tif');
labelledImage=uint16(labelledImage);
labelledImage2=imresize3(labelledImage, [size(labelledImage,1:2) size(labelledImage,3)*0.7/0.608], 'nearest');
motif=[13 20 21 22]; %Choose labels from cell motif
colours=[];
for nCell=2:max(max(max(labelledImage2))) %nCell of the first label:max
    if ~ismember(nCell,motif)
        colours=[colours; 0.8 0.8 0.8];
     elseif nCell == motif(1) 

        colours=[colours; 0.8 0.8 0.8]; % blue 

    elseif nCell == motif(2) 

        colours=[colours; 0.8 0.8 0.8]; %YELLOW 

    elseif nCell == motif(3) 

         colours=[colours; 0.8 0.8 0.8]; %pink

    elseif nCell == motif(4) 

         colours=[colours; 0.8 0.8 0.8]; % green

    end 
end
zSliceCut=round(94*0.7/0.608); %choose the slice you want to cut the stack
figure,paint3D(labelledImage2,unique(labelledImage2), colours, 3,1);

labelledImage3=labelledImage2(:,:,1:zSliceCut);
labelledImage3(:,:,end+1:end+50)=zeros(size(labelledImage,1),size(labelledImage,2),50);
labelledCellsPortion=ismember(unique(labelledImage2),unique(labelledImage3));
colours2=colours(labelledCellsPortion,:);
figure,paint3D(labelledImage3,unique(labelledImage3), colours2, 3,1);
% % camorbit(305, 0)
% camorbit(125, 0)
% camorbit(0, 180)
% camlight('headlight', 'infinite');
