function varargout = LeafMachineBatchGUI(varargin)
    % LEAFMACHINEBATCHGUI MATLAB code for LeafMachineBatchGUI.fig
    % Begin initialization code - DO NOT EDIT
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
                       'gui_Singleton',  gui_Singleton, ...
                       'gui_OpeningFcn', @LeafMachineBatchGUI_OpeningFcn, ...
                       'gui_OutputFcn',  @LeafMachineBatchGUI_OutputFcn, ...
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


% --- Executes just before LeafMachineBatchGUI is made visible.
function LeafMachineBatchGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to LeafMachineBatchGUI (see VARARGIN)

% Choose default command line output for LeafMachineBatchGUI
    handles.output = hObject;
    format short g
    
    % Check GPU status
    try
        gpuDevice;
        handles.GPUstatus = 'TRUE';
        fprintf("*** GPU Available *** \n")
    catch
        handles.GPUstatus = 'FALSE';
        fprintf("*** GPU Not Available *** \n")
    end
    
    % Add to path
    addpath(genpath('Img'));
    addpath(genpath('Leaf_Data'));
    addpath(genpath('Processed_Images'));
    addpath(genpath('Raw_Images'));
    addpath(genpath('Ruler'));
    addpath(genpath('Networks'));
    addpath(genpath('SandboxFunctions'));
    addpath(genpath('Training_Images'));
    
    matlabGPUcheck()
    
    % Load ML Networks
    % SVM
    handles.SVM = load('Networks/SVM/leafID_subset20AdaBoost50splits100learners0810percent.mat');
    handles.SVM = handles.SVM.leafID_subset20AdaBoost50splits100learners0810percent;
    % Slower version of SVM, more options provided in the 'Networks' folder
    % handles.SVM = load('Networks/SVM/leafID_AdaBoost500splits100learners8var0799percent.mat');
    % handles.SVM = handles.SVM.leafID_AdaBoost500splits100learners8var0799percent;

    % SVM for Ruler ID ***non-functional in LM v-2.0
    handles.netSVMruler = load('Networks/SVM/SVM_RulerID_BaggedTrees0906percent.mat');
    handles.netSVMruler = handles.netSVMruler.SVM_RulerID_BaggedTrees0906percent;
    
    % Semantic Segmentation 
    handles.S = load('Networks/deeplabV3Plus_Lexi_dynamicCrop_MWK_network.mat');  
    handles.LeafMachine_SegNet_v1 = handles.S.deeplabV3Plus_Lexi_dynamicCrop_MWK;

    % Load list of plant families
    handles.allPlantFamilies = load('SandboxFunctions/allPlantFamilies.mat');  
    
    % Initialize GUI images and radio buttons
    handles.placeholder = imread('Img/LMlarge.jpg');
    handles.placeholder2 = imread('Img/Batch.jpg');
    axes(handles.axes1);
    imshow(handles.placeholder);
    uibuttongroup5_CreateFcn(hObject, eventdata, handles);
    set(handles.uibuttongroup5,'selectedobject',handles.radiobuttonLocal);
    set(handles.uibuttongroup6,'selectedobject',handles.dwc_high);
    handles.url_col_radio = "NA";
    handles.dirFGFile = "noFilter";
    handles.FGfilter = "noFilter";
    
    guidata(hObject, handles);
end

function varargout = LeafMachineBatchGUI_OutputFcn(hObject,eventdata, handles) 
    handles = guidata(hObject);
    varargout{1} = handles.output;
    guidata(hObject, handles);
end

function changeBatchOpen_Callback(hObject,~,~)
    handles = guidata(hObject); 
    try
        % Choose folder location
        [handles.dirOpen] = uigetdir('Choose Folder for Batch Processing');
        addpath(handles.dirOpen)

        % Parse folder name
        fOut = strsplit(handles.dirOpen,'\');
        fOut = fOut(length(fOut));
        handles.dirOpenName = char(fOut(1));

        % Update GUI
        set(handles.openLocationText,'string',strcat('Opening From > ',char(handles.dirOpenName)),'ForegroundColor',[.47 .67 .19]);
        set(handles.changeBatchOpen,'BackgroundColor',[.47 .67 .19]);
        set(handles.fileSaveDisp,'String',"");
    catch
    end
    guidata(hObject, handles);
end

function changeURL_Callback(hObject,~,~)
    handles = guidata(hObject); 
    % Choose file
    [handles.dirURLFileName,handles.dirURLPath] = uigetfile({'*.csv'},'Choose .csv File Containing URLs in a Column');
    addpath(handles.dirURLPath);
    handles.dirURLFile = fullfile(handles.dirURLPath,handles.dirURLFileName);
    handles.dirOpen = handles.dirURLFile;
    
    % Update GUI
    set(handles.urlText,'string',strcat('Opening From > ',char(handles.dirURLFileName)),'ForegroundColor',[.47 .67 .19]);
    set(handles.changeURL,'BackgroundColor',[.47 .67 .19]);
    set(handles.fileSaveDisp,'String',"");
    set(handles.uibuttongroup5,'selectedobject',handles.radiobuttonURL);
    
    guidata(hObject, handles);
end

function changeURL2_Callback(hObject,~,~)
    handles = guidata(hObject);
    [handles.dirURLFileName2,handles.dirURLPath2] = uigetfile({'*.csv'},'Choose .csv File Containing URLs in a Column');
    addpath(handles.dirURLPath2);
    handles.dirURLFile2 = fullfile(handles.dirURLPath2,handles.dirURLFileName2);
    handles.dirOpen2 = handles.dirURLFile2;
    
    % Update GUI
    set(handles.urlText2,'string',strcat('Opening From > ',char(handles.dirURLFileName2)),'ForegroundColor',[.47 .67 .19]);
    set(handles.changeURL2,'BackgroundColor',[.47 .67 .19]);
    set(handles.fileSaveDisp,'String',"");
    set(handles.uibuttongroup5,'selectedobject',handles.radiobuttonURL);
    
    guidata(hObject, handles);
end

% --- Executes on button press in changeBatchSave.
function changeBatchSave_Callback(hObject,~,~)
    handles = guidata(hObject); 
    try
        % Choose folder location
        [handles.dirSave] = uigetdir('Choose Save Location');
        addpath(handles.dirSave)

        % Parse folder name
        fOut = strsplit(handles.dirSave,'\');
        fOut = fOut(length(fOut));
        handles.dirSaveName = char(fOut(1));
        handles.saveSuffix = get(handles.saveFolderSuffix,'String');
        if handles.saveSuffix == ""
            handles.dirSave_wSuffix = handles.dirSave;
        else
            handles.dirSave_wSuffix = fullfile(handles.dirSave,handles.saveSuffix);
        end
        % Savdir to display in console
        handles.dirSaveName_wSuffix = strcat(handles.dirSaveName,' > ',handles.saveSuffix);

        % Update GUI
        set(handles.saveLocationText,'string',strcat('Destination Set > ',char(handles.dirSaveName_wSuffix)),'ForegroundColor',[.47 .67 .19]);
        set(handles.changeBatchSave,'BackgroundColor',[.47 .67 .19]);
    catch 
    end
    guidata(hObject, handles);
end

function inputSaveFreq_Callback(hObject, eventdata, handles)
    handles = guidata(hObject); 
    guidata(hObject, handles);
end
% --- Executes during object creation, after setting all properties.
function inputSaveFreq_CreateFcn(hObject, eventdata, handles)
    handles = guidata(hObject); 
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    guidata(hObject, handles);
end

% --- Executes on button press in checkboxGPU.
function checkboxGPU_Callback(hObject, eventdata, handles)
end

% --- Executes on button press in checkboxLCM.
function checkboxLCM_Callback(hObject, eventdata, handles)
end

% --- Executes on button press in checkboxLS.
function checkboxLS_Callback(hObject, eventdata, handles)
end

% --- Executes on button press in checkboxIND.
function checkboxIND_Callback(hObject, eventdata, handles)
end

%=============================================================
%================== Run Batch Processing ===================== 
%=============================================================
function Run_Callback(hObject,~,~)
    handles = guidata(hObject); 
    RESET = get(handles.Run,'String');
    if RESET == "Run"
        try
            set(handles.uibuttongroup5,'SelectionChangeFcn',@uibuttongroup5_SelectionChangedFcn)
            % Check radiobuttons for local_URL status
            if handles.radiobuttonLocal.Value
                handles.local_url = 'local';
                handles.dirOpen2 = 'NA';
            else
                handles.local_url = 'url';
            end

            set(handles.uibuttongroup6,'SelectionChangeFcn',@uibuttongroup6_SelectionChangedFcn)
            % Check radiobuttons for local_URL status
            if handles.dwc_high.Value
                handles.url_col_radio = "accessURI";
            else
                handles.url_col_radio = "goodQualityAccessURI";
            end


            %%% Filter Group Module
            set(handles.filterGroup,'SelectionChangeFcn',@filterGroup_SelectionChangedFcn)
            % Check radiobuttons for Filter Group
            if isa(handles.dirFGFile,'string')
                handles.FGfilter = "noFilter";
            else
                if handles.FGfamily.Value
                    handles.FGfilter = "family";
                elseif handles.FGgenera.Value
                    handles.FGfilter = "genus";
                elseif handles.FGspecies.Value
                    handles.FGfilter = "species";
                else
                    handles.FGfilter = "noFilter";
                end
            end
            
            % If user did not set open dir prior to run
            if handles.radiobuttonLocal.Value == 0
            else
                if handles.openLocationText.String == "Location not set..."
                    % Choose folder location
                    [handles.dirOpen] = uigetdir('Choose Folder for Batch Processing');
                    addpath(handles.dirOpen)
                    % Parse folder name
                    fOut = strsplit(handles.dirOpen,'\');
                    fOut = fOut(length(fOut));
                    handles.dirOpenName = char(fOut(1));
                    % Update GUI
                    set(handles.openLocationText,'string',strcat('Opening From > ',char(handles.dirOpenName)),'ForegroundColor',[.47 .67 .19]);
                    set(handles.changeBatchOpen,'BackgroundColor',[.47 .67 .19]);
                    guidata(hObject,handles);
                end
            end
            
            
            % If user did not set save dir prior to run
            if handles.saveLocationText.String == "Location not set..."
                % Choose folder location
                [handles.dirSave] = uigetdir('Choose Save Location');
                addpath(handles.dirSave)

                % Parse folder name
                fOut = strsplit(handles.dirSave,'\');
                fOut = fOut(length(fOut));
                handles.dirSaveName = char(fOut(1));
                handles.saveSuffix = get(handles.saveFolderSuffix,'String');
                if handles.saveSuffix == ""
                    handles.dirSave_wSuffix = handles.dirSave;
                else
                    handles.dirSave_wSuffix = fullfile(handles.dirSave,handles.saveSuffix);
                end
                % Savdir to display in console
                handles.dirSaveName_wSuffix = strcat(handles.dirSaveName,'>',handles.saveSuffix);

                % Update GUI
                set(handles.saveLocationText,'string',strcat('Destination Set > ',char(handles.dirSaveName_wSuffix)),'ForegroundColor',[.47 .67 .19]);
                set(handles.changeBatchSave,'BackgroundColor',[.47 .67 .19]);
                guidata(hObject,handles);
            end
            % Check checkboxes for gpu status
            if handles.checkboxGPU.Value
                handles.gpu_cpu = 'gpu';
            else
                handles.gpu_cpu = 'cpu';
            end

            % Check checkboxes for LazySnapping status
            if handles.checkboxLS.Value
                handles.LS = true;
            else
                handles.LS = false;
            end

            % Check checkboxes for saveLeafCandidateMask status
            if handles.checkboxLCM.Value
                handles.LCM = true;
            else
                handles.LCM = false;
            end

            % Check checkboxes for image quality
            if handles.quality.Value
                handles.quality = 'High';
            else
                handles.quality = 'Low';
            end

            % Check checkboxes for image quality
            if handles.checkboxIND.Value
                handles.checkboxIND = true;
            else
                handles.checkboxIND = false;
            end
            
            % Check checkboxes for image quality
            if handles.saveOverlayImages.Value
                handles.saveOverlayImages = "True";
            else
                handles.saveOverlayImages = "False";
            end

            % Check checkboxes for image quality
            if handles.imfillMasksCB.Value
                handles.imfillMasksCB = "True";
            else
                handles.imfillMasksCB = "False";
            end

            % Check checkboxes for image quality
            if handles.imfillMasksCBpartial.Value
                handles.imfillMasksCBpartial = "True";
            else
                handles.imfillMasksCBpartial = "False";
            end

            % Check checkboxes for image quality
            if handles.imfillMasksCBclump.Value
                handles.imfillMasksCBclump = "True";
            else
                handles.imfillMasksCBclump = "False";
            end

            % Get save freq
            defaultSave = 10;
            handles.saveFreq = round(str2double(get(handles.inputSaveFreq,'String')));

            if isempty(handles.saveFreq)
                handles.saveFreq = uint64(defaultSave);
            else
                try 
                    handles.saveFreq = uint64(handles.saveFreq);
                catch
                    handles.saveFreq = uint64(defaultSave);
                end
            end
            

            % Check checkboxes for allFilesSuffix status
            handles.filesSuffix = get(handles.allFilesSuffix,'String');
            handles.url_col = get(handles.urlColumn,'String');

            if isempty(handles.url_col)
                handles.url_col = handles.url_col_radio;       
            end

            %{Leaf,Background,Stem,Text_Black,Fruit_Flower};
            handles.feature = 1;%Leaf
            feature = handles.feature;

            WaitCursor();

            % Run Main Operations!!!
            
            [nFiles,BatchTime] = LeafMachineBatchSegmentation_GUI(handles.dirOpen,handles.dirOpen2,handles.LeafMachine_SegNet_v1,handles.SVM,handles.netSVMruler,...
                                handles.dirFGFile,handles.FGfilter,handles.saveOverlayImages,handles.LCM,handles.LS,handles.checkboxIND,handles.saveFreq,feature,handles.gpu_cpu,...
                                handles.local_url,handles.url_col,handles.imfillMasksCB,handles.imfillMasksCBpartial,handles.imfillMasksCBclump,handles.quality,handles.filesSuffix,handles.dirSave_wSuffix,handles,hObject);             

            ArrowCursor();
            set(handles.fileSaveDisp,'String',strcat(nFiles," Images Processed in ",BatchTime," Seconds"),'ForegroundColor',[0 .45 .74]);
            set(handles.Run,'String',"Reset",'BackgroundColor',[0, 0.4470, 0.7410]);
            guidata(hObject,handles);
        catch ME
            ArrowCursor();
            guidata(hObject,handles);
            ME.getReport
            fprintf("An error occured. Check the Command Window for error codes and try again. \n")
            closereq
            LeafMachineBatchGUI
        end
    elseif RESET == "Reset"
        closereq
        LeafMachineBatchGUI
    end
end



% --- Executes on button press in customSet.
function customSet_Callback(hObject, eventdata, handles)
    handles = guidata(hObject);
    try
        % Choose file
        [handles.dircustomSetFileName,handles.dircustomSetPath] = uigetfile({'*.csv','*.xlsx'},'Select the Custom "occurences.csv" File');
        addpath(handles.dircustomSetPath);
        handles.tableCustomSet = readtable(fullfile(handles.dircustomSetPath,handles.dircustomSetFileName));
    
        % Update GUI
        set(handles.customSet,'BackgroundColor',[.47 .67 .19]);
    catch
        fprintf("An error occurred when reading the 'occurrences.csv' file. \n");
    end
    guidata(hObject,handles);
end
% --- Executes on button press in customSetImages.
function customSetImages_Callback(hObject, eventdata, handles)
    handles = guidata(hObject);
    try
        % Choose file
        [handles.dircustomSetImagesFileName,handles.dircustomSetImagesPath] = uigetfile({'*.csv','*.xlsx'},'Select the Full "images.csv" File');
        addpath(handles.dircustomSetImagesPath);
        handles.tableCustomSetImages = readtable(fullfile(handles.dircustomSetImagesPath,handles.dircustomSetImagesFileName));

        % Update GUI
        set(handles.customSetImages,'BackgroundColor',[.47 .67 .19]);
    catch
        fprintf("An error occurred when reading the 'images.csv' file. \n");
    end
    guidata(hObject,handles);
end

% --- Executes on button press in customOut.
function customOut_Callback(hObject, eventdata, handles)
    handles = guidata(hObject); 
    try
        % Choose folder location
        [handles.dirCustomOut] = uigetdir('Choose Save Location');
        addpath(handles.dirCustomOut)

        % Update GUI
        set(handles.customOut,'BackgroundColor',[.47 .67 .19]);
    catch 
        fprintf("An error occurred setting the output directory. \n");
    end
    guidata(hObject, handles);
end

% --- Executes on button press in customRun.
function customRun_Callback(hObject, eventdata, handles)
    handles = guidata(hObject);
    try
    generateCustomImagesFile(handles.tableCustomSetImages,handles.tableCustomSet,handles.dirCustomOut)
    
    closereq
    LeafMachineBatchGUI
    catch
        fprintf("An error occurred when generating the custom images file, please close this window and try again. \n");
    end
    guidata(hObject,handles);
end

% --- Executes on button press in FGset.
function FGset_Callback(hObject, eventdata, handles)
    handles = guidata(hObject); 
    try
    % Choose file
    [handles.dirFGFileName,handles.dirFGPath] = uigetfile({'*.csv'},'Choose .csv File Containing URLs in a Column');
    addpath(handles.dirFGPath);
    handles.dirFGFile = readtable(fullfile(handles.dirFGPath,handles.dirFGFileName));
    
    % Update GUI
    set(handles.FGset,'BackgroundColor',[.47 .67 .19]);
    catch
        fprintf("An error occurred when reading the filter csv/xlsx file. \n");
    end
    
    guidata(hObject, handles);
end

% --- Executes on button press in saveOverlayImages.
function saveOverlayImages_Callback(hObject, eventdata, handles)
    handles = guidata(hObject);
    guidata(hObject,handles);
end

% --- Executes on button press in Dimages.
function Dimages_Callback(hObject, eventdata, handles)
    handles = guidata(hObject);
    
    try
    % Choose file
    [handles.dirDimages,handles.dirDimagesPath] = uigetfile({'*.csv','*.xlsx'},'Choose images.csv File');
    addpath(handles.dirDimagesPath);
    handles.DimagesFILE = fullfile(handles.dirDimagesPath,handles.dirDimages);
    
    % Update GUI
    set(handles.Dimages,'BackgroundColor',[.47 .67 .19]);
    catch
        fprintf("An error occurred when selecting the 'images.csv' file. \n");
    end
    
    guidata(hObject,handles);
end

% --- Executes on button press in Docc.
function Docc_Callback(hObject, eventdata, handles)
    handles = guidata(hObject);
    
    try
    % Choose file
    [handles.dirDocc,handles.dirDoccPath] = uigetfile({'*.csv','*.xlsx'},'Choose occurrences.csv File');
    addpath(handles.dirDoccPath);
    handles.DoccFILE = fullfile(handles.dirDoccPath,handles.dirDocc);
    
    % Update GUI
    set(handles.Docc,'BackgroundColor',[.47 .67 .19]);
    catch
        fprintf("An error occurred when selecting the 'occurrences.csv' file. \n");
    end
    
    guidata(hObject,handles);
end

% --- Executes on button press in Dout.
function Dout_Callback(hObject, eventdata, handles)
    handles = guidata(hObject);
    
    try
        % Choose folder location
        [handles.dirDOut] = uigetdir('Choose Save Location');
        addpath(handles.dirDOut)

        % Update GUI
        set(handles.Dout,'BackgroundColor',[.47 .67 .19]);
    catch 
        fprintf("An error occurred setting the output directory. \n");
    end
    
    guidata(hObject,handles);
end

% --- Executes on button press in Drun.
function Drun_Callback(hObject, eventdata, handles)
    handles = guidata(hObject);
    
    %%% Resolution Group Module
    set(handles.resPick,'SelectionChangeFcn',@resPick_SelectionChangedFcn)
    % Check radiobuttons for resPick
    handles.res = "BOTH";
    if handles.resFull.Value
        handles.res = "HIGH";
    elseif handles.resLow.Value
        handles.res = "LOW";
    elseif handles.resBoth.Value
        handles.res = "BOTH";
    end
    
    try
        GUIdownloadDwCimages(handles.DimagesFILE,handles.DoccFILE,handles.dirDOut,handles.res)
    catch
        fprintf("An error occurred with the GUIdownloadDwCimages function. \n");
    end
    guidata(hObject,handles);
end

function Stop_Callback(hObject, eventdata, handles)
    closereq
end

function saveFolderSuffix_Callback(hObject, eventdata, handles)
    handles = guidata(hObject);
    guidata(hObject,handles);
end

function saveFolderSuffix_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end

function allFilesSuffix_Callback(hObject, eventdata, handles)
    handles = guidata(hObject);
    guidata(hObject,handles);
end

function allFilesSuffix_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end

function urlColumn_Callback(hObject, eventdata, handles)
    handles = guidata(hObject);
    guidata(hObject,handles);
end

% --- Executes on button press in imfillMasksCB.
function imfillMasksCB_Callback(hObject, eventdata, handles)
    handles = guidata(hObject);
    guidata(hObject,handles);
end

% --- Executes on button press in imfillMasksCBpartial.
function imfillMasksCBpartial_Callback(hObject, eventdata, handles)
    handles = guidata(hObject);
    guidata(hObject,handles);
end

% --- Executes on button press in imfillMasksCBclump.
function imfillMasksCBclump_Callback(hObject, eventdata, handles)
    handles = guidata(hObject);
    guidata(hObject,handles);
end

function urlColumn_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end

% --- Executes during object creation, after setting all properties.
function uibuttongroup5_CreateFcn(hObject, eventdata, handles)
    handles = guidata(hObject);
    guidata(hObject,handles);
end
% --- Executes when selected object is changed in uibuttongroup5.
function uibuttongroup5_SelectionChangedFcn(hObject, eventdata, handles)
    handles = guidata(hObject);
    
    set(handles.uibuttongroup5,'SelectionChangeFcn',@uibuttongroup5_SelectionChangedFcn)
    switch(get(eventdata.NewValue,'Tag'))
        case 'Local'
            handles.radiobuttonLocal = 0.1;
        case 'URL'
            handles.radiobuttonURL = 1;
    end
    
    guidata(hObject,handles);matlab default background color
end

% --- Executes during object creation, after setting all properties.
function uibuttongroup6_CreateFcn(hObject, eventdata, handles)
    handles = guidata(hObject);
    guidata(hObject,handles);
end
% --- Executes when selected object is changed in uibuttongroup6.
function uibuttongroup6_SelectionChangedFcn(hObject, eventdata, handles)
    handles = guidata(hObject);
    
    set(handles.uibuttongroup6,'SelectionChangeFcn',@uibuttongroup6_SelectionChangedFcn)
    switch(get(eventdata.NewValue,'Tag'))
        case 'dwc_high'
            handles.url_col_radio = "goodQualityAccessURI";
        case 'dwc_low'
            handles.url_col_radio = "accessURI";
    end
    guidata(hObject,handles);
end

% --- Executes when selected object is changed in filterGroup.
function filterGroup_SelectionChangedFcn(hObject, eventdata, handles)
    handles = guidata(hObject);
    
    set(handles.filterGroup,'SelectionChangeFcn',@filterGroup_SelectionChangedFcn)
    switch(get(eventdata.NewValue,'Tag'))
        case 'FGfamily'
            handles.FGfilter = "family";
        case 'FGgenera'
            handles.FGfilter = "genera";
        case 'FGspecies'
            handles.FGfilter = "species";
    end
    guidata(hObject,handles);
end

% --- Executes when selected object is changed in filterGroup.
function resPick_SelectionChangedFcn(hObject, eventdata, handles)
    handles = guidata(hObject);
    
    set(handles.resPick,'SelectionChangeFcn',@resPick_SelectionChangedFcn)
    switch(get(eventdata.NewValue,'Tag'))
        case 'resFull'
            handles.res = "HIGH";
        case 'resLow'
            handles.res = "LOW";
        case 'resBoth'
            handles.res = "BOTH";
    end
    guidata(hObject,handles);
end

% --- Executes on button press in quality.
function quality_Callback(hObject, eventdata, handles)
    handles = guidata(hObject);
    guidata(hObject,handles);
end




%<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
%>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
%-------------------- Non-GUI Functions ----------------------
%<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
%>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
function WaitCursor()
    set(gcf, 'pointer', 'watch') 
    drawnow;
end

function ArrowCursor()
    set(gcf, 'pointer', 'arrow')
    drawnow;
end


%=============================================================
%====== For resolving directory conflicts with gtruth ========
%=============================================================
% handles.workspace = load('Networks\LeafMachine_SegNet.mat');
% 
% kspace = load('Networks\LeafMachine_SegNet.mat');
% oldPathDataSource  = "D:\Will Files\Dropbox\ML_Project\Image_Database\Training_Images";
% newPathDataSource  = fullfile(pwd,"Networks\Training_Images");
% 
% oldPathPixelLabel = "D:\Will Files\Dropbox\ML_Project\Image_Database\GroundTruth\PixelLabelData_11";
% newPathPixelLabel = fullfile(pwd,"Networks\PixelLabelData_11");
% 
% alterPaths = {[oldPathDataSource newPathDataSource];[oldPathPixelLabel newPathPixelLabel]};
% unresolvedPaths = changeFilePaths(kspace.gTruth,alterPaths)



