clc; clear; close all;

% Specify the folder containing the .mat files
folder_path = '/home/pedro/test_tracking/fixed/'; % Change to your path
save_path = '/home/pedro/test_tracking/fixed_relabeled/';

% Get a list of all .mat files
files = dir(fullfile(folder_path, '*.mat'));
[~, idx] = sort({files.name}); % Ensure correct order
files = files(idx);

% Load the first 3D labeled image
prev_data = load(fullfile(folder_path, files(1).name));
disp(fieldnames(prev_data)); % Check variable names in .mat file
prev_labels = prev_data.labelledImage; % Update if variable name is different

newName = strrep(files(1).name, '.mat', '_relabeled.tif');
writeStackTif(double(prev_labels)./255, strcat(save_path, newName));

% save(fullfile(save_path, ['relabeled_' files(i).name]), 'prev_labels');

for i = 2:length(files)
    fprintf('Processing file: %s\n', files(i).name);

    % Load the current 3D labeled image
    curr_data = load(fullfile(folder_path, files(i).name));
    curr_labels = curr_data.labelledImage;

    % Get unique labels, excluding background (0)
    unique_curr_labels = unique(curr_labels);
    unique_curr_labels(unique_curr_labels == 0) = [];
    unique_prev_labels = unique(prev_labels);
    unique_prev_labels(unique_prev_labels == 0) = [];

    % Compute centroids for prev_labels
    prev_centroids = zeros(length(unique_prev_labels), 3);
    for k = 1:length(unique_prev_labels)
        prev_label = unique_prev_labels(k);
        [px, py, pz] = ind2sub(size(prev_labels), find(prev_labels == prev_label));
        prev_centroids(k, :) = mean([px, py, pz], 1);
    end

    % Mapping of current labels to previous labels
    new_label_map = containers.Map('KeyType', 'double', 'ValueType', 'double');
    
    auxImg = zeros(size(curr_labels));
    for j = 1:length(unique_curr_labels)
        curr_label = unique_curr_labels(j);

        % Get centroid of current label
        [x, y, z] = ind2sub(size(curr_labels), find(curr_labels == curr_label));
        if isempty(x), continue; end % Skip if no pixels
        centroid_curr = mean([x, y, z], 1);
        
        labelPrev = prev_labels(round(centroid_curr(1)), round(centroid_curr(2)), round(centroid_curr(3)));

        currLabelHolder = double((curr_labels == curr_label));
        auxImg(currLabelHolder == 1) = labelPrev;
    end
    new_curr_labels = auxImg;

    % Update previous labels for next iteration
    prev_labels = new_curr_labels;
    
    newName = strrep(files(i).name, '.mat', '_relabeled.tif');
    writeStackTif(double(prev_labels)./255, strcat(save_path, newName));
    
end

disp('Label assignment completed.');
