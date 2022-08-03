function [firstQuartileScutoids, secondQuartileScutoids, thirdQuartileScutoids, fourthQuartileScutoids] = correlateVariableWithScutoids(labelledImage, data, scutoids, variable, quantiles)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % correlateVariableWithScutoids
    % Function that divide cyst in 4 quartiles 
    % using the chosen variable
    % then gives the percentage of cells in each quartile
    % that are scutoids.
    % THIS FUNCTION IS INTENDED TO BE LAUNCHED USING THE HOMONIMOUS _UI FILE!
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % inputs:
    % labelledImage: labels
    % data: column of values of the chosen variable
    % scutoids: column of values of scutoid variable
    % variable: Name of the variable e.g. "cell_height"
    % quantiles: if 0, quantiles will be calculated for each cyst
    %       if you rather use general quantiles, use them as input
    
    
    % Initialize variables
    variableArray = [];
    firstQuartileScuArray = [];
    secondQuartileScuArray = [];
    thirdQuartileScuArray = [];
    fourthQuartileScuArray = [];
    
    %Calculate quantiles  or load them
    if all(quantiles == 0)
        % Quartile splitting
        firstQuantile = quantile(data, 0.25);
        secondQuantile = quantile(data, 0.5);
        thirdQuantile = quantile(data, 0.75);
    else
        firstQuantile = quantiles(1);
        secondQuantile = quantiles(2);
        thirdQuantile = quantiles(3);
    end

    %for each cell, check if scutoid and add data to the afore-initialized variables
    for cellIx = 1:size(data, 1)
        
        variableValue = data(cellIx);
        
        if variableValue<=firstQuantile
            firstQuartileScuArray = [firstQuartileScuArray, scutoids(cellIx)];
        elseif (firstQuantile<variableValue) && (variableValue<=secondQuantile)
            secondQuartileScuArray = [secondQuartileScuArray, scutoids(cellIx)];
        elseif (secondQuantile<variableValue) && (variableValue<=thirdQuantile)
            thirdQuartileScuArray = [thirdQuartileScuArray, scutoids(cellIx)];
        elseif thirdQuantile<variableValue
            fourthQuartileScuArray = [fourthQuartileScuArray, scutoids(cellIx)];
        end
        
    end
    
    %Calculate percentages
    firstQuartileScutoids = sum(firstQuartileScuArray)/length(firstQuartileScuArray);
    secondQuartileScutoids = sum(secondQuartileScuArray)/length(secondQuartileScuArray);
    thirdQuartileScutoids = sum(thirdQuartileScuArray)/length(thirdQuartileScuArray);
    fourthQuartileScutoids = sum(fourthQuartileScuArray)/length(fourthQuartileScuArray);
    
    %fix nan values
    firstQuartileScutoids(isnan(firstQuartileScutoids))=0;
    secondQuartileScutoids(isnan(secondQuartileScutoids))=0;
    thirdQuartileScutoids(isnan(thirdQuartileScutoids))=0;
    fourthQuartileScutoids(isnan(fourthQuartileScutoids))=0;

end
