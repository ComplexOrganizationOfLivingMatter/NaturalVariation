%% Select file
[fileName, path] = uigetfile;
dataTable = readtable(strcat(path, fileName));

%% select variables
nonNumeric = cellfun(@(x) ~isnumeric(x),table2cell(dataTable(1,:)));
dataTable(:, nonNumeric) =  [];
params = dataTable.Properties.VariableNames;

for idx = 1:length(params) 
   param = params{idx};
   struct.(param) = param;
end

% Let the user pick some of the fields:
C = fieldnames(struct);
size_wind = [1 50; 1 50; 1 50; 1 50]; % Windows size
idx = listdlg('PromptString','Select variables. Keep pushed CTRL to select several variables',...
              'SelectionMode','multiple',...
              'ListString',C, 'ListSize',[550,250]);
          
% Show the values of the fields that the user picked:
chosenVariables = [];
for k = 1:numel(idx)
    chosenVariables = [chosenVariables, {struct.(C{idx(k)})}];
end

%% Select variables for correlation
% Let the user pick some of the fields:
C = fieldnames(struct);
idx = listdlg('PromptString','Select correlation variables. Keep pushed CTRL to select several variables',...
              'SelectionMode','multiple',...
              'ListString',C, 'ListSize',[550,250]);
          
% Show the values of the fields that the user picked:
chosenVariablesCorr = [];
for k = 1:numel(idx)
    chosenVariablesCorr = [chosenVariablesCorr, {struct.(C{idx(k)})}];
end

heatmapComparison(strcat(path, fileName), chosenVariables, chosenVariablesCorr)
