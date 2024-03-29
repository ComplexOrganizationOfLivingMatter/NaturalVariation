function plotSpatialDistributionByRanges_ui

    % plotSpatialDistributionByRanges_ui
    % 
    % Main code for plotting eggChambers norm by stage
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    data = inputdlg({'Directory with "raw" and "labels" folders', 'Saving path', 'Range e.g [0,25,50,75,100]'},...
                  'Input data', [1 50;1 50; 1 50], {pwd, pwd, '[0,150,300,500]'}); 

         
    %% select variable to plot
    params = ["ID_Cell", "Volume", "EquivDiameter", "PrincipalAxisLength", "ConvexVolume", "Solidity", "SurfaceArea", "aspectRatio", "sphericity", "normalizedVolume", "irregularityShapeIndex", "apical_NumNeighs", "apical_Area", "basal_NumNeighs", "basal_Area", "cell_height", "lateral_NumNeighs", "lateral_Area", "average_cell_wall_Area", "std_cell_wall_Area", "scutoids", "apicoBasalTransitions", "surfaceRatio", "betCentrality", "coefCluster", "GRAY"];

    for idx = 1:length(params) 
       param = params{idx};
       struct.(param) = param;
    end

    % Let the user pick some of the fields:
    C = fieldnames(struct);
    size_wind = [1 50; 1 50; 1 50; 1 50]; % Windows size
    idx = listdlg('PromptString','Select variable to plot.',...
                  'SelectionMode','single',...
                  'ListString',C, 'ListSize',[550,250]);

    % Show the values of the fields that the user picked:
    variable = [];
    for k = 1:numel(idx)
        variable = [variable, {struct.(C{idx(k)})}];
    end
    
    %% Ask for saveName
    prompt = 'Enter a saveName: ';
    saveName = input(prompt, 's');
        
    %% Find global min/max values
    % exist min/max values? if not, calculate 'em
    if isfile(strcat(data{1}, '/allStages', '_', variable{1}, '_spatialData.xls'))
        dataTable = readtable(strcat(data{1}, '/allStages', '_', variable{1}, '_spatialData.xls'));
    else
        getCellSpatialDataBulk(strcat(data{1}, '/raw/'), strcat(data{1}, '/labels/'), variable, strcat(data{1}, '/'), strcat('allStages'))
        dataTable = readtable(strcat(data{1}, '/allStages', '_', variable{1}, '_spatialData.xls'));
    end
    
    %% separate by stages
    stageSep = data(3);
    stageSep = stageSep{1};
    stageSep = str2num(stageSep);
    
    generalNCells = unique(dataTable.nCells);
    dataTable.stage =  cell(size(dataTable, 1),1);
    
    dataTable(stageSep(1)<=dataTable.nCells & dataTable.nCells<stageSep(2), 'stage') = {'1'};
    dataTable(stageSep(2)<=dataTable.nCells & dataTable.nCells<stageSep(3), 'stage') = {'2'};
    dataTable(stageSep(3)<=dataTable.nCells & dataTable.nCells<stageSep(4), 'stage') = {'3'};
    dataTable(stageSep(4)<=dataTable.nCells, 'stage') = {'4'};
    
    stages = unique(dataTable.stage);
    

    for stageIx = 1:length(stages)
        disp('Rearanging your data ...')
        stage = stages(stageIx);
        if ~exist(strcat(data{1}, '/stage_', num2str(stage{1}),'_raw/'), 'dir')
            disp('stage ', num2str(stage{1}))
            mkdir(strcat(data{1}, '/stage_', num2str(stage{1}),'_raw/'))
            mkdir(strcat(data{1}, '/stage_', num2str(stage{1}),'_labels/'))

            eggChambers = unique(dataTable(strcmp(dataTable.stage, stage{1}), 'cystID').cystID);
            for eggChamberIx = 1:length(eggChambers)
                eggChamberID = eggChambers{eggChamberIx};
                copyfile(strcat(data{1},'/raw/',eggChamberID,'.tif'), strcat(data{1}, '/stage_', num2str(stage{1}),'_raw/',eggChamberID,'.tif'))
                copyfile(strcat(data{1},'/labels/',eggChamberID,'.tif'), strcat(data{1}, '/stage_', num2str(stage{1}),'_labels/',eggChamberID,'.tif'))
            end
        end
    end
    disp('Everything is arranged now!')

    disp('plotting ...')
    for stageIx = 1:length(stages)
        stage = stages{stageIx};
        disp(strcat('stage ', stage, ' eggs'))
        minimum = min(dataTable(strcmp(dataTable.stage, stage), variable).Variables);
        maximum = max(dataTable(strcmp(dataTable.stage, stage),  variable).Variables);
    
        disp('plotting norm by stage')
        plotSpatialDistribution(strcat(data{1}, '/stage_', num2str(stage),'_raw/'), strcat(data{1}, '/stage_', num2str(stage),'_labels/'), variable{1}, strcat(data{2}, '/'), strcat(saveName,'_', num2str(stage), '_normByStage'), [minimum maximum])
        disp('plotting norm by egg')
        plotSpatialDistribution(strcat(data{1}, '/stage_', num2str(stage),'_raw/'), strcat(data{1}, '/stage_', num2str(stage),'_labels/'), variable{1}, strcat(data{2}, '/'), strcat(saveName,'_', num2str(stage), '_normByEgg'), [])
    end

    
end
