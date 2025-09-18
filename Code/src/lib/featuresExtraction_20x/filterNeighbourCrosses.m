function filterNeighbourCrosses(neighsArray)

    infoWrongNeighs = table();
    for cellId = 1:length(neighsArray)
       
        cellIdNeighbors = neighsArray{cellId};
        
        %neighbors of cellIDNeighbours that have neighbours in common with cellIdNeighbours.
        % Interseco vecinos de vecinos con los vecinos de la primera.
        intersections = arrayfun(@(x) intersect(neighsArray{x}, neighsArray{cellId}), cellIdNeighbors, 'UniformOutput', false);
        intersectionSizes = cellfun(@numel, intersections);
        cellIdNeighbors = cellIdNeighbors(intersectionSizes==3); %THIS WAS >2 BEFORE 20240904 ASK JUAN
                
        for neighbourIx = 1:numel(cellIdNeighbors)
            neighbourId = cellIdNeighbors(neighbourIx);
            
            neighbourNeighs = neighsArray{neighbourId};
            neighbourNeighs = neighbourNeighs(neighbourNeighs~=cellId);
            
            containsCellId = arrayfun(@(c) any(neighsArray{c} == cellId), neighbourNeighs);
            
            % neighbours of the neighbour and cellId
            neighbourNeighs = neighbourNeighs(containsCellId);
            
            % up to this point, i've the neighs that are neighs of the
            % neighs and neighs of the cellId
            
            % TASK: I want to check if 2 or more of these neighbourNeighs
            % have a common neighbour apart from cellId and neighbourId.  
           
            intersection = arrayfun(@(c) intersect(neighsArray{c}, neighbourNeighs), neighbourNeighs, 'UniformOutput', false);
            nonEmptyIndices = find(~cellfun('isempty', intersection));
            nonEmptyIntersections = {intersection{nonEmptyIndices}};
            nonEmptyIntersections = nonEmptyIntersections';
            
            transposedCells = cellfun(@(c) c, nonEmptyIntersections, 'UniformOutput', false);
            nonEmptyIntersections = cell2mat(transposedCells);
            
            cellIdCounts = numCounts{cellId};
            mainConnection = cellIdCounts(neighsArray{cellId}==neighbourId);
                        
            neighbourNeighs = arrayfun(@ (c) repmat(neighbourNeighs(c), size(intersection{c},1), 1), 1:numel(neighbourNeighs), 'UniformOutput', false)';
            neighbourNeighs = neighbourNeighs(~cellfun('isempty', neighbourNeighs));
            neighbourNeighs = cell2mat(neighbourNeighs);
            
            secondaryConnection = arrayfun(@ (c, d) numCounts{c}(neighsArray{c}==d), neighbourNeighs, nonEmptyIntersections);
            
            two_four = arrayfun(@ (c) numCounts{neighbourId}(neighsArray{neighbourId}==c), nonEmptyIntersections);
            two_three = arrayfun(@ (c) numCounts{neighbourId}(neighsArray{neighbourId}==c), neighbourNeighs);
            one_three = arrayfun(@ (c) numCounts{cellId}(neighsArray{cellId}==c), neighbourNeighs);
            one_four = arrayfun(@ (c) numCounts{cellId}(neighsArray{cellId}==c), nonEmptyIntersections);
            
            tempInfoWrongNeighs = table();
            tempInfoWrongNeighs.cellId = repmat(cellId, size(nonEmptyIntersections));
            tempInfoWrongNeighs.neighbourId = repmat(neighbourId, size(nonEmptyIntersections));
            tempInfoWrongNeighs.neighbourNeighs = neighbourNeighs;
            tempInfoWrongNeighs.nonEmptyIntersections = nonEmptyIntersections;
            tempInfoWrongNeighs.one_two = repmat(mainConnection, size(nonEmptyIntersections));
            tempInfoWrongNeighs.three_four = secondaryConnection;
            tempInfoWrongNeighs.two_three = two_three;
            tempInfoWrongNeighs.two_four = two_four;
            tempInfoWrongNeighs.one_three = one_three;
            tempInfoWrongNeighs.one_four = one_four;

            infoWrongNeighs = [infoWrongNeighs; tempInfoWrongNeighs];
        end
                
    end
        
                 
    
    if ~isempty(infoWrongNeighs)
        infoWrongNeighs_array = table2array(infoWrongNeighs(:, 1:4));

        infoWrongNeighs_array_sorted = sort(infoWrongNeighs_array, 2);

        [~, uniqueIndices] = unique(infoWrongNeighs_array_sorted, 'rows');

        infoWrongNeighs_array_sorted = infoWrongNeighs_array(uniqueIndices, :);

        uniqueWrongCells = unique(infoWrongNeighs_array_sorted(:,1));
        tableNames = infoWrongNeighs.Properties.VariableNames;

        for cellIx = 1:length(uniqueWrongCells)
            cellId = uniqueWrongCells(cellIx);
            crossettas = find(infoWrongNeighs_array_sorted(:,1)==cellId);

            for crossettaIx = 1:numel(crossettas)
                crossetta = crossettas(crossettaIx);
                crossettaMembers = infoWrongNeighs_array_sorted(crossetta, 1:4);

                logicalIndex = (infoWrongNeighs.cellId == crossettaMembers(1)) & ...
                   (infoWrongNeighs.neighbourId == crossettaMembers(2)) & ...
                   (infoWrongNeighs.neighbourNeighs == crossettaMembers(3)) & ...
                   (infoWrongNeighs.nonEmptyIntersections == crossettaMembers(4));

                crossettaRow = infoWrongNeighs(logicalIndex, :);
                crossettaRow = table2array(crossettaRow);

                [minValue, minIndex] = min(crossettaRow(5:end));
                crossettaIssue = tableNames(4+minIndex);

                if strcmp(crossettaIssue{:}, 'one_two')
                    cell1 = crossettaRow(1);
                    cell2 = crossettaRow(2);
                elseif strcmp(crossettaIssue{:}, 'one_three')
                    cell1 = crossettaRow(1);
                    cell2 = crossettaRow(3);
                elseif strcmp(crossettaIssue{:}, 'one_four')
                    cell1 = crossettaRow(1);
                    cell2 = crossettaRow(4);
                elseif strcmp(crossettaIssue{:}, 'two_three')
                    cell1 = crossettaRow(2);
                    cell2 = crossettaRow(3);
                elseif strcmp(crossettaIssue{:}, 'two_four')
                    cell1 = crossettaRow(2);
                    cell2 = crossettaRow(4);      
                elseif strcmp(crossettaIssue{:}, 'three_four')
                    cell1 = crossettaRow(3);
                    cell2 = crossettaRow(4);
                end

                %% update cell1
                tempCounts = numCounts{cell1};
                tempNeighsArray = neighsArray{cell1};
                tempCounts(tempNeighsArray==cell2) = [];
                numCounts{cell1} = tempCounts;
                tempNeighsArray(tempNeighsArray==cell2) = [];
                neighsArray{cell1} = tempNeighsArray;
                numNeighs(cell1) = length(tempNeighsArray);

                %% update cell2
                tempCounts = numCounts{cell2};
                tempNeighsArray = neighsArray{cell2};
                tempCounts(tempNeighsArray==cell1) = [];
                numCounts{cell2} = tempCounts;
                tempNeighsArray(tempNeighsArray==cell1) = [];
                neighsArray{cell2} = tempNeighsArray;
                numNeighs(cell2) = length(tempNeighsArray);

            end
        end
    end
    