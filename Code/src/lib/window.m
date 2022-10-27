function varargout = window(varargin)
% WINDOW MATLAB code for window.fig
%      WINDOW, by itself, creates a new WINDOW or raises the existing
%      singleton*.
%
%      H = WINDOW returns the handle to a new WINDOW or the handle to
%      the existing singleton*.
%
%      WINDOW('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in WINDOW.M with the given input arguments.
%
%      WINDOW('Property','Value',...) creates a new WINDOW or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before window_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to window_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help window

% Last Modified by GUIDE v2.5 08-May-2020 17:14:35

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @window_OpeningFcn, ...
                   'gui_OutputFcn',  @window_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

% --- Executes just before window is made visible.
function window_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to window (see VARARGIN)
% imageSequence (1), outputDir (2), labelledImage (3), lumenImage (4),
% resizeImg (5), tipValue (6), glandOrientation(7), colours(8),
% notFoundCellsApical(9), notFoundCellsBasal(10)

% Choose default command line output for window
handles.output = hObject;
set(0, 'currentfigure', hObject); 

% Update handles structure
guidata(hObject, handles);

if isempty(varargin{9}) == 0
    if isstring(varargin{10})
        set(handles.missingApical,'string',varargin{9})
    else
        set(handles.missingApical,'string', strjoin(arrayfun(@num2str, varargin{9}, 'UniformOutput', false), ', '));
    end
end
if isempty(varargin{10}) == 0
    if isstring(varargin{10})
        set(handles.missingBasal,'string',varargin{10})
    else
        set(handles.missingBasal,'string', strjoin(arrayfun(@num2str,varargin{10}, 'UniformOutput', false), ', '))
    end
end

handles.imageSequence = varargin{1};
handles.outputDir = varargin{2};
handles.labelledImageTemp = varargin{3};
handles.lumenImageTemp = varargin{4};
handles.labelledImage = varargin{3};
handles.lumenImage = varargin{4};
handles.resizeImg = varargin{5};
handles.tipValue = varargin{6};
handles.glandOrientation = varargin{7};
handles.colours = varargin{8};

labelledImage = varargin{3};
resizeImg = varargin{5};
originalSize = size(labelledImage);
sizeResized = originalSize * resizeImg;
sizeResized(3) = originalSize(3);

handles.labelledImageTemp_Resized = imresize3(labelledImage, sizeResized, 'nearest');
handles.lumenImageTemp_Resized = imresize3(double(varargin{4}), sizeResized, 'nearest')>0;

handles.selectedZ = 1;
handles.cellId = 1;
handles.showAllCells = 0;
handles.windowListener = 1;
handles.showBackground = 0;
handles.roiMask = -1;
handles.canModifyOutsideGland = 0;
handles.canModifyInsideLumen = 0;
handles.hideLumen = 0;

%% Output
handles.labelledImage = varargin{3};
handles.lumenImage = varargin{4};
handles.colours = varargin{8};

%% GUI
imageSequence = handles.imageSequence;
set(handles.slider1,'Max',size(imageSequence,3));
set(handles.slider1,'Value',1);
set(handles.slider1,'Min',1);
set(handles.slider1,'SliderStep',[1 1]./(size(imageSequence,3)-1));

set(handles.figure1,'toolbar','figure');

buttonsToRemove = findall(handles.figure1, 'Type', 'uipushtool');
buttonsToRemove(1).Visible = 'Off';
buttonsToRemove(2).Visible = 'Off';
buttonsToRemove(3).Visible = 'Off';
buttonsToRemove(4).Visible = 'Off';
buttonsToRemove(5).Visible = 'Off';
%buttonsToRemove(6).Visible = 'Off';

buttonsToRemove = findall(handles.figure1, 'Type', 'uitoggletool');
buttonsToRemove(1).Visible = 'off';
buttonsToRemove(2).Visible = 'off';
buttonsToRemove(3).Visible = 'off';
buttonsToRemove(4).Visible = 'off';
% buttonsToRemove(5).Visible = 'off';
% buttonsToRemove(9).Visible = 'off';

% hOpen = findall(gcf, 'tooltipstring', 'Brush/Select Data');
% hOpen(1).Visible = 'off';

% Update handles structure
guidata(hObject, handles);

% This sets up the initial plot - only do when we are invisible
% so window can get raised using window.
if strcmp(get(hObject,'Visible'),'off')
    showSelectedCell(handles)
end

% UIWAIT makes window wait for user response (see UIRESUME)
uiwait(handles.figure1);



% --- Outputs from this function are returned to the command line.
function varargout = window_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
varargout{2} = handles.labelledImageTemp;
varargout{3} = handles.lumenImageTemp;
varargout{4} = handles.colours;

delete(handles.figure1);

% --- Executes on button press in save.
function save_Callback(hObject, eventdata, handles)
% hObject    handle to save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
roiMask = handles.roiMask;
progressBar = waitbar(0, 'Saving... Please wait', 'WindowStyle', 'modal');
if roiMask ~= -1
    delete(roiMask);
    roiMask = -1;
    handles.roiMask = roiMask;
    labelledImage = handles.labelledImageTemp;
    newCellRegion = handles.newCellRegion;
    selectCellId = handles.cellId;
    selectedZ = handles.selectedZ;
    lumenImage = handles.lumenImageTemp;
    
    if sum(newCellRegion(:)) > 0
        %newCellRegion = imresize(double(newCellRegion), [size(labelledImage, 1)  size(labelledImage, 2)], 'nearest')>0;
        insideGland = newCellRegion>-1;
        if handles.canModifyOutsideGland == 0
            insideGland = insideGland & labelledImage(:,:,selectedZ) > 0;
        end
        %% The order is important here: Because the lumen is already 0 on the labelled image
        if handles.canModifyInsideLumen == 1
            insideGland(lumenImage(:,:,selectedZ) == 1) = 1;
        else
            insideGland(lumenImage(:,:,selectedZ) == 1) = 0;
        end
        
        if selectCellId > 0
            imgActualZ = labelledImage(:, :, selectedZ);
            mostCommonIndex = mode(imgActualZ(newCellRegion));
            % First condition: we do not care if you are modifying a cell
            % and moving into the background. We do care if you are
            % replacing one cell for another one.
            % Second condition: Beware if you create two non-overlapping
            % areas. If you are creating a new cell, we do not care about
            % this.
            if (mostCommonIndex ~= 0 && mostCommonIndex ~= selectCellId) || (sum(imgActualZ(newCellRegion) == selectCellId) == 0 && selectCellId <= max(labelledImage(:)))
                answer = questdlg(['You are mostly replacing ', num2str(mostCommonIndex) , ' with ', num2str(selectCellId),'. Are you sure you want to proceed?'], ...
                    'Confirm', ...
                    'Yes','No', 'No');
                if strcmp(answer, 'No')
                    close(progressBar)
                    return
                end
            end
            if selectCellId <= max(labelledImage(:))
                [x, y] = find(newCellRegion & insideGland);
            else % Add cell
                [x, y] = find(newCellRegion);
                
                colours = handles.colours;
                newColours = colorcube(255);
                colours(end+1, :) = newColours(randi(255), :);
                handles.colours = colours;
            end
            
            newIndices = sub2ind(size(labelledImage), x, y, ones(length(x), 1)*selectedZ);
            labelledImage(newIndices) = selectCellId;
            if handles.canModifyInsideLumen == 1
                lumenImage(newIndices) = 0;
            end
        else
            [x, y] = find(newCellRegion);
            newIndices = sub2ind(size(labelledImage), x, y, ones(length(x), 1)*selectedZ);
            labelledImage(newIndices) = selectCellId;
            lumenImage(newIndices) = 1;
            labelledImage(lumenImage>0) = 0;
        end
        handles.labelledImageTemp = labelledImage;
        handles.lumenImageTemp = lumenImage;
        % Update handles structure
        guidata(hObject, handles);
        handles = updateResizedImage(hObject, handles);
        pause(2);
    end
end
close(progressBar)
showSelectedCell(handles);


% --- Executes during object creation, after setting all properties.
function tbCellId_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tbCellId (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function tbCellId_Callback(hObject, eventdata, handles)
% hObject    handle to tbZFrame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of tbZFrame as text
%        str2double(get(hObject,'String')) returns contents of tbZFrame as a double
handles.windowListener = 1;
handles.cellId = str2double(get(hObject,'String'));
% Update handles structure
guidata(hObject, handles);

showSelectedCell(handles);


function tbZFrame_Callback(hObject, eventdata, handles)
% hObject    handle to tbZFrame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of tbZFrame as text
%        str2double(get(hObject,'String')) returns contents of tbZFrame as a double
handles.windowListener = 1;
labelledImage = handles.labelledImageTemp;
newFrameValue = str2double(get(hObject,'String'));
if newFrameValue > 0 && newFrameValue <= size(labelledImage, 3)
    handles.selectedZ = newFrameValue;
    % Update handles structure
    guidata(hObject, handles);
    showSelectedCell(handles);
end


% --- Executes during object creation, after setting all properties.
function tbZFrame_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tbZFrame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in insertROI.
function insertROI_Callback(hObject, eventdata, handles)
% hObject    handle to insertROI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.windowListener = 0;
% Update handles structure
guidata(hObject, handles);

roiMask = handles.roiMask;
if roiMask ~= -1
    delete(roiMask);
end
try
    roiMask = impoly(gca);
    newCellRegion = createMask(roiMask);
    handles.roiMask = roiMask;
    handles.newCellRegion = newCellRegion;
catch
    disp('ROI cancelled')
end
handles.windowListener = 1;
% Update handles structure
guidata(hObject, handles);
uiwait(handles.figure1);


% --- Executes on button press in increaseID.
function increaseID_Callback(hObject, eventdata, handles)
% hObject    handle to increaseID (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.windowListener = 1;
newValue = handles.cellId+1;
labelledImage = handles.labelledImageTemp_Resized;

if newValue <= max(labelledImage(:))
    handles.cellId = newValue;
    set(handles.tbCellId,'string',num2str(newValue));
    showSelectedCell(handles);
end
% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in decreaseID.
function decreaseID_Callback(hObject, eventdata, handles)
% hObject    handle to decreaseID (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.windowListener = 1;
newValue = handles.cellId-1;
if newValue >= 0
    handles.cellId = newValue;
    set(handles.tbCellId,'string',num2str(newValue));
    % Update handles structure
    guidata(hObject, handles);
    showSelectedCell(handles);
end
% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in increaseZ.
function increaseZ_Callback(hObject, eventdata, handles)
% hObject    handle to increaseZ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.windowListener = 1;
newValue = handles.selectedZ+1;
labelledImage = handles.labelledImageTemp_Resized;

if newValue <= size(labelledImage, 3)
    handles.selectedZ = newValue;
    set(handles.tbZFrame,'string',num2str(newValue));
    set(handles.slider1,'Value', newValue);
    showSelectedCell(handles);
end
% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in decreaseZ.
function decreaseZ_Callback(hObject, eventdata, handles)
% hObject    handle to decreaseZ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.windowListener = 1;
newValue = handles.selectedZ-1;
if newValue > 0
    handles.selectedZ = newValue;
    set(handles.tbZFrame,'string',num2str(newValue));
    set(handles.slider1,'Value', newValue);
    showSelectedCell(handles);
end
% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in modifyOutside.
function modifyOutside_Callback(hObject, eventdata, handles)
% hObject    handle to modifyOutside (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of modifyOutside
handles.canModifyOutsideGland = get(hObject,'Value') == 1;
% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in hideLumen.
function modifyInsideLumen_Callback(hObject, eventdata, handles)
% hObject    handle to hideLumen (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of hideLumen
handles.canModifyInsideLumen = get(hObject,'Value') == 1;
% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in modifyInsideLumen.
function hideLumen_Callback(hObject, eventdata, handles)
% hObject    handle to modifyInsideLumen (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of modifyInsideLumen
handles.hideLumen = get(hObject,'Value') == 1;
showSelectedCell(handles);
% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in btRemove.
function btRemove_Callback(hObject, eventdata, handles)
% hObject    handle to btRemove (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
cellId = handles.cellId;

answer = questdlg(['Are you sure to remove cell ', num2str(handles.cellId) , '?'], ...
    'Remove cell', ...
    'Yes','No', 'No');
if strcmp(answer, 'Yes')
    if cellId > 0
        labelledImage = handles.labelledImageTemp;
        labelledImage(labelledImage == cellId) = 0;
        handles.labelledImageTemp = labelledImage;
    else
        lumenImage = handles.lumenImageTemp;
        lumenImage(lumenImage == 1) = 0;
        handles.lumenImageTemp = lumenImage;
    end
    handles = updateResizedImage(hObject, handles);
end
showSelectedCell(handles);
% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in btAddCell.
function btAddCell_Callback(hObject, eventdata, handles)
% hObject    handle to btAddCell (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
labelledImage = handles.labelledImageTemp;
newValue = max(labelledImage(:)) + 1;
handles.cellId = newValue;
set(handles.tbCellId,'string',num2str(newValue));
% Update handles structure
guidata(hObject, handles);
insertROI_Callback(hObject, eventdata, handles)


% --- Executes on button press in btMergeCells.
function btMergeCells_Callback(hObject, eventdata, handles)
% hObject    handle to btMergeCells (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

labelledImage = handles.labelledImageTemp;

prompt = {'Enter cells to be merged (comma-separated): E.g. 20,25'};
title = 'Input';
dims = [1 35];
definput = {''};
answer = inputdlg(prompt,title,dims,definput);
if isempty(answer) == 0
    cellsToMergeStr = strtrim(strsplit(answer{1}, ','));
    cellsToMerge = cellfun(@str2double, cellsToMergeStr);
    if length(cellsToMerge) > 1
        labelledImageTmp = mergeLabelsOfImage(labelledImage, cellsToMerge);
        handles.labelledImageTemp = labelledImageTmp;
        % Update handles structure
        guidata(hObject, handles);
        updateResizedImage(hObject, handles);
        showSelectedCell(handles);
    else
        errordlg('You should add more than 1 cell label', 'MEC!');
    end
end

% --- Executes on button press in chBoxShowAll.
function chBoxShowAll_Callback(hObject, eventdata, handles)
% hObject    handle to chBoxShowAll (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.showAllCells = get(hObject,'Value') == 1;
% Update handles structure
guidata(hObject, handles);
showSelectedCell(handles);

function figure1_WindowButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if handles.windowListener==1
    %% If you are not modifying ROIs
    if strcmp(eventdata.Source.SelectionType, 'normal')
        try
            pos = round(eventdata.Source.CurrentObject.Parent.CurrentPoint);
            pos = pos(1,1:2);
            
            labelledImage = handles.labelledImageTemp;
            labelledImageZ = labelledImage(:,:,handles.selectedZ)';
            selectedCell = labelledImageZ(pos(1), pos(2));

            handles.cellId = selectedCell;
            set(handles.tbCellId,'string',num2str(selectedCell));
            
            % Update handles structure
            guidata(hObject, handles);
            showSelectedCell(handles);
        catch
        end
    end
end


% --- Executes on button press in btRemove2DCell.
function btRemove2DCell_Callback(hObject, eventdata, handles)
% hObject    handle to btRemove2DCell (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
cellId = handles.cellId;
answer = questdlg(['Are you sure to remove cell ', num2str(handles.cellId) , ' on this frame?'], ...
	'Remove cell', ...
	'Yes','No', 'No');
if strcmp(answer, 'Yes')
    if cellId > 0
        labelledImage = handles.labelledImageTemp;
        labelledImage_selectedZ = labelledImage(:, :, handles.selectedZ);
        labelledImage_selectedZ(labelledImage_selectedZ == cellId) = 0;
        labelledImage(:, :, handles.selectedZ) = labelledImage_selectedZ;
        handles.labelledImageTemp = labelledImage;
    else
        lumenImage = handles.lumenImageTemp;
        lumenImage_selectedZ = lumenImage(:, :, handles.selectedZ);
        lumenImage_selectedZ(lumenImage_selectedZ == 1) = 0;
        lumenImage(:, :, handles.selectedZ) = lumenImage_selectedZ;
        handles.lumenImageTemp = lumenImage;
    end
    % Update handles structure
    guidata(hObject, handles);
    updateResizedImage(hObject, handles);
end
showSelectedCell(handles);

% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
numZ = round(get(hObject,'Value'));
handles.selectedZ = numZ;
set(handles.tbZFrame,'string',num2str(numZ));
% Update handles structure
guidata(hObject, handles);
showSelectedCell(handles);

% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



% --- Executes on button press in showBackground.
function showBackground_Callback(hObject, eventdata, handles)
% hObject    handle to showBackground (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.showBackground = get(hObject,'Value') == 1;
% Update handles structure
guidata(hObject, handles);
showSelectedCell(handles);


% --- Executes on button press in btFillHoles.
function btFillHoles_Callback(hObject, eventdata, handles)
% hObject    handle to btFillHoles (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
labelledImage = handles.labelledImageTemp;
lumenImage = handles.lumenImageTemp;
selectedZ = handles.selectedZ;
labelledImageZ = uint16(labelledImage(:,:,selectedZ));
lumenImageZ = lumenImage(:,:,selectedZ);

invalidRegionZ = labelledImageZ == 0 & ~lumenImageZ;
invalidRegionZ = imfill(invalidRegionZ == 0, 'holes') & lumenImageZ == 0;
 
labelledImage(:,:,selectedZ) = fill0sWithCells(labelledImageZ, labelledImageZ, invalidRegionZ == 0);
handles.labelledImageTemp = labelledImage;
% Update handles structure
guidata(hObject, handles);
updateResizedImage(hObject, handles);
showSelectedCell(handles);


% --- Executes on button press in btMaintainBigObject.
function btMaintainBigObject_Callback(hObject, eventdata, handles)
% hObject    handle to btMaintainBigObject (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
labelledImageResized = handles.labelledImageTemp_Resized;
labelledImage = handles.labelledImageTemp;
progressBar = waitbar(0, 'Removing splitted objects', 'WindowStyle', 'modal');

uniqIds = unique(labelledImageResized);
uniqIds = uniqIds(2:end);

for idCell = uniqIds'
    mask3dResized = labelledImage == idCell;
    vol = regionprops3(mask3dResized,'Volume');
    % Update waitbar and message
    waitbar(idCell/max(uniqIds))
    if size(vol,1)>1
        mask3d = labelledImage == idCell;
        mask3d = bwlabeln(mask3d);
        vol = regionprops3(mask3d,'Volume');
        [~,idx] = max(vol.Volume);
        labelledImage(mask3d>0) = 0;
        labelledImage(mask3d == idx) = idCell;
    end
end
handles.labelledImageTemp = labelledImage;
% Update handles structure
guidata(hObject, handles);
updateResizedImage(hObject, handles);
close(progressBar)
showSelectedCell(handles);


% --- Executes on button press in btInterpolate3Dcell.
function btInterpolate3Dcell_Callback(hObject, eventdata, handles)
% hObject    handle to btInterpolate3Dcell (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
labelledImage = handles.labelledImageTemp;
lumenImage = handles.lumenImageTemp;
cellID = handles.cellId;
invalidRegion = labelledImage == 0 & ~lumenImage;
progressBar = waitbar(0, 'Interpolating 3D cell', 'WindowStyle', 'modal');
invalidRegion = imfill(invalidRegion == 0, 18 , 'holes') & lumenImage == 0;
waitbar(0.2)
if cellID>0
    if handles.canModifyOutsideGland == 1
       invalidRegion(labelledImage == 0) = 0;
    end
    if handles.canModifyInsideLumen == 1
       invalidRegion(lumenImage == 0) = 0;
    end

    maskCell3D = labelledImage == cellID;
    idx = find(maskCell3D); 
    [x,y,z] = ind2sub(size(maskCell3D), idx);
    shp = alphaShape(x,y,z);
    pc = criticalAlpha(shp,'one-region');
    shp.Alpha = pc;
    waitbar(0.4)
    maskCell3Duint16 = uint16(maskCell3D).*uint16(cellID);
    boundBox = regionprops3(maskCell3Duint16, 'BoundingBox');
    boundBox = boundBox.BoundingBox(cellID,:);
    
    allX = round([boundBox(1):boundBox(1)+boundBox(4)]);
    allY = round([boundBox(2):boundBox(2)+boundBox(5)]);
    allZ = round([boundBox(3):boundBox(3)+boundBox(6)]);
    maskOnes = zeros(size(maskCell3Duint16));
    maskOnes(allY,allX,allZ) = 1;
    idBoundBox = find(maskOnes);

    [qx,qy,qz] = ind2sub(size(maskCell3Duint16), idBoundBox);
    waitbar(0.5)
    tf = inShape(shp,qx,qy,qz);
    waitbar(0.8)
    idBoundBox = idBoundBox(tf==1);
    maskCell3Duint16(idBoundBox) = cellID;
    maskCell3Duint16(invalidRegion) = 0;

    labelledImage(maskCell3Duint16>0) = cellID;
    handles.labelledImageTemp = labelledImage;
    waitbar(0.9)
    % Update handles structure
    guidata(hObject, handles);
    updateResizedImage(hObject, handles);
    showSelectedCell(handles);
    waitbar(1)
    close(progressBar)

end


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure

if isequal(get(hObject, 'waitstatus'), 'waiting')
    % The GUI is still in UIWAIT, us UIRESUME
    uiresume(hObject);
else
    % The GUI is no longer waiting, just close it
    delete(hObject);
end
