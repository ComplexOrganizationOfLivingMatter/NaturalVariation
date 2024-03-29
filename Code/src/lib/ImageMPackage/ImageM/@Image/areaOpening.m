function [res, inds] = areaOpening(obj, value, varargin)
%AREAOPENING Remove small regions or particles in binary or label image.
%
%   IMG2 = areaOpening(IMG, MINSIZE);
%   Removes the particles in image IMG that have less than MINSIZE pixels
%   or voxels. IMG can be either a binary or a label image. If IMG is
%   binary, it is first labelled using 4 or 6 connectivity.
%
%   IMG2 = areaOpening(IMG, MINSIZE, CONN);
%   Applies to
%
%   Example
%     % Apply area opening on segmented rice image
%     img = Image.read('rice.png');
%     seg = whiteTopHat(img, ones(30, 30)) > 50;
%     seg2 = areaOpening(seg, 100);
%     figure;
%     subplot(1, 2, 1); show(seg); title('segmented');
%     subplot(1, 2, 2); show(seg2); title('after area opening');
%
%     % Area opening on text image
%     BW = Image.read('text.png');
%     BW2 = areaOpening(BW, 50);
%     figure; show(BW);
%     figure; show(BW2);
% 
%   See also
%     attributeOpening, largestRegion, regionprops, bwareaopen, opening
%

% ------
% Author: David Legland
% e-mail: david.legland@inra.fr
% Created: 2011-11-08,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2011 INRA - Cepia Software Platform.

% check input arguments
if nargin < 2
    error('Image:areaOpening', 'Need to specify the minimum number of pixels');
end

% force image to be label
if isLabelImage(obj)
    data = obj.Data;
    res = zeros(size(obj.Data), 'like', obj.Data);
    
elseif isBinaryImage(obj)
    % if image is binary compute labeling
    
    % choose default connectivity depending on dimension
    conn = defaultConnectivity(obj);
    
    % case of connectivity specified by user
    if ~isempty(varargin)
        conn = varargin{1};
    end
    
    % appply labeling, get result as 2D or 3D matrix
    data = labelmatrix(bwconncomp(obj.Data, conn));
    res = false(size(obj.Data), 'like', obj.Data);
    
else
    error('Image:areaOpening', 'Requires binary or label image');
end

% compute area of each region
props = regionprops(data, 'Area');
areas = [props.Area];

% select regions with areas greater than threshold
inds = find(areas >= value);

% keep only the pixels belonging to the selected regions
mask = ismember(data, inds);
res(mask) = data(mask);

% create new image
res = Image.create('data', res, 'parent', obj);
