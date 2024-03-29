classdef ImageExtendedMaxima < imagem.actions.ScalarImageAction
% Extract extended maxima in a grayscale or intensity image.
%
%   output = ImageExtendedMaximaAction(input)
%
%   Example
%   ImageExtendedMaximaAction
%
%   See also
%     ImageExtendedMinimaAction

% ------
% Author: David Legland
% e-mail: david.legland@inra.fr
% Created: 2011-11-11,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2011 INRA - Cepia Software Platform.

properties
    % the set of handles to dialog widgets, indexed by their name
    Handles;

    Viewer;
    
    % the value of dynamic, between 0 and image grayscale extent
    Value = 0;
    
    % the min and max of values present in image.
    ImageExtent;
    
    % the connectivity of the regions. Default value is 4.
    Conn = 4;
    
    % the list of available connectivity values
    ConnValues = [4, 8];
end

methods
    function obj = ImageExtendedMaxima()
    end
end

methods
    function run(obj, frame) %#ok<INUSD>
        % apply extended maxima to current image
        
        obj.Viewer = frame;
        if ~isScalarImage(currentImage(obj.Viewer))
            warning('ImageM:WrongImageType', ...
                'Extended maxima can be applied only on scalar images');
            return;
        end
        
        createExtendedMaximaFigure(obj);
        setMaximaValue(obj, obj.Value);
        updateWidgets(obj);
    end
    
    function hf = createExtendedMaximaFigure(obj)
        
        % compute intensity bounds, based either on type or on image data
        img = obj.Viewer.Doc.Image;
        if isinteger(img.Data)
            type = class(img.Data);
            minVal = double(intmin(type));
            maxVal = double(intmax(type));
        else
            minVal = double(min(img.Data(:)));
            maxVal = double(max(img.Data(:)));
        end
        obj.ImageExtent = [minVal maxVal];

        % compute slider steps
        valExtent = maxVal - minVal;
        if minVal == 0
            valExtent = valExtent + 1;
        end
        sliderStep1 = 1 / valExtent;
        sliderStep2 = 10 / valExtent;
        
        % initial value of maxima dynamic
        dynValue = valExtent / 4;
        obj.Value = dynValue;
        
        % setup connectivity options
        if ndims(img) == 2 %#ok<ISMAT>
            obj.ConnValues = [4 8];
            connValuesString = {'4', '8'};
        else
            obj.ConnValues = [6 26];
            connValuesString = {'6', '26'};
        end
        
        % background color of most widgets
        gui = obj.Viewer.Gui;
        bgColor = getWidgetBackgroundColor(gui);
        
%         % action figure
%         hf = figure(...
%             'Name', 'Extended Maxima', ...
%             'NumberTitle', 'off', ...
%             'MenuBar', 'none', ...
%             'Toolbar', 'none', ...
%             'CloseRequestFcn', @obj.closeFigure);
        % create the figure that will contains the display
        hf = createNewFigure(obj.Viewer.Gui, obj.Viewer, ...
            'Name', 'Extended Maxima', ...
            'CloseRequestFcn', @obj.closeFigure);
        
        set(hf, 'units', 'pixels');
        pos = get(hf, 'Position');
        pos(3:4) = [250 200];
        set(hf, 'Position', pos);
        
        obj.Handles.Figure = hf;
        
        % vertical layout
        vb  = uix.VBox('Parent', hf, 'Spacing', 5, 'Padding', 5);
        
        % one panel for value text input
        mainPanel = uix.VBox('Parent', vb);
        line1 = uix.HBox('Parent', mainPanel, 'Padding', 5);
        uicontrol(...
            'Style', 'Text', ...
            'Parent', line1, ...
            'String', 'Dynamic Value:');
        obj.Handles.ValueEdit = uicontrol(...
            'Style', 'Edit', ...
            'Parent', line1, ...
            'String', num2str(dynValue), ...
            'BackgroundColor', bgColor, ...
            'Callback', @obj.onTextValueChanged, ...
            'KeyPressFcn', @obj.onTextValueChanged);
        set(line1, 'Widths', [-1 -1]);

        % one slider for changing value
        obj.Handles.ValueSlider = uicontrol(...
            'Style', 'Slider', ...
            'Parent', mainPanel, ...
            'Min', 0, 'Max', valExtent, ...
            'Value', dynValue, ...
            'SliderStep', [sliderStep1 sliderStep2], ...
            'BackgroundColor', bgColor, ...
            'Callback', @obj.onSliderValueChanged);
        set(mainPanel, 'Heights', [35 25]);
        
        % setup listeners for slider continuous changes
        addlistener(obj.Handles.ValueSlider, ...
            'ContinuousValueChange', @obj.onSliderValueChanged);
        
        % combo box for the connectivity
        obj.Handles.ConnectivityPopup = addComboBoxLine(gui, mainPanel, ...
            'Connectivity:', connValuesString, ...
            @obj.onConnectivityChanged);
           
        % button for control panel
        buttonsPanel = uix.HButtonBox( 'Parent', vb, 'Padding', 5);
        uicontrol( 'Parent', buttonsPanel, ...
            'String', 'OK', ...
            'Callback', @obj.onButtonOK);
        uicontrol( 'Parent', buttonsPanel, ...
            'String', 'Cancel', ...
            'Callback', @obj.onButtonCancel);
        
        set(vb, 'Heights', [-1 40] );
    end
    
    function bin = computeMaximaImage(obj)
        % Compute the result of extended maxima.
        
        img = currentImage(obj.Viewer);
        bin = extendedMaxima(img, obj.Value, obj.Conn);

        % compute image name
        baseName = '';
        if ~isempty(img.Name)
            baseName = [img.Name '-'];
        end
        newName = sprintf('%semax%dC%d', baseName, obj.Value, obj.Conn);
        bin.Name = newName;
    end
    
    function closeFigure(obj, varargin)
        % clean up viewer figure
        clearPreviewImage(obj.Viewer);
        updateDisplay(obj.Viewer);
        
        % close the current fig
        delete(obj.Handles.Figure);
    end
    
    function setMaximaValue(obj, newValue)
        imgDyn = obj.ImageExtent(2) - obj.ImageExtent(1);
        obj.Value = max(min(round(newValue), imgDyn), 0);
    end
    
    function updateWidgets(obj)
        
        set(obj.Handles.ValueEdit, 'String', num2str(obj.Value))
        set(obj.Handles.ValueSlider, 'Value', obj.Value);
        
            
        % update preview image of the document
        bin = computeMaximaImage(obj);
        updatePreviewImage(obj.Viewer, bin);
    end
    
end

%% GUI Items Callback
methods
    function onButtonOK(obj, varargin)        
        doc = currentDoc(obj.Viewer);
        clearPreviewImage(obj.Viewer);
        updateDisplay(obj.Viewer);

        bin = computeMaximaImage(obj);
        newDoc = addImageDocument(obj.Viewer, bin);
        
        % add history
        string = sprintf('%s = extendedMaxima(%s, %s, %d);\n', ...
            newDoc.Tag, doc.Tag, num2str(obj.Value), obj.Conn);
        addToHistory(obj.Viewer, string);

        closeFigure(obj);
    end
    
    function onButtonCancel(obj, varargin)
        clearPreviewImage(obj.Viewer);
        updateDisplay(obj.Viewer);
        
        closeFigure(obj);
    end
    
    function onSliderValueChanged(obj, varargin)
        val = get(obj.Handles.ValueSlider, 'Value');
        
        setMaximaValue(obj, val);
        updateWidgets(obj);
    end
    
    function onTextValueChanged(obj, varargin)
        val = str2double(get(obj.Handles.ValueEdit, 'String'));
        if ~isfinite(val)
            return;
        end
        
        setMaximaValue(obj, val);
        updateWidgets(obj);
    end
    
    function onConnectivityChanged(obj, varargin)
        index = get(obj.Handles.ConnectivityPopup, 'Value');
        obj.Conn = obj.ConnValues(index);
        
        updateWidgets(obj);
    end
end

end