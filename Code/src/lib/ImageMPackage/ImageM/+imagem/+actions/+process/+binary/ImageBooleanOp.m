classdef ImageBooleanOp < imagem.gui.Action
% Compute boolean operation from two images.
%
%   Class ImageBooleanOpAction
%
%   Example
%   ImageBooleanOpAction
%
%   See also
%

% ------
% Author: David Legland
% e-mail: david.legland@inra.fr
% Created: 2012-11-04,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2011 INRA - Cepia Software Platform.


%% Properties
properties
    Handles;
    Viewer;
    
    OpList = {@or, @and, @xor};
    OpNames = {'Or', 'And', 'Exclusive Or'};
    
end % end properties


%% Constructor
methods
    function obj = ImageBooleanOp()
    end

end % end constructors

methods
    function run(obj, frame)
        disp('image arithmetic');
        
        obj.Viewer = frame;
        createFigure(obj);
    end
    
    function hf = createFigure(obj)
        
        % action figure
        hf = figure(...
            'Name', 'Boolean Operation', ...
            'NumberTitle', 'off', ...
            'MenuBar', 'none', 'Toolbar', 'none');
        set(hf, 'units', 'pixels');
        pos = get(hf, 'Position');
        pos(3:4) = [250 200];
        set(hf, 'Position', pos);
        
        obj.Handles.Figure = hf;
        
        imageNames = getImageNames(obj.Viewer.Gui.App);
        
        % vertical layout
        vb  = uix.VBox('Parent', hf, ...
            'Spacing', 5, 'Padding', 5);
        
        gui = obj.Viewer.Gui;
        
        % one panel for value text input
        mainPanel = uix.VBox('Parent', vb);

        % combo box for the first image
        obj.Handles.ImageList1 = addComboBoxLine(gui, mainPanel, ...
            'First image:', imageNames);
        
        % combo box for the operation name
        obj.Handles.OperationList = addComboBoxLine(gui, mainPanel, ...
            'Operation:', obj.OpNames);
        
        % combo box for the second image
        obj.Handles.ImageList2 = addComboBoxLine(gui, mainPanel, ...
            'Second image:', imageNames);
        
        % button for control panel
        buttonsPanel = uix.HButtonBox('Parent', vb, 'Padding', 5);
        uicontrol('Parent', buttonsPanel, ...
            'String', 'OK', ...
            'Callback', @obj.onButtonOK);
        uicontrol('Parent', buttonsPanel, ...
            'String', 'Cancel', ...
            'Callback', @obj.onButtonCancel);
        
        set(vb, 'Heights', [-1 40] );
    end
    

    function closeFigure(obj)
        % clean up viewer figure
        
        % close the current fig
        close(obj.Handles.Figure);
    end
    
end

%% GUI Items Callback
methods
    function onButtonOK(obj, varargin)        
        
        app = obj.Viewer.Gui.App;
        
        doc1 = getDocument(app, get(obj.Handles.ImageList1, 'Value'));
        img1 = doc1.Image;

        doc2 = getDocument(app, get(obj.Handles.ImageList2, 'Value'));
        img2 = doc2.Image;
        
        % get operation as function handle
        opIndex = get(obj.Handles.OperationList, 'Value');
        op = obj.OpList{opIndex};
        opName = char(op);
        
        if ndims(img1) ~= ndims(img2)
            error('Input images must have same dimension');
        end
        if any(size(img1) ~= size(img2))
            error('Input images must have same size');
        end
        % check inputs
        if ~isBinaryImage(img1) || ~isBinaryImage(img2)
            error('Input images must be binary');
        end
        
        
        % compute result image
        res = op(img1, img2);
        
        % add image to application, and create new display
        newDoc = addImageDocument(obj.Viewer, res);
        
        % add history
        string = sprintf('%s = %s(%s, %s));\n', ...
            newDoc.Tag, opName, doc1.Tag, doc2.Tag);
        addToHistory(obj.Viewer, string);

        closeFigure(obj);
    end
    
    function onButtonCancel(obj, varargin)
        closeFigure(obj);
    end
    
end

end % end classdef

