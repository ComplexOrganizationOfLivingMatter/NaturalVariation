function getCystSummaryByRange_ui

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       getExperimentsSummaryByRange_ui       %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% ui for running getExperimentsSummaryByRange.m
%
% Using getCellSpatialData tables, counts the
% number of cells inside a user-determined
% range by experiment.
%
% input_1: pathToTable
% input_2: lowerRangeZ
% input_3: higherRangeZ
% input_4: lowerRangeVar
% input_5: higherRangeVar

% example
% lowerRangeZ = 0;
% higherRangeZ = 0.15;
% lowerRangeVar = 0;
% higherRangeVar = 0.5;

%ui get path labels
[FileName,PathName] = uigetfile('F:\', 'Select cellSpatialData table (.xls)');

prompt = {'Enter lowerRangeZ:','Enter higherRangeZ:','Enter lowerRangeVariable:','Enter higherRangeVariable:'};
dlgtitle = 'Input ranges';
dims = [1 35];
definput = {'0','0.15','0','0.5'};
inputRanges = inputdlg(prompt,dlgtitle,dims,definput);

lowerRangeZ = str2double(inputRanges{1});
higherRangeZ = str2double(inputRanges{2});
lowerRangeVar = str2double(inputRanges{3});
higherRangeVar = str2double(inputRanges{4});

disp('##########################################')
disp(strcat('Using ZRange [', inputRanges{1}, ' < normZPos < ', inputRanges{2}, ']'))
disp(strcat('Using varRange [', inputRanges{3}, ' < normVarData < ', inputRanges{4}, ']'))
disp('##########################################')

getCystSummaryByRange(PathName, FileName, lowerRangeZ, higherRangeZ, lowerRangeVar, higherRangeVar)
