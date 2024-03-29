function res = horzcat(obj, varargin)
% Horizontal concatenation of images.
%
%   RES = horzcat(IMG1, IMG2)
%   RES = [IMG1 IMG2];
%
%   Example
%     % duplicate image in horizontal direction
%     img = Image.read('cameraman.tif');
%     res = horzcat(img, img);
%     show(res);
%
%   See also
%     vertcat, repmat, cat
%

% ------
% Author: David Legland
% e-mail: david.legland@inrae.fr
% Created: 2011-08-04,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2011 INRA - Cepia Software Platform.

data = obj.Data;
name = obj.Name;

for i = 1:length(varargin)
    var = varargin{i};
    data = [data ; var.Data]; %#ok<AGROW>
    
    name = strcat(name, '+', var.Name);
end

res = Image( ...
    'Data', data, ...
    'Parent', obj, ...
    'Name', name);
