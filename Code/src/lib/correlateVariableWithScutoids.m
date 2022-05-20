function [firstQuartileScutoids, secondQuartileScutoids, thirdQuartileScutoids, fourthQuartileScutoids] = correlateVariableWithScutoids(labelledImage, data, scutoids, variable, quantiles)
    
    % Scu
    variableArray = [];
    firstQuartileScuArray = [];
    secondQuartileScuArray = [];
    thirdQuartileScuArray = [];
    fourthQuartileScuArray = [];

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
    
    firstQuartileScutoids = sum(firstQuartileScuArray)/length(firstQuartileScuArray);
    secondQuartileScutoids = sum(secondQuartileScuArray)/length(secondQuartileScuArray);
    thirdQuartileScutoids = sum(thirdQuartileScuArray)/length(thirdQuartileScuArray);
    fourthQuartileScutoids = sum(fourthQuartileScuArray)/length(fourthQuartileScuArray);
    
    firstQuartileScutoids(isnan(firstQuartileScutoids))=0;
    secondQuartileScutoids(isnan(secondQuartileScutoids))=0;
    thirdQuartileScutoids(isnan(thirdQuartileScutoids))=0;
    fourthQuartileScutoids(isnan(fourthQuartileScutoids))=0;

end