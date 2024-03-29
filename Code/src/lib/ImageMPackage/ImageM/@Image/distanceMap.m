function map = distanceMap(obj, varargin)
% Distance map of a binary image (2D or 3D).
%
%   MAP = distanceMap(BIN)
%   The distance transform is an operator applied to binary images, that
%   results in a graylevel image that contains, for each foregournd pixel,
%   the distance to the closest background pixel.  
%
%   Example
%     img = Image.read('circles.png');
%     map = distanceMap(img);
%     show(map)
%
%   See also
%     skeleton, geodesicDistanceMap

% ------
% Author: David Legland
% e-mail: david.legland@inrae.fr
% Created: 2011-03-27,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2011 INRA - Cepia Software Platform.

% check type
if ~strcmp(obj.Type, 'binary')
    error('Requires a binary image');
end

% compute distance map
dist = bwdist(~obj.Data, varargin{:});

newName = createNewName(obj, '%s-distMap');

% create new image
map = Image('Data', dist, ...
    'Parent', obj, ...
    'Name', newName, ...
    'Type', 'intensity', ...
    'ChannelNames', {'distance'});
