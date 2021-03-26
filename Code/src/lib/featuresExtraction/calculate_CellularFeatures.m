function [CellularFeaturesValidCells,CellularFeaturesAllCells, meanSurfaceRatio, apicobasal_neighbours,polygon_distribution] = calculate_CellularFeatures(apical3dInfo,basal3dInfo,lateral3dInfo,apicalLayer,basalLayer,labelledImage,totalLateralCellsArea,absoluteLateralContacts,noValidCells,validCells)
    %CALCULATE_CELLULARFEATURES Summary of this function goes here
    %   Detailed explanation goes here

%     %% Check cell motives that participate in apico-basal intercalations.
%     apicobasal_neighbours=cellfun(@(x,y)(unique(vertcat(x,y))), apical3dInfo, basal3dInfo, 'UniformOutput',false);
%     apicoBasalTransitionsLabels = cellfun(@(x, y) unique(vertcat(setdiff(x, y), setdiff(y, x))), apical3dInfo, basal3dInfo, 'UniformOutput', false);
%     apicoBasalTransitions = cellfun(@(x) length(x), apicoBasalTransitionsLabels);
%     [verticesInfo] = getVertices3D(labelledImage, apicobasal_neighbours);
%     indexCells = find(apicoBasalTransitions>0);
%     indexCells=setdiff(indexCells,noValidCells);
%     totalMsgs = 'Motives that could not be involved in apico-basal intercalations';

%     for nIndex= 1:length(indexCells')
%         [row,~]=find(verticesInfo.verticesConnectCells==indexCells(nIndex));
%         pairedCells = apicoBasalTransitionsLabels{1,indexCells(nIndex)};
%         for indexPairedCells = 1:length(pairedCells)
%             [row2,~]=find(verticesInfo.verticesConnectCells == pairedCells(indexPairedCells));
%             rows = intersect(row,row2);
%             chosenNumbers = verticesInfo.verticesConnectCells(rows,:);
%             wrongScutoids = unique(chosenNumbers(:)');
%             otherMotifCells = setdiff(wrongScutoids,[pairedCells(indexPairedCells) indexCells(nIndex)]);
%             if ismember(otherMotifCells(1) ,apicoBasalTransitionsLabels{1,otherMotifCells(end)}) == 0 || length(otherMotifCells) > 2
%                 msg1 = 'All cells of this motif could not be involved in a apico-basal intercalation: ';
%                 msg2= string(num2str(unique(chosenNumbers(:)')));
%                 msg=strcat(msg1,msg2);
%                 if ismember(msg2,totalMsgs) == 0
%                     totalMsgs = [totalMsgs, msg2];
%                     warning(msg);
%                 end
%                 if length(otherMotifCells) == 2
%                     newApicalNeighs = apical3dInfo{1,indexCells(nIndex)}';
%                     newApicalNeighs(newApicalNeighs == pairedCells(indexPairedCells)) = [];
%                     newBasalNeighs = basal3dInfo{1,indexCells(nIndex)}';
%                     newBasalNeighs(newBasalNeighs == pairedCells(indexPairedCells)) = [];
%                     apical3dInfo{1,indexCells(nIndex)} = newApicalNeighs';
%                     basal3dInfo{1,indexCells(nIndex)} = newBasalNeighs';
%                 end
%             end
%         end
%     end

    %% Calculate polygon distribution
    [polygon_distribution_Apical] = calculate_polygon_distribution(cellfun(@length, apical3dInfo), validCells);
    [polygon_distribution_Basal] = calculate_polygon_distribution(cellfun(@length, basal3dInfo), validCells);
    [polygon_distribution_Lateral] = calculate_polygon_distribution(cellfun(@length, lateral3dInfo), validCells);
    neighbours_data = table(apical3dInfo, basal3dInfo, lateral3dInfo);
    polygon_distribution = table(polygon_distribution_Apical, polygon_distribution_Basal,polygon_distribution_Lateral);
    neighbours_data.Properties.VariableNames = {'Apical','Basal','Lateral'};
    polygon_distribution.Properties.VariableNames = {'Apical','Basal','Lateral'};

    %%  Calculate number of neighbours of each cell
    number_neighbours = table(cellfun(@length,(apical3dInfo)),cellfun(@length,(basal3dInfo)),cellfun(@length,(lateral3dInfo)));
    
    apicobasal_neighbours=cellfun(@(x,y)(unique(vertcat(x,y))), apical3dInfo, basal3dInfo, 'UniformOutput',false);
    apicobasal_neighboursRecount= cellfun(@length ,apicobasal_neighbours);
    
    %%  Calculate area cells
    apical_area_cells=cell2mat(struct2cell(regionprops(apicalLayer,'Area'))).';
    basal_area_cells=cell2mat(struct2cell(regionprops(basalLayer,'Area'))).';
    lateral_area_cells = totalLateralCellsArea;
    
    average_lateral_wall = cellfun(@mean, absoluteLateralContacts);
    std_lateral_wall = cellfun(@std, absoluteLateralContacts);
    
    meanSurfaceRatio = sum(basal_area_cells(validCells)) / sum(apical_area_cells(validCells));

    %%  Calculate volume cells
    volume_cells=table2array(regionprops3(labelledImage,'Volume'));

    %%  Determine if a cell is a scutoid or not
    scutoids_cells=cellfun(@(x,y) double(~isequal(x,y)), neighbours_data.Apical,neighbours_data.Basal);
    apicoBasalTransitions = cellfun(@(x, y) length(unique(vertcat(setdiff(x, y), setdiff(y, x)))), neighbours_data.Apical,neighbours_data.Basal);

    %%  Export to a excel file
    ID_cells=(1:length(basal3dInfo)).';
    CellularFeaturesAllCells=table(ID_cells,number_neighbours.Var1',number_neighbours.Var2',number_neighbours.Var3',apicobasal_neighboursRecount',scutoids_cells', apicoBasalTransitions', apical_area_cells,basal_area_cells,lateral_area_cells, average_lateral_wall, std_lateral_wall, volume_cells);
    CellularFeaturesAllCells.Properties.VariableNames = {'ID_Cell','Apical_sides','Basal_sides','Lateral_sides','Apicobasal_neighbours','Scutoids', 'apicoBasalTransitions', 'Apical_area','Basal_area','Lateral_area','Average_cell_wall_area', 'Std_cell_wall_area', 'Volume'};

    CellularFeaturesValidCells = CellularFeaturesAllCells;
    CellularFeaturesValidCells(noValidCells,:) = [];  
end

