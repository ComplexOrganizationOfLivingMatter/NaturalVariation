function plotViolinScatter(tableForScatter, dotColors, violinColor, plotOrder)

    uniqueClasses = unique(tableForScatter.class);
    uniqueTypes = unique(tableForScatter.type);
    tableForScatterOrig = tableForScatter;
    classTicks = [];
    classTicksNames = [];
    classTicksOrder = [];
    
    for classIx = 1:size(uniqueClasses, 1)
        classTicks = [classTicks, classIx];
        classTicksNames = [classTicksNames, uniqueClasses(classIx)];
        tableForScatter = tableForScatterOrig(strcmp(tableForScatterOrig.class,uniqueClasses(classIx)),  :);
        radius = 0.01;
        xyPositions = [];
        sampleTypes = [];
        colors = dotColors;
        %% classIX plot order
        classIxPlotOrder = str2num(plotOrder{classIx});
        classTicksOrder = [classTicksOrder, classIxPlotOrder];
            
        for sampleIx=1:size(tableForScatter,1)
            yposition = tableForScatter(sampleIx, 'var1').var1;

            xyPositions = [xyPositions;[classIxPlotOrder, yposition]];
            sampleTypes = [sampleTypes; tableForScatter(sampleIx, 'type').type];
        end

        sampleTypes = grp2idx(categorical(sampleTypes));

        for sampleIx=1:size(tableForScatter,1)
            distances = pdist2([classIxPlotOrder, tableForScatter(sampleIx, 'var1').var1], xyPositions);

            closestPoints = distances<radius;
            countClosesstPoints = sum(closestPoints);

            if countClosesstPoints == 1
                continue
            end

            newXPos = linspace(0, radius*countClosesstPoints/2, countClosesstPoints);
            newXPos = newXPos + classIxPlotOrder-radius*countClosesstPoints/4;
            xyPositions(closestPoints, 1) = newXPos;

        end

        %%Median
        medianValue = median(xyPositions(:, 2));

        %hfit
        hfit = figure;
        figure(hfit);
        hfit = histfit(tableForScatter.var1,100,'kernel');


        
        %%
        curveXData = hfit(2).XData;
        curveYData = 1.25*(hfit(2).YData-min(hfit(2).YData))/(max((hfit(2).YData-min(hfit(2).YData)))/(max(abs(xyPositions(:, 1)))-classIxPlotOrder));

        %Violin
        violinx1 = curveYData+classIxPlotOrder;
        violinx2 = -curveYData+classIxPlotOrder;

        %Correction
%         violinx1(1) = classIxPlotOrder;
%         violinx1(end) = classIxPlotOrder;
%     %     violinx2(1) = 1;
%         violinx2(end) = classIxPlotOrder;

        violiny = curveXData;
        
        if classIx==1
            h1=figure(2);
        else
            figure(h1);
        end
        
        if ~isempty(violinColor)
            patch([violinx1,violinx2], [violiny violiny], violinColor(classIx, :), 'EdgeColor', 'none')
            hold on
        end


        for dotIx = 1:size(xyPositions, 1)
            plot(xyPositions(dotIx,1),xyPositions(dotIx,2), 'r.', 'MarkerSize', 25,'Color', colors(sampleTypes(dotIx),:));
            hold all
        end
        plot([classIxPlotOrder-0.2 classIxPlotOrder+0.2], [medianValue medianValue], 'r')
        hold on
        xlim([0.5 size(uniqueClasses, 1)+0.5])
        ylim([0 1])
        hold on

    end
    h = zeros(size(uniqueTypes, 1), 1);
    legendText = [];
    uniqueSampleTypes = unique(sampleTypes);
    for hix = 1:size(uniqueTypes, 1)
        h(hix) = plot(1000,1000,'.', 'MarkerSize', 25, 'Color', colors(hix,:));
        legendText = [legendText, string(uniqueTypes(hix))];
        hold on
    end
    legend(h, legendText);
    xticks(classTicks);
    [~, sortIx] = sort(classTicksOrder);
    xticklabels(classTicksNames(sortIx))
end