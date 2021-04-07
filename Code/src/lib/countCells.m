function [numOfCells] = countCells(labelledImage)
    numOfCells = length(unique(labelledImage));
end