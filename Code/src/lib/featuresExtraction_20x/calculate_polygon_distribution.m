function [polygon_distribution]=calculate_polygon_distribution( sides_cells, valid_cells )
 
    %We discriminate for valid cells
    sides_valid_cells=sides_cells(valid_cells);
    
  
    %Calculate percentages
    digons=sum(sides_valid_cells==2)/length(sides_valid_cells);
    triangles=sum(sides_valid_cells==3)/length(sides_valid_cells);
    squares=sum(sides_valid_cells==4)/length(sides_valid_cells);
    pentagons=sum(sides_valid_cells==5)/length(sides_valid_cells);
    hexagons=sum(sides_valid_cells==6)/length(sides_valid_cells);
    heptagons=sum(sides_valid_cells==7)/length(sides_valid_cells);
    octogons=sum(sides_valid_cells==8)/length(sides_valid_cells);
    nonagons=sum(sides_valid_cells==9)/length(sides_valid_cells);
    decagons=sum(sides_valid_cells==10)/length(sides_valid_cells);
    
    
    % Clasify in a variable type cell
    polygon_distribution={};
    
    polygon_distribution{1,1}='digons'; polygon_distribution{1,2}='triangles'; polygon_distribution{1,3}='squares';  
    polygon_distribution{1,4}='pentagons'; polygon_distribution{1,5}='hexagons'; polygon_distribution{1,6}='heptagons';  
    polygon_distribution{1,7}='octogons'; polygon_distribution{1,8}='nonagons'; polygon_distribution{1,9}='decagons';


    polygon_distribution{2,1}=digons; polygon_distribution{2,2}=triangles; polygon_distribution{2,3}=squares;  
    polygon_distribution{2,4}=pentagons; polygon_distribution{2,5}=hexagons; polygon_distribution{2,6}=heptagons;  
    polygon_distribution{2,7}=octogons; polygon_distribution{2,8}=nonagons; polygon_distribution{2,9}=decagons;

    
       
end

