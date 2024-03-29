classdef MouseListener < handle
% Listener for mouse events.
%
%   Class MouseListener
%
%   Example
%   MouseListener
%
%   See also
%

% ------
% Author: David Legland
% e-mail: david.legland@inra.fr
% Created: 2011-11-13,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2011 INRA - Cepia Software Platform.


%% Properties
properties
end % end properties


%% Constructor
methods
    function obj = MouseListener(varargin)
    % Constructor for MouseListener class

    end

end % end constructors


%% Methods
methods (Abstract)
    onMouseButtonPressed(obj, source, event)
    onMouseButtonReleased(obj, source, event)
    onMouseMoved(obj, source, event)
end % end methods

end % end classdef

