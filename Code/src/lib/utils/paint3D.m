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
    elseif nargin == 5 && varargin{4}==3
        labelledImage=varargin{1};
        showingCells=varargin{2};
        colours=varargin{3};
        prettyGraphics = varargin{4};    
        radiusSmooth = varargin{5};
    else
        labelledImage=varargin{1};
        showingCells = (1:max(labelledImage(:)))';
        colours = colorcube(double(max(labelledImage(:))));
        colours = colours(randperm(max(labelledImage(:))), :);
        prettyGraphics = 0;
    end
    
    if prettyGraphics == 3
        if isempty(radiusSmooth)
            radiusSmooth = 2.5;
        end
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

    if prettyGraphics > 0
        figure;
        if prettyGraphics == 3
            % For label images, call the specific regionIsosurfaces
            [meshes, ~] = regionIsosurfaces(labelledImage, 'smoothRadius', radiusSmooth);
%             display each mesh with color specified by colormap of doc
            for iLabel = 1:length(meshes)
%                 if sum(colours(iLabel,:) == [0, 0, 0])==3
%                     p = patch(meshes{iLabel}, 'FaceAlpha', 0.1);
%                 else
%                     p = patch(meshes{iLabel}, 'FaceAlpha', 1);
%                 end
                p = patch(meshes{iLabel});

                set(p, 'FaceColor', colours(iLabel,:), 'LineStyle', 'none');
            end   
        else
            for numSeed = showingCells
                % Painting each cell
               [x,y,z] = ind2sub(size(labelledImage),find(labelledImage == numSeed));

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
    
    
        axis equal;
        axis('vis3d'); view(3);
        camlight left;
        camlight right;
        lighting flat
        material dull

        newFig = gca;
        newFig.XGrid = 'off';
        newFig.YGrid = 'off';
        newFig.ZGrid = 'off';
        newFig.Visible = 'off';
%         xlim([0, 200]);
%         ylim([0, 200]);
%         zlim([0, 200]);

    end
    hold off;
end

