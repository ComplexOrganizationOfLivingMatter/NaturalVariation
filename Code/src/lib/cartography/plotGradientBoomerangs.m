function plotGradientBoomerangs()

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % plotGradientBoomerangs
    % 
    % Main code for boomerang plotting 
    %
    % Uses xls table from getCellSpatialData.m as input
    %
    % Saves output in same folder where cellSpatialData 
    % table is
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %% Read table
    [fileName, tablePath] = uigetfile('D:\Jesus\tutorial\*.xls', 'Select cellSpatialData table');
    
    cellSpatialData = readtable(strcat(tablePath, fileName));

    savePath = tablePath;
        
    dataTable = cellSpatialData;
    
    %% Params: Size od each dot and size of each bin of polarHistogram
    dotSize = 5;
    polarBinSize = 20;
    
    zposVariable = 'normZPos';

    xyposVariable = 'normXYPos';
    
    chosenNumericVariable = 'normVariableData';

    %% asign colors
    tableForPlotting = table();
    uniqueCysts = unique(cellSpatialData.cystID);
    
    for cystIx = 1:length(uniqueCysts)
        cystID = uniqueCysts(cystIx);
        cystData = cellSpatialData(strcmp(cellSpatialData.cystID,cystID), chosenNumericVariable);
        cystData = cell2mat(table2cell(cystData));
        
        maxValue = max(cystData);
        minValue = min(cystData);
        
        Q1 = 0.25;
        Q2 = 0.5;
        Q3 = 0.75;
        
        quantiles = cystData;
        quantiles(cystData<=Q1) = 1;
        quantiles(cystData>Q1 & cystData<=Q2) = 2;
        quantiles(cystData>Q2 & cystData<=Q3) = 3;
        quantiles(cystData>Q3) = 4;

        cMap1 = interp1([0;0.5],[1 0.84 0.15; 1 0.28 0.65],linspace(0,0.5,50));
        cMap2 = interp1([0.5;1],[1 0.28 0.6; 0.41 0.28 0.55],linspace(0.5,1,50));
         
        cMap = [cMap1; cMap2]; 
        cMapIndex = round(100*(cystData-minValue)/(maxValue-minValue));
        cMapIndex(cMapIndex==0)=1;
        cMapIndex(isnan(cMapIndex))=1;
        
        colours = cMap(cMapIndex, :);
        
        auxTableForPlotting = cellSpatialData(strcmp(cellSpatialData.cystID,cystID), :);
        
        auxTableForPlotting = [auxTableForPlotting,table(colours)];
        auxTableForPlotting = [auxTableForPlotting,table(quantiles)];

        tableForPlotting = [tableForPlotting;auxTableForPlotting];
        
    end
    
    %% name
    fileName = strsplit(fileName, '.');
    fileName = fileName{1};
    
    %% plot figures

    figure
    for dotIx = 1:size(tableForPlotting, 1)
            plot(cell2mat(table2cell(tableForPlotting(dotIx,xyposVariable))),cell2mat(table2cell(tableForPlotting(dotIx,zposVariable))), 'r.', 'MarkerSize', dotSize,'Color', cell2mat(table2cell(tableForPlotting(dotIx,'colours'))));
            hold all
    end
    xlim([-0.1, 1.1])
    ylim([-0.1, 1.1])
    title('GENERAL')
    
    print(gcf,  strcat(savePath, '/', fileName, '_', 'general','.png'), '-dpng', '-r600')
    close()
    
    % general polar scatter plot 
    figure
    polarscatter(cell2mat(table2cell(tableForPlotting(:,'polarDistr'))), cell2mat(table2cell(tableForPlotting(:,'polarDist'))),dotSize, cell2mat(table2cell(tableForPlotting(:,'colours'))), 'filled')
    rticks([])
    pax = gca;
    pax.ThetaColor = 'black';
    pax.RColor = 'black';
    pax.GridColor = 'black';
    pax.LineWidth = 1;
    pax.GridAlpha = 0.5;
    

    print(gcf,  strcat(savePath, '/', fileName, '_', 'general_polarScat','.png'), '-dpng', '-r600')
    close()

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Q1
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    figure
    tableForPlottingQ1 = tableForPlotting(tableForPlotting.quantiles==1, :);
    for dotIx = 1:size(tableForPlottingQ1, 1)
            plot(cell2mat(table2cell(tableForPlottingQ1(dotIx,xyposVariable))),cell2mat(table2cell(tableForPlottingQ1(dotIx,zposVariable))), 'r.', 'MarkerSize', dotSize,'Color', cell2mat(table2cell(tableForPlottingQ1(dotIx,'colours'))));
            hold all
    end
    title('Q1')
    xlim([-0.1, 1.1])
    ylim([-0.1, 1.1])
    print(gcf,  strcat(savePath, '/', fileName, '_', 'q1','.png'), '-dpng', '-r600')
    close()
    
    % bin distribution for statistics
    
    binDistributionTable = array2table(zeros(0,12));
    cystwiseBinDistributionTable = array2table(zeros(0,13));


    % Q1 polar histogram plot 

    figure
    pHist = polarhistogram(cell2mat(table2cell(tableForPlottingQ1(:,'polarDistr'))),  10, 'BinLimits',[-pi/2 pi/2], 'FaceColor', '#FFD000', 'EdgeColor', 'black', 'FaceAlpha', 1, 'EdgeAlpha', 0.5);
    
    % bin distribution info
    binDistributionTable = [binDistributionTable; cell2table(['1', sum(pHist.BinCounts), num2cell(round(100*pHist.BinCounts/sum(pHist.BinCounts),2))])];
        
    
    % bin distribution for statistics (cystwise)
    
    cystwiseInfo = tableForPlottingQ1(:,{'cystID', 'polarDistr'});
    uniqueCystID = unique(cystwiseInfo.cystID);
    
    for cystIx = 1:length(uniqueCystID)
        infoForBinCount = cystwiseInfo(strcmp(cystwiseInfo.cystID,uniqueCystID(cystIx)), 'polarDistr');
        counts = histcounts(infoForBinCount.polarDistr,pHist.BinEdges);

        cystwiseBinDistributionTable = [cystwiseBinDistributionTable; cell2table(['Q1', uniqueCystID(cystIx), sum(counts), num2cell(round(100*counts/sum(counts),2))])];

    end
    
    % plots
    title('q1')
    maxBinCounts = max(pHist.BinCounts);
    thetaticks([0, 90, 180, 270])
    pax = gca;
    pax.RTick = [0, maxBinCounts/4, maxBinCounts/2, 3*maxBinCounts/4, maxBinCounts];
    pax.RLim = [0, maxBinCounts];
    pax.RTickLabel = [];
    pax.ThetaColor = 'black';
    pax.RColor = 'black';
    pax.GridColor = 'black';
    pax.LineWidth = 1.5;
    pax.GridAlpha = 0.1;

    print(gcf,  strcat(savePath, '/', fileName, '_', 'q1_polarhist','.png'), '-dpng', '-r600')
    close()
    
    % Q1 polar scatter plot 

    figure
    polarscatter(cell2mat(table2cell(tableForPlottingQ1(:,'polarDistr'))), cell2mat(table2cell(tableForPlottingQ1(:,'polarDist'))),dotSize, cell2mat(table2cell(tableForPlottingQ1(:,'colours'))), 'filled')
    rticks([])
    pax = gca;
    pax.ThetaColor = 'black';
    pax.RColor = 'black';
    pax.GridColor = 'black';
    pax.LineWidth = 1;
    pax.GridAlpha = 0.5;

    print(gcf,  strcat(savePath, '/', fileName, '_', 'q1_polarScat','.png'), '-dpng', '-r600')
    close()
 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Q2
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    figure
    tableForPlottingQ2 = tableForPlotting(tableForPlotting.quantiles==2, :);
    for dotIx = 1:size(tableForPlottingQ2, 1)
            plot(cell2mat(table2cell(tableForPlottingQ2(dotIx,xyposVariable))),cell2mat(table2cell(tableForPlottingQ2(dotIx,zposVariable))), 'r.', 'MarkerSize', dotSize,'Color', cell2mat(table2cell(tableForPlottingQ2(dotIx,'colours'))));
            hold all
    end
    title('Q2')
    xlim([-0.1, 1.1])
    ylim([-0.1, 1.1])
    print(gcf,  strcat(savePath, '/', fileName, '_', 'q2','.png'), '-dpng', '-r600')   
    close()

    % Q2 polar histogram
    
    figure
    pHist = polarhistogram(cell2mat(table2cell(tableForPlottingQ2(:,'polarDistr'))),  10, 'BinLimits',[-pi/2 pi/2], 'FaceColor', '#FF5D71', 'EdgeColor', 'black', 'FaceAlpha', 1, 'EdgeAlpha', 0.5);

    binDistributionTable = [binDistributionTable; cell2table(['2', sum(pHist.BinCounts), num2cell(round(100*pHist.BinCounts/sum(pHist.BinCounts),2))])];

    % bin distribution for statistics (cystwise)
    
    cystwiseInfo = tableForPlottingQ2(:,{'cystID', 'polarDistr'});
    uniqueCystID = unique(cystwiseInfo.cystID);
    
    for cystIx = 1:length(uniqueCystID)
        infoForBinCount = cystwiseInfo(strcmp(cystwiseInfo.cystID,uniqueCystID(cystIx)), 'polarDistr');
        counts = histcounts(infoForBinCount.polarDistr,pHist.BinEdges);

        cystwiseBinDistributionTable = [cystwiseBinDistributionTable; cell2table(['Q2', uniqueCystID(cystIx), sum(counts), num2cell(round(100*counts/sum(counts),2))])];

    end
    
    % plot
    
    title('q2')
    maxBinCounts = max(pHist.BinCounts);
    thetaticks([0, 90, 180, 270])
    pax = gca;
    pax.RTick = [0, maxBinCounts/4, maxBinCounts/2, 3*maxBinCounts/4, maxBinCounts];
    pax.RLim = [0, maxBinCounts];
    pax.RTickLabel = [];
    pax.ThetaColor = 'black';
    pax.RColor = 'black';
    pax.GridColor = 'black';
    pax.LineWidth = 1.5;
    pax.GridAlpha = 0.1;

    print(gcf,  strcat(savePath, '/', fileName, '_', 'q2_polarhist','.png'), '-dpng', '-r600')
    close()
    
    % Q2 polar scatter
    
    figure
    polarscatter(cell2mat(table2cell(tableForPlottingQ2(:,'polarDistr'))), cell2mat(table2cell(tableForPlottingQ2(:,'polarDist'))),dotSize, cell2mat(table2cell(tableForPlottingQ2(:,'colours'))), 'filled')
%     rticks([])
%     thetaticks([0, 90, 180, 270])
%     pax = gca;
%     pax.ThetaColor = 'black';
%     pax.RColor = 'black';
%     pax.GridColor = 'black';
%     pax.LineWidth = 1;
%     pax.GridAlpha = 0.5;
     rticks([])
    pax = gca;
    pax.ThetaColor = 'black';
    pax.RColor = 'black';
    pax.GridColor = 'black';
    pax.LineWidth = 1;
    pax.GridAlpha = 0.5;

    print(gcf,  strcat(savePath, '/', fileName, '_', 'q2_polarScat','.png'), '-dpng', '-r600')
    close()

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Q3
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    

    figure
    tableForPlottingQ3 = tableForPlotting(tableForPlotting.quantiles==3, :);
    for dotIx = 1:size(tableForPlottingQ3, 1)
            plot(cell2mat(table2cell(tableForPlottingQ3(dotIx,xyposVariable))),cell2mat(table2cell(tableForPlottingQ3(dotIx,zposVariable))), 'r.', 'MarkerSize', dotSize,'Color', cell2mat(table2cell(tableForPlottingQ3(dotIx,'colours'))));
            hold all
    end
    title('Q3')
    xlim([-0.1, 1.1])
    ylim([-0.1, 1.1])
    print(gcf,  strcat(savePath, '/', fileName, '_', 'q3','.png'), '-dpng', '-r600')
    close()
    
    % Q3 polar histogram

    figure
    pHist = polarhistogram(cell2mat(table2cell(tableForPlottingQ3(:,'polarDistr'))),  10, 'BinLimits',[-pi/2 pi/2], 'FaceColor', '#ED009F', 'EdgeColor', 'black', 'FaceAlpha', 1, 'EdgeAlpha', 0.5);
    
    binDistributionTable = [binDistributionTable; cell2table(['3', sum(pHist.BinCounts), num2cell(round(100*pHist.BinCounts/sum(pHist.BinCounts),2))])];

    % bin distribution for statistics (cystwise)
    
    cystwiseInfo = tableForPlottingQ3(:,{'cystID', 'polarDistr'});
    uniqueCystID = unique(cystwiseInfo.cystID);
    
    for cystIx = 1:length(uniqueCystID)
        infoForBinCount = cystwiseInfo(strcmp(cystwiseInfo.cystID,uniqueCystID(cystIx)), 'polarDistr');
        counts = histcounts(infoForBinCount.polarDistr,pHist.BinEdges);

        cystwiseBinDistributionTable = [cystwiseBinDistributionTable; cell2table(['Q3', uniqueCystID(cystIx), sum(counts), num2cell(round(100*counts/sum(counts),2))])];

    end
    
    % plot
    
    title('q3')
    maxBinCounts = max(pHist.BinCounts);
    thetaticks([0, 90, 180, 270])
    pax = gca;
    pax.RTick = [0, maxBinCounts/4, maxBinCounts/2, 3*maxBinCounts/4, maxBinCounts];
    pax.RLim = [0, maxBinCounts];
    pax.RTickLabel = [];
    pax.ThetaColor = 'black';
    pax.RColor = 'black';
    pax.GridColor = 'black';
    pax.LineWidth = 1.5;
    pax.GridAlpha = 0.1;

    print(gcf,  strcat(savePath, '/', fileName, '_', 'q3_polarhist','.png'), '-dpng', '-r600')
    close()

    % Q3 polar scatter

    figure
    polarscatter(cell2mat(table2cell(tableForPlottingQ3(:,'polarDistr'))), cell2mat(table2cell(tableForPlottingQ3(:,'polarDist'))),dotSize, cell2mat(table2cell(tableForPlottingQ3(:,'colours'))), 'filled')
    rticks([])
    pax = gca;
    pax.ThetaColor = 'black';
    pax.RColor = 'black';
    pax.GridColor = 'black';
    pax.LineWidth = 1;
    pax.GridAlpha = 0.5;

    print(gcf,  strcat(savePath, '/', fileName, '_', 'q3_polarScat','.png'), '-dpng', '-r600')
    close()
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Q4
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    figure
    tableForPlottingQ4 = tableForPlotting(tableForPlotting.quantiles==4, :);
    for dotIx = 1:size(tableForPlottingQ4, 1)
            plot(cell2mat(table2cell(tableForPlottingQ4(dotIx,xyposVariable))),cell2mat(table2cell(tableForPlottingQ4(dotIx,zposVariable))), 'r.', 'MarkerSize', dotSize,'Color', cell2mat(table2cell(tableForPlottingQ4(dotIx,'colours'))));
            hold all
    end
    title('Q4')
    xlim([-0.1, 1.1])
    ylim([-0.1, 1.1])
    print(gcf,  strcat(savePath, '/', fileName, '_', 'q4','.png'), '-dpng', '-r600')
    close()

    % Q4 polar histogram
    
    figure
    pHist = polarhistogram(cell2mat(table2cell(tableForPlottingQ4(:,'polarDistr'))),  10, 'BinLimits',[-pi/2 pi/2], 'FaceColor', '#710D9B', 'EdgeColor', 'black', 'FaceAlpha', 1, 'EdgeAlpha', 0.5);
   
    binDistributionTable = [binDistributionTable; cell2table(['4', sum(pHist.BinCounts), num2cell(round(100*pHist.BinCounts/sum(pHist.BinCounts),2))])];

    % bin distribution for statistics (cystwise)
    
    cystwiseInfo = tableForPlottingQ4(:,{'cystID', 'polarDistr'});
    uniqueCystID = unique(cystwiseInfo.cystID);
    
    for cystIx = 1:length(uniqueCystID)
        infoForBinCount = cystwiseInfo(strcmp(cystwiseInfo.cystID,uniqueCystID(cystIx)), 'polarDistr');
        counts = histcounts(infoForBinCount.polarDistr,pHist.BinEdges);

        cystwiseBinDistributionTable = [cystwiseBinDistributionTable; cell2table(['Q4', uniqueCystID(cystIx), sum(counts), num2cell(round(100*counts/sum(counts),2))])];

    end
    
    % plot
    
    
    title('q4')
    maxBinCounts = max(pHist.BinCounts);
    thetaticks([0, 90, 180, 270])
    pax = gca;
    pax.RTick = [0, maxBinCounts/4, maxBinCounts/2, 3*maxBinCounts/4, maxBinCounts];
    pax.RLim = [0, maxBinCounts];
    pax.RTickLabel = [];
    pax.ThetaColor = 'black';
    pax.RColor = 'black';
    pax.GridColor = 'black';
    pax.LineWidth = 1.5;
    pax.GridAlpha = 0.1;
    
    print(gcf,  strcat(savePath, '/', fileName, '_', 'q4_polarhist','.png'), '-dpng', '-r600')
    close()
    
    % Q4 polar scatter
    
    figure
    polarscatter(cell2mat(table2cell(tableForPlottingQ4(:,'polarDistr'))), cell2mat(table2cell(tableForPlottingQ4(:,'polarDist'))),dotSize, cell2mat(table2cell(tableForPlottingQ4(:,'colours'))), 'filled')
    rticks([])
    pax = gca;
    pax.ThetaColor = 'black';
    pax.RColor = 'black';
    pax.GridColor = 'black';
    pax.LineWidth = 1;
    pax.GridAlpha = 0.5;

    print(gcf,  strcat(savePath, '/', fileName, '_', 'q4_polarScat','.png'), '-dpng', '-r600')
    close()
    
    
% 
    binDistributionTable.Properties.VariableNames = {'Q', 'numCells', '-90 to -72', '-72 to -54', '-54 to -36', '-36 to -18', '-18 to 0', '0 to 18', '18 to 36', '36 to 54', '54 to 72', '72 to 90'};
    writetable(binDistributionTable, strcat(savePath, '/', fileName, '_', 'binStats.xls'));

    cystwiseBinDistributionTable.Properties.VariableNames = {'Q', 'cystID', 'numCells', '-90 to -72', '-72 to -54', '-54 to -36', '-36 to -18', '-18 to 0', '0 to 18', '18 to 36', '36 to 54', '54 to 72', '72 to 90'};
    writetable(cystwiseBinDistributionTable, strcat(savePath, '/', fileName, '_', 'cystwiseBinStats.xls'));
end
