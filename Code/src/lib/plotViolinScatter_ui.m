%% Select file
[fileName, path] = uigetfile;
dataTable = readtable(strcat(path, fileName));
dataTableCopy = dataTable;


%%
colorQuest = questdlg('Do you want to select colors?', ...
	'COLOR SELECTION', ...
	'Nah, random colors its OK','YES', 'YES');

violinQuest = questdlg('Do you want to plot violins?', ...
	'VIOLINS OR SCATTER?', ...
	'YES','Nah, just scatter', 'Nah, just scatter');


%% select variable to plot (NUMERIC!)
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
idx = listdlg('PromptString','Select variable to plot.',...
              'SelectionMode','single',...
              'ListString',C, 'ListSize',[550,250]);
          
% Show the values of the fields that the user picked:
chosenNumericVariable = [];
for k = 1:numel(idx)
    chosenNumericVariable = [chosenNumericVariable, {struct.(C{idx(k)})}];
end

%% select class variable
dataTable = dataTableCopy;

params = dataTable.Properties.VariableNames;

for idx = 1:length(params) 
   param = params{idx};
   struct.(param) = param;
end

% Let the user pick some of the fields:
C = fieldnames(struct);
size_wind = [1 50; 1 50; 1 50; 1 50]; % Windows size
idx = listdlg('PromptString','Select class variable (mutation, phenotype..., whatever)...',...
              'SelectionMode','single',...
              'ListString',C, 'ListSize',[550,250]);
          
% Show the values of the fields that the user picked:
chosenClassVariable = [];
for k = 1:numel(idx)
    chosenClassVariable = [chosenClassVariable, {struct.(C{idx(k)})}];
end

uniqueClasses = unique(dataTable(:, chosenClassVariable{1}));

prompt = table2cell(uniqueClasses);
dlgtitle = 'Choose plot order';
dims = [1 35];
defaultValues = linspace(1, size(uniqueClasses, 1), size(uniqueClasses, 1));
defaultValues = strsplit(num2str(defaultValues), ' ');
plotOrder = inputdlg(prompt,dlgtitle,dims, defaultValues);

%% select type variables
dataTable = dataTableCopy;

params = dataTable.Properties.VariableNames;

for idx = 1:length(params) 
   param = params{idx};
   struct.(param) = param;
end

% Let the user pick some of the fields:
C = fieldnames(struct);
size_wind = [1 50; 1 50; 1 50; 1 50]; % Windows size
idx = listdlg('PromptString','Select type variable (oblate/prolate, ...)',...
              'SelectionMode','single',...
              'ListString',C, 'ListSize',[550,250]);
          
% Show the values of the fields that the user picked:
chosenTypeVariable = [];
for k = 1:numel(idx)
    chosenTypeVariable = [chosenTypeVariable, {struct.(C{idx(k)})}];
end

%%
if strcmp(colorQuest, 'YES')
    colorMatrix = [];
    uniqueTypes = unique(dataTable(:, chosenTypeVariable{1}));
    for typeIx = 1:size(uniqueTypes, 1)
        colorMatrix = [colorMatrix; uisetcolor(strcat(string(uniqueTypes{typeIx, :}), ' color'))];
    end
else
    colorMatrix = random(size(uniqueTypes, 1), 3);
end

if strcmp(violinQuest, 'YES')
    violinColor = [];
    for classIx = 1:size(uniqueClasses, 1)
        violinColor = [violinColor; uisetcolor(strcat(string(uniqueClasses{classIx, :}), ' color'))];
    end
else
    violinColor = [];
end

tableForScatter = dataTableCopy(:, {chosenClassVariable{1}, chosenNumericVariable{1}, chosenTypeVariable{1}});
tableForScatter.Properties.VariableNames = {'class', 'var1', 'type'};
plotViolinScatter(tableForScatter, colorMatrix, violinColor, plotOrder)