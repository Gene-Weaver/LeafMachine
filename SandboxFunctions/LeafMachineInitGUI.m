function varargout = LeafMachineInitGUI(varargin)
% LEAFMACHINEINITGUI MATLAB code for LeafMachineInitGUI.fig
%      LEAFMACHINEINITGUI, by itself, creates a new LEAFMACHINEINITGUI or raises the existing
%      singleton*.
%
%      H = LEAFMACHINEINITGUI returns the handle to a new LEAFMACHINEINITGUI or the handle to
%      the existing singleton*.
%
%      LEAFMACHINEINITGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in LEAFMACHINEINITGUI.M with the given input arguments.
%
%      LEAFMACHINEINITGUI('Property','Value',...) creates a new LEAFMACHINEINITGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before LeafMachineInitGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to LeafMachineInitGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help LeafMachineInitGUI

% Last Modified by GUIDE v2.5 27-Sep-2019 14:45:00

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @LeafMachineInitGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @LeafMachineInitGUI_OutputFcn, ...
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

% --- Executes just before LeafMachineInitGUI is made visible.
function LeafMachineInitGUI_OpeningFcn(hObject, eventdata, handles, varargin)
    % Choose default command line output for LeafMachineInitGUI
    handles.output = hObject;
    
    handles.placeholder = imread('Img/LMlarge.jpg');
    axes(handles.axes1);
    imshow(handles.placeholder);
    
    % Update handles structure
    guidata(hObject, handles);
end

% --- Outputs from this function are returned to the command line.
function varargout = LeafMachineInitGUI_OutputFcn(hObject, eventdata, handles) 
    handles = guidata(hObject);    
    varargout{1} = handles.output;
    guidata(hObject,handles);
end

% --- Executes on button press in run.
function run_Callback(hObject, eventdata, handles)
    handles = guidata(hObject);
    LeafMachineBatchGUI
    guidata(hObject,handles);
end


% --- Executes on button press in exit.
function exit_Callback(hObject, eventdata, handles)
    closereq
end
