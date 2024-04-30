function extractData

path = '/media/pedro/6TB/jesus/NaturalVariation/voronoiModel_extra/';
modelDir = dir(path);

for modelIx = 3:numel(modelDir)
    
    modelId = modelDir(modelIx).name;
    
    currentPath = strcat(path, modelId);
    
    modelName = dir(strcat(currentPath, '/', modelId, '_lloydIters_5_', '*LAYER_2.xls'));
    modelName = modelName.name;
    modelName = modelName(1:end-5);
    
    
    copyfile(strcat(strcat(currentPath, '/', modelName, '0.mat')), '/media/pedro/6TB/jesus/NaturalVariation/voronoiModel_extra_clean/');
    copyfile(strcat(strcat(currentPath, '/', modelName, '0.xls')), '/media/pedro/6TB/jesus/NaturalVariation/voronoiModel_extra_clean/');
    copyfile(strcat(strcat(currentPath, '/', modelName, '2.mat')), '/media/pedro/6TB/jesus/NaturalVariation/voronoiModel_extra_clean/');
    copyfile(strcat(strcat(currentPath, '/', modelName, '2.xls')), '/media/pedro/6TB/jesus/NaturalVariation/voronoiModel_extra_clean/');
    
end

