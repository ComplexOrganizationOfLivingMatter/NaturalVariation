function res = xor(obj, value)
% Overload the xor operator for Image objects.
%
%     RES = xor(IMG, VALUE)
%
%   Example
%   xor
%
%   See also
%     or, and

% ------
% Author: David Legland
% e-mail: david.legland@inra.fr
% Created: 2010-11-29,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2010 INRA - Cepia Software Platform.

% extract data
[data1, data2, parent, name1, name2] = parseInputCouple(obj, value, ...
    inputname(1), inputname(2));

% compute new data
newData = builtin('xor', data1, data2);

% create result image
newName = strcat(name1, ' XOR ', name2);
res = Image('data', newData, 'parent', parent, 'name', newName);
