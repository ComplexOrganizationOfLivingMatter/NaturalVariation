function maskOutlines = getCellOutlines(img)
    %get outline
    uniqCells = unique(img(:));
    uniqCells=uniqCells(uniqCells~=0);
    
    maskOutlines = double(zeros(size(img))); 
    for nC = uniqCells'
       maskCell = (img==nC);
       perimCell = imdilate(bwperim(maskCell),strel('sphere',1));
       maskOutlines(perimCell==1) = 1; 
    end

end
