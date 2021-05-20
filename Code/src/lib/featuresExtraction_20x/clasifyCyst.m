function [class, ellipsoidFactor] = clasifyCyst(principalAxisLength, sensitivity)
    sortedPrincipalAxisLength = sort(principalAxisLength, 'descend');
    compareAB = sortedPrincipalAxisLength(2)/sortedPrincipalAxisLength(1) > 1-sensitivity;
    compareAC = sortedPrincipalAxisLength(3)/sortedPrincipalAxisLength(1) > 1-sensitivity;
    compareBC = sortedPrincipalAxisLength(3)/sortedPrincipalAxisLength(2) > 1-sensitivity;
    
    if compareAB && compareAC && compareBC
        class = 'sphere';
    elseif compareAB && ~compareAC && ~compareBC
        class = 'oblate';
    elseif ~compareAB && ~compareAC && compareBC
        class = 'prolate';
    else
        class = 'ellipsoid';
    end
    
    ellipsoidFactor = sortedPrincipalAxisLength(1)/sortedPrincipalAxisLength(2)-sortedPrincipalAxisLength(2)/sortedPrincipalAxisLength(3);
end