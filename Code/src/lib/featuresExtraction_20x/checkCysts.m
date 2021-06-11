function [warnings, resultTable] = checkCysts(bulk, cystName, numOfCells, fullCyst3dFeatures, hollowTissue3dFeatures, lumen3dFeatures, avgCellVolume, celularHeight, class, ellipsoidFactor, resultTable, warnings)

    if bulk==false
        
        %% solidity(ies) > 1
        if lumen3dFeatures.Solidity>1
            warnings = strcat(warnings, '/ lumenSolidity /')
        end

        if hollowTissue3dFeatures.Solidity>1
            warnings = strcat(warnings, '/ hollowTissueSolidity /')
        end

        if fullCyst3dFeatures.Solidity>1
            warnings = strcat(warnings, '/ cystSolidity /')
        end


        %% lumenPrincipalAxes > cystPrincipalAxes

        if any(fullCyst3dFeatures.PrincipalAxisLength - lumen3dFeatures.PrincipalAxisLength < 0)
           warnings = strcat(warnings, '/ lumenPrincipalAxes > cystPrincipalAxes/'); 
        end


        %% cystConvexVolume > cystVolume

        if (fullCyst3dFeatures.ConvexVolume - fullCyst3dFeatures.Volume < 0)
           warnings = strcat(warnings, '/ cystConvexVolume > cystVolume/'); 
        end


        %% lumenPrincipalAxes > cystPrincipalAxes

        if (lumen3dFeatures.ConvexVolume - lumen3dFeatures.Volume < 0)
           warnings = strcat(warnings, '/ lumenVolume > lumenConvexVolume/'); 
        end


        %% lumenVolume > cystVolume

        if (fullCyst3dFeatures.Volume - lumen3dFeatures.Volume < 0)
           warnings = strcat(warnings, '/ lumenVolume > fullCystVolume/'); 
        end


    else
        %%% Bulk (find outliers)
           
        %% lumen volume outliers
            
        outliers = isoutlier(resultTable.lumenVolume);
        resultTable.warnings(outliers) = cellfun(@(warning) strcat(warning, '/ lumenVolume outlier /'), resultTable.warnings(outliers), 'UniformOutput', false);

        
        %% cyst volume outliers
            
        outliers = isoutlier(resultTable.cystVolume);
        resultTable.warnings(outliers) = cellfun(@(warning) strcat(warning, '/ cyst outlier /'), resultTable.warnings(outliers), 'UniformOutput', false);

    
        %% hollowTissue volume outliers
            
        outliers = isoutlier(resultTable.hollowTissueVolume);
        resultTable.warnings(outliers) = cellfun(@(warning) strcat(warning, '/ hollowTissue outlier /'), resultTable.warnings(outliers), 'UniformOutput', false);

    
        %% lumen prinicpal axes outliers
            
        outliers = isoutlier(resultTable.lumenPrincipalAxesLength);
        outliers = or(outliers(:, 1), or(outliers(:, 2), outliers(:, 3)));
        resultTable.warnings(outliers) = cellfun(@(warning) strcat(warning, '/ lumenPrincipalAxesLength outlier /'), resultTable.warnings(outliers), 'UniformOutput', false);

    
        %% cyst prinicpal axes outliers
            
        outliers = isoutlier(resultTable.cystPrincipalAxesLength);
        outliers = or(outliers(:, 1), or(outliers(:, 2), outliers(:, 3)));
        resultTable.warnings(outliers) = cellfun(@(warning) strcat(warning, '/ cystPrincipalAxesLength outlier /'), resultTable.warnings(outliers), 'UniformOutput', false);

    
        %% hollowTissue volume outliers
            
        outliers = isoutlier(resultTable.hollowTissueVolume);
        resultTable.warnings(outliers) = cellfun(@(warning) strcat(warning, '/ hollowTissue outlier /'), resultTable.warnings(outliers), 'UniformOutput', false);

    
        %% cyst solidity outliers
            
        outliers = isoutlier(resultTable.cystSolidity);
        resultTable.warnings(outliers) = cellfun(@(warning) strcat(warning, '/ cystSolidity outlier /'), resultTable.warnings(outliers), 'UniformOutput', false);

        
        %% cyst sphericity outliers
            
        outliers = isoutlier(resultTable.cystSphericity);
        resultTable.warnings(outliers) = cellfun(@(warning) strcat(warning, '/ cystSphericity outlier /'), resultTable.warnings(outliers), 'UniformOutput', false);

    
        %% cyst solidity outliers
            
        outliers = isoutlier(resultTable.lumenSolidity);
        resultTable.warnings(outliers) = cellfun(@(warning) strcat(warning, '/ lumenSolidity outlier /'), resultTable.warnings(outliers), 'UniformOutput', false);

        
        %% cyst sphericity outliers
            
        outliers = isoutlier(resultTable.lumenSphericity);
        resultTable.warnings(outliers) = cellfun(@(warning) strcat(warning, '/ lumenSphericity outlier /'), resultTable.warnings(outliers), 'UniformOutput', false);

    
        %% hollow tissue solidity outliers
            
        outliers = isoutlier(resultTable.hollowTissueSolidity);
        resultTable.warnings(outliers) = cellfun(@(warning) strcat(warning, '/ hollowTissueSolidity outlier /'), resultTable.warnings(outliers), 'UniformOutput', false);

        
        %% hollow tissue sphericity outliers
            
        outliers = isoutlier(resultTable.hollowTissueSolidity);
        resultTable.warnings(outliers) = cellfun(@(warning) strcat(warning, '/ hollowTissueSolidity outlier /'), resultTable.warnings(outliers), 'UniformOutput', false);

    
        %% cyst surfaceArea
            
        outliers = isoutlier(resultTable.cystSurfaceArea);
        resultTable.warnings(outliers) = cellfun(@(warning) strcat(warning, '/ cystSurfaceArea outlier /'), resultTable.warnings(outliers), 'UniformOutput', false);

    
        %% lumen surfaceArea
            
        outliers = isoutlier(resultTable.lumenSurfaceArea);
        resultTable.warnings(outliers) = cellfun(@(warning) strcat(warning, '/ lumenSurfaceArea outlier /'), resultTable.warnings(outliers), 'UniformOutput', false);

    
        %% cyst cystIrregularityShapeIndex
            
        outliers = isoutlier(resultTable.cystIrregularityShapeIndex);
        resultTable.warnings(outliers) = cellfun(@(warning) strcat(warning, '/ cystIrregularityShapeIndex outlier /'), resultTable.warnings(outliers), 'UniformOutput', false);

    
        %% lumen cystIrregularityShapeIndex
            
        outliers = isoutlier(resultTable.lumenIrregularShapeIndex);
        resultTable.warnings(outliers) = cellfun(@(warning) strcat(warning, '/ lumenIrregularShapeIndex outlier /'), resultTable.warnings(outliers), 'UniformOutput', false);

    
        %% hollowTissue cystIrregularityShapeIndex
            
        outliers = isoutlier(resultTable.hollowTissueIrregularShapeIndex);
        resultTable.warnings(outliers) = cellfun(@(warning) strcat(warning, '/ hollowTissueIrregularShapeIndex outlier /'), resultTable.warnings(outliers), 'UniformOutput', false);

    
        %% cyst aspectRatio
            
        outliers = isoutlier(resultTable.cystAspectRatio);
        resultTable.warnings(outliers) = cellfun(@(warning) strcat(warning, '/ cystAspectRatio outlier /'), resultTable.warnings(outliers), 'UniformOutput', false);

    
        %% lumen aspectRatio
            
        outliers = isoutlier(resultTable.lumenAspectRatio);
        resultTable.warnings(outliers) = cellfun(@(warning) strcat(warning, '/ lumenAspectRatio outlier /'), resultTable.warnings(outliers), 'UniformOutput', false);

    
        %% hollowTissue aspectRatio
            
        outliers = isoutlier(resultTable.hollowTissueAspectRatio);
        resultTable.warnings(outliers) = cellfun(@(warning) strcat(warning, '/ hollowTissueAspectRatio outlier /'), resultTable.warnings(outliers), 'UniformOutput', false);

    
        %% percentage lumen volume
            
        outliers = isoutlier(resultTable.percentageLumenSpace);
        resultTable.warnings(outliers) = cellfun(@(warning) strcat(warning, '/ percentageLumenSpace outlier /'), resultTable.warnings(outliers), 'UniformOutput', false);

    
        %% lumen surface per cell
            
        outliers = isoutlier(resultTable.apicalSurfacePerCell);
        resultTable.warnings(outliers) = cellfun(@(warning) strcat(warning, '/ apicalSurfacePerCell outlier /'), resultTable.warnings(outliers), 'UniformOutput', false);

    
        %% cyst surface per cell
            
        outliers = isoutlier(resultTable.basalSurfacePerCell);
        resultTable.warnings(outliers) = cellfun(@(warning) strcat(warning, '/ basalSurfacePerCell outlier /'), resultTable.warnings(outliers), 'UniformOutput', false);

        
        %% cystSurfaceRatio surface per cell
            
        outliers = isoutlier(resultTable.cystSurfaceRatio);
        resultTable.warnings(outliers) = cellfun(@(warning) strcat(warning, '/ cystSurfaceRatio outlier /'), resultTable.warnings(outliers), 'UniformOutput', false);

    
    end
        
        
        
    
end