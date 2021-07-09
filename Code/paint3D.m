function paint3D(varargin)
%PAINT3D Summary of this function goes here
%   Detailed explanation goes here
    if nargin==2 
        labelledImage=varargin{1};
        showingCells=varargin{2};
        colours = colorcube(double(max(labelledImage(:))));
        colours = colours(randperm(max(labelledImage(:))), :);
        prettyGraphics = 0;
    elseif nargin == 3
        labelledImage=varargin{1};
        showingCells=varargin{2};
        colours=varargin{3};
        prettyGraphics = 0;
    elseif nargin == 4
        labelledImage=varargin{1};
        showingCells=varargin{2};
        colours=varargin{3};
        prettyGraphics = varargin{4};
    else
        labelledImage=varargin{1};
        showingCells = (1:max(labelledImage(:)))';
        colours = colorcube(double(max(labelledImage(:))));
        colours = colours(randperm(max(labelledImage(:))), :);
        prettyGraphics = 0;
    end

    if isempty(showingCells)
        showingCells = (1:max(labelledImage(:)));
    end
    if isempty(colours)
        colours = colorcube(double(max(labelledImage(:))));
        colours = colours(randperm(max(labelledImage(:))), :);
    end
%     figure;

    if size(unique(showingCells),1) > size(unique(showingCells),2)
        showingCells = unique(showingCells)';
    else
        showingCells = unique(showingCells);
    end

    for numSeed = showingCells
        % Painting each cell
        [x,y,z] = ind2sub(size(labelledImage),find(labelledImage == numSeed));
        if isempty(x) == 0
            if prettyGraphics == 1
                shp = alphaShape(x,y,z, 1);
                pc = criticalAlpha(shp,'one-region');
                shp.Alpha = pc+3;
                plot(shp, 'FaceColor', colours(numSeed, :), 'EdgeColor', 'none', 'AmbientStrength', 0.3, 'FaceAlpha', 1);
            elseif prettyGraphics == 2
                shp = alphaShape(x,y,z, 1);
                pc = criticalAlpha(shp,'one-region');
                if isempty(pc)
                    shp = alphaShape(x,y,z);
                else
                    shp.Alpha = pc+3;
                end
                plot(shp, 'FaceColor', colours(numSeed, :), 'EdgeColor', 'none');
            else
                pcshow([x,y,z], colours(numSeed, :));
            end
            hold on;
        end
    end
    
    if prettyGraphics == 1
        axis equal
        camlight left;
        camlight right;
        lighting flat
        material dull

        newFig = gca;
        newFig.XGrid = 'off';
        newFig.YGrid = 'off';
        newFig.ZGrid = 'off';
        newFig.Visible = 'off';
    end
    hold off;
end

