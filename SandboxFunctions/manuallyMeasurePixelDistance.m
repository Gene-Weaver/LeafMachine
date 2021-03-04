function varargout = manuallyMeasurePixelDistance(varargin)
% MANUALLYMEASUREPIXELDISTANCE MATLAB code for manuallyMeasurePixelDistance.fig
%      MANUALLYMEASUREPIXELDISTANCE, by itself, creates a new MANUALLYMEASUREPIXELDISTANCE or raises the existing
%      singleton*.
%
%      H = MANUALLYMEASUREPIXELDISTANCE returns the handle to a new MANUALLYMEASUREPIXELDISTANCE or the handle to
%      the existing singleton*.
%
%      MANUALLYMEASUREPIXELDISTANCE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MANUALLYMEASUREPIXELDISTANCE.M with the given input arguments.
%
%      MANUALLYMEASUREPIXELDISTANCE('Property','Value',...) creates a new MANUALLYMEASUREPIXELDISTANCE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before manuallyMeasurePixelDistance_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to manuallyMeasurePixelDistance_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help manuallyMeasurePixelDistance

% Last Modified by GUIDE v2.5 03-May-2019 17:27:10

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @manuallyMeasurePixelDistance_OpeningFcn, ...
                   'gui_OutputFcn',  @manuallyMeasurePixelDistance_OutputFcn, ...
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
end

% --- Executes just before manuallyMeasurePixelDistance is made visible.
function manuallyMeasurePixelDistance_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to manuallyMeasurePixelDistance (see VARARGIN)

% Choose default command line output for manuallyMeasurePixelDistance
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% This sets up the initial plot - only do when we are invisible
% so window can get raised using manuallyMeasurePixelDistance.
if strcmp(get(hObject,'Visible'),'off')
    plot(rand(5));
end

handles.fDir = "D:\Will Files\Dropbox\ML_Project\Image_Database\DwC_10RandImg";
handles.outDir = "D:\Will Files\Dropbox\ML_Project\Image_Database\DwC_10RandImg_manualPixelDistanceQC";
if ~exist(handles.outDir, 'dir')
   mkdir(handles.outDir)
end
handles.S = dir(fullfile(handles.fDir,'*.jpg')); % pattern to match filenames.
handles.idx = numel(handles.S);
handles.i = 0;
handles.line = 0;
handles.headerID = 'measurementID_1cm';
headers = {'fName','measurementID_1cm','pixelDistance','nRow','nCol'};
data = cell(1,5);
handles.dataOut = cell2table(data);
handles.dataOut.Properties.VariableNames = headers;
guidata(hObject, handles);
end


% --- Outputs from this function are returned to the command line.
function varargout = manuallyMeasurePixelDistance_OutputFcn(hObject, eventdata, handles)
handles.output = hObject;

varargout{1} = handles.output;
guidata(hObject, handles);

end

% --- Executes on button press in next.
function next_Callback(hObject, ~, handles)
% hObject    handle to next (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.output = hObject;
handles.i = handles.i + 1;
handles.line = handles.line + 1;

axes(handles.axes1);

handles.file = fullfile(handles.fDir,handles.S(handles.i).name);
handles.img = imread(handles.file);
[handles.row, handles.col,~] = size(handles.img);
imshow(handles.img);
h = imdistline(gca,[50 50],[50 450]);
pause('on');pause;
api = iptgetapi(h);

% Save pixel distance for later conversion
handles.distance = api.getDistance();

handles.dataOut.fName{handles.line} = handles.S(handles.i).name;
handles.dataOut.measurementID_1cm{handles.line} = handles.headerID;
handles.dataOut.pixelDistance{handles.line} = handles.distance;
handles.dataOut.nRow{handles.line} = handles.row;
handles.dataOut.nCol{handles.line} = handles.col;

api.delete();
guidata(hObject, handles);
end

% --- Executes on button press in add.
function add_Callback(hObject, ~, handles)
handles.output = hObject;
handles.line = handles.line + 1;

axes(handles.axes1);

handles.file = fullfile(handles.fDir,handles.S(handles.i).name);
handles.img = imread(handles.file);
[handles.row, handles.col,~] = size(handles.img);
imshow(handles.img);
h = imdistline(gca,[50 50],[50 450]);
pause('on');pause;
api = iptgetapi(h);

% Save pixel distance for later conversion
handles.distance = api.getDistance();

handles.dataOut.fName{handles.line} = handles.S(handles.i).name;
handles.dataOut.measurementID_1cm{handles.line} = handles.headerID;
handles.dataOut.pixelDistance{handles.line} = handles.distance;
handles.dataOut.nRow{handles.line} = handles.row;
handles.dataOut.nCol{handles.line} = handles.col;

api.delete();
guidata(hObject, handles);
end

% --- Executes on button press in noRuler.
function noRuler_Callback(hObject, ~, handles)
handles.output = hObject;

handles.dataOut.fName{handles.line} = handles.S(handles.i).name;
handles.dataOut.measurementID_1cm{handles.line} = handles.headerID;
handles.dataOut.pixelDistance{handles.line} = 'NA';

guidata(hObject, handles);
end

% --- Executes on button press in save.
function save_Callback(hObject, ~, handles)
handles.output = hObject;
st = [handles.headerID,'_QCPixelData2.xlsx'];
writetable(handles.dataOut,st)
guidata(hObject, handles);

end

% --- Executes on button press in finish.
function finish_Callback(hObject, ~, handles)
% hObject    handle to finish (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
end






% --------------------------------------------------------------------
function FileMenu_Callback(hObject, ~, handles)
% hObject    handle to FileMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
end

% --------------------------------------------------------------------
function OpenMenuItem_Callback(hObject, ~, handles)
% hObject    handle to OpenMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
file = uigetfile('*.fig');
if ~isequal(file, 0)
    open(file);
end
end
% --------------------------------------------------------------------
function PrintMenuItem_Callback(hObject, ~, handles)
% hObject    handle to PrintMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
printdlg(handles.figure1)
end
% --------------------------------------------------------------------
function CloseMenuItem_Callback(hObject, ~, handles)
% hObject    handle to CloseMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
selection = questdlg(['Close ' get(handles.figure1,'Name') '?'],...
                     ['Close ' get(handles.figure1,'Name') '...'],...
                     'Yes','No','Yes');
if strcmp(selection,'No')
    return;
end

delete(handles.figure1)
end

% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, ~, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1
end

% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, ~, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
     set(hObject,'BackgroundColor','white');
end

end
