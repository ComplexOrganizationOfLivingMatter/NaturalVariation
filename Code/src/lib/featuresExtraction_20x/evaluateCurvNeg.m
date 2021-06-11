function [curvNeg] = evaluateCurvNeg(solidity, sensitivity)
    curvNeg = '';
    if solidity < sensitivity
        curvNeg = 'curvNeg';
    end
end
