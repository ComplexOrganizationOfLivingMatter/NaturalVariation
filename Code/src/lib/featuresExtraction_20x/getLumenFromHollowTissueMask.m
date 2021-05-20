function [lumenMask] = getLumenFromHollowTissueMask(hollowTissueMask)
    filledHollowTissue = imfill(hollowTissueMask, 'holes');
    lumen = filledHollowTissue-hollowTissueMask;
end