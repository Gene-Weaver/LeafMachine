%% Personal Notes
%%%%% use class object to store data
% methods for functions
% properties to store data
%%%%% seperate class to store individual leaves 
% store all leaves in matrix 

% add catch for having correct organizational directories

%% Operational Notes
% The 'Create Mask' requirement is used to make sure old data is not
% partially used to save new data. For example, if the user saved data for
% leaf1 and partially measures leaf2, old data like the previous make may
% be residually present in the GUI data storage system. The requirement
% ensures that SaveLeafData cannot be pressed while data is in a partially
% updated state.

%% GUI Code
function varargout = GUI_Auto_Distance(varargin)
% GUI_AUTO_DISTANCE MATLAB code for GUI_Auto_Distance.fig
%      GUI_AUTO_DISTANCE, by itself, creates a new GUI_AUTO_DISTANCE or raises the existing
%      singleton*.
%
%      H = GUI_AUTO_DISTANCE returns the handle to a new GUI_AUTO_DISTANCE or the handle to
%      the existing singleton*.
%
%      GUI_AUTO_DISTANCE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI_AUTO_DISTANCE.M with the given input arguments.
%
%      GUI_AUTO_DISTANCE('Property','Value',...) creates a new GUI_AUTO_DISTANCE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GUI_Auto_Distance_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GUI_Auto_Distance_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GUI_Auto_Distance

% Last Modified by GUIDE v2.5 02-Oct-2017 00:21:06

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GUI_Auto_Distance_OpeningFcn, ...
                   'gui_OutputFcn',  @GUI_Auto_Distance_OutputFcn, ...
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

% --- Executes just before GUI_Auto_Distance is made visible.
function GUI_Auto_Distance_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;
format short g
handles.placeholder = imread('Img/StartLeaf.jpg');
handles.placeholder2 = imread('Img/StartRuler.jpg');
handles.placeholder3 = imread('Img/StartDiagram.jpg');
handles.Ruler = handles.placeholder2;
axes(handles.axes1);
imshow(handles.placeholder);
axes(handles.axes2);
imshow(handles.placeholder2);
axes(handles.axes3);
imshow(handles.placeholder3);
uibuttongroup1_CreateFcn(hObject, eventdata, handles);

set(handles.uibuttongroup1,'selectedobject',handles.Metric1cm);

handles.Metric1mm = .1;
handles.Metric1cm = 1;
handles.Metric10cm = 10;

handles.SCALE = handles.Metric1cm;
guidata(hObject, handles);
end

% --- Executes during object creation, after setting all properties.
function uibuttongroup1_CreateFcn(hObject, eventdata, handles)
handles = guidata(hObject);
guidata(hObject,handles);
end

% --- Outputs from this function are returned to the command line.
function varargout = GUI_Auto_Distance_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;
end

% --- Executes when selected object is changed in uibuttongroup1.
function uibuttongroup1_SelectionChangedFcn(hObject, eventdata, handles)
handles = guidata(hObject);
set(handles.uibuttongroup1,'SelectionChangeFcn',@uibuttongroup1_SelectionChangedFcn)
switch(get(eventdata.NewValue,'Tag'))
    case 'Metric1mm'
        handles.SCALE = 0.1;
    case 'Metric1cm'
        handles.SCALE = 1;
    case 'Metric10cm'
        handles.SCALE = 10;
end
guidata(hObject,handles);
end

% --- Executes on button press in NextImage.
function NextImage_Callback(hObject, eventdata, handles)
handles = guidata(hObject);
handles.ImageFile = uigetfile({'*.JPG;*.jpg;*.jpeg;*.png'});
handles.RGB = imread(handles.ImageFile);
guidata(hObject,handles);
handles.ImageH = length(handles.RGB(:,1,1));
handles.ImageW = length(handles.RGB(1,:,1));
axes(handles.axes1);
imshow(handles.RGB);

% Restart Leaf index at 1 
handles.LeafIndex = 1;
% Reset pixel distance
handles.DIST = 0;
DIST_disp = round(handles.DIST);
handles.TickMarksFound = 0;

set(handles.TickMarks,'string',sprintf('Tick Marks Identified = %d',handles.TickMarksFound));
set(handles.DisplayDistance,'string',sprintf('Distance = %d pixels',DIST_disp))
set(handles.LeafAreaReport,'string','Leaf Area =');
% Disable Mask tools
set(handles.pushbuttonLeaf,'Enable','off');
set(handles.pushbuttonBackground,'Enable','off');
set(handles.CreateMask,'Enable','off');
set(handles.RedoLeaf,'Enable','off');
set(handles.MeasureManually,'Enable','on');
set(handles.NextImage,'BackgroundColor',[.47 .67 .19]);
axes(handles.axes2);
imshow(handles.Ruler);
axes(handles.axes3);
imshow(handles.placeholder3);

% Update UI data
guidata(hObject,handles);
end

% --- Executes on button press in MeasureDistance.
function MeasureDistance_Callback(hObject, eventdata, handles)
handles = guidata(hObject);
% Loading icon setup
set(gcf, 'pointer', 'arrow') 
oldpointer = get(gcf, 'pointer'); 
set(gcf, 'pointer', 'watch') 
drawnow;
% Get most recent radiobutton choice
set(handles.uibuttongroup1,'SelectionChangeFcn',@uibuttongroup1_SelectionChangedFcn)
% Find and Measure Ruler
sceneImageRGB = handles.RGB;
sceneImage = rgb2gray(sceneImageRGB);
boxImageRGB = handles.Ruler;
boxImage = rgb2gray(boxImageRGB);

boxPoints = detectHarrisFeatures(boxImage);
scenePoints = detectHarrisFeatures(sceneImage);
%boxPoints = detectSURFFeatures(boxImage);
%scenePoints = detectSURFFeatures(sceneImage);%66.9
%boxPoints = detectHarrisFeatures(boxImage,'MinQuality', 0.001);
%scenePoints = detectHarrisFeatures(sceneImage,'MinQuality', 0.001);%

[boxFeatures, boxPoints] = extractFeatures(boxImage, boxPoints);
[sceneFeatures, scenePoints] = extractFeatures(sceneImage, scenePoints);
%%%
axes(handles.axes2)
imshow(handles.Ruler)
hold on
plot(boxPoints);
hold off
axes(handles.axes1)
%try 
    %%% 
    % Match features between ruler and image
    boxPairs = matchFeatures(boxFeatures, sceneFeatures);
    matchedBoxPoints = boxPoints(boxPairs(:, 1), :);
    matchedScenePoints = scenePoints(boxPairs(:, 2), :);
    [tform, inlierBoxPoints, inlierScenePoints] = estimateGeometricTransform(matchedBoxPoints, matchedScenePoints, 'affine');
    
    % Create boundary around ruler based on matched features
    boxPolygon = [1, 1;...                           % top-left
            size(boxImage, 2), 1;...                 % top-right
            size(boxImage, 2), size(boxImage, 1);... % bottom-right
            1, size(boxImage, 1);...                 % bottom-left
            1, 1];                   % top-left again to close the polygon
    newBoxPolygon = transformPointsForward(tform, boxPolygon);
%     figure(1);
%     imshow(sceneImage);
%     hold on;
%     line(newBoxPolygon(:, 1), newBoxPolygon(:, 2), 'Color', 'g');

    % Find matched points within the polygon
    ScenePointsX = scenePoints.Location(:,1);
    ScenePointsY = scenePoints.Location(:,2);
    [in,on] = inpolygon(ScenePointsX,ScenePointsY,newBoxPolygon(:,1),newBoxPolygon(:,2));
    PointsInPoly = [ScenePointsX(in),ScenePointsY(in)];
    PointsOutPoly = [ScenePointsX(~in),ScenePointsY(~in)];
%     scatter(PointsInPoly(:,1),PointsInPoly(:,2),'g','.') % all points inside ruler boundary
%     scatter(PointsOutPoly(:,1),PointsOutPoly(:,2),'r','.')
%    hold off
    %%% End of selecting points around ruler
    
    %%% Find tick marks and convert pixel distance to 1 cm. 
    % *** 1st distance calculation ***
    % Get scenepoints from above
    Location = PointsInPoly;
    % Create zeros vector to store data
    MinDist = zeros(length(Location)-1,1);
    for i = 1:length(Location)
        LocationTemp = Location;
        Start = Location(i,:);
        LocationTemp(i,:) = [];
        % Euclidean distance between points
        distances = sqrt(sum(bsxfun(@minus, LocationTemp, Start).^2,2));
        MinDist(i,1) = min(distances);
    end
    % Create temporary vector
    MinDistTemp = MinDist;
    % Remove zero distances
    MinDist(MinDist(:,1)==0)=[];
    % Show density plot 
    %axes(handles.axes3)
    %ksdensity(MinDist);
    [peakDensity,xi] = ksdensity(MinDist);
    [maxDensity,peakIndex] = max(peakDensity);
    % PeakLocation is the uncorrected pixel distance equal to 1mm
    peakLocation = xi(peakIndex);
    % All points within 10% of the peak density location
    PeakPoints = MinDistTemp((MinDistTemp(:,1)>=(.8*peakLocation)) & (MinDistTemp(:,1)<=(1.2*peakLocation)));
    
    
    % *** Use the peak density info to recalculate the distances to realign
    % the correct tickmarks
    % PeakPointsLocation stores the coordinates of scenematching features
    % that fall within 10% of the peak density value
    PeakPointsLocation = zeros(length(Location)-1,2);
    for i = 1:length(Location)
        LocationTemp = Location;
        Start = Location(i,:);
        LocationTemp(i,:) = [];
        % Euclidean distance between points
        distances = sqrt(sum(bsxfun(@minus, LocationTemp, Start).^2,2));
        PeakMin = min(distances);
        if ((PeakMin >=(.9*peakLocation)) & (PeakMin<=(1.1*peakLocation)))
            PeakPointsLocation(i,:) = Start;
        else
            PeakPointsLocation(i,:) = 0; % make rows 0 if it is not within the range
        end
    end
    % Remove zero rows
    PeakPointsLocation(~any(PeakPointsLocation,2), : ) = [];
    
    
    % *** Normalize the points by mapping to a line of best fit ***
    % Determine ruler orientation
    RulerXRange = range(PointsInPoly(:,1));
    RulerYRange = range(PointsInPoly(:,2));
    if RulerXRange > RulerYRange
        % Ruler is horrizontal in image
        NormalizeX = polyfit(PeakPointsLocation(:,1),PeakPointsLocation(:,2),1);
        ApproxX = polyval(NormalizeX,PeakPointsLocation(:,1));
        CorrectedPoints = [PeakPointsLocation(:,1),ApproxX];
        
        
    else
        % Ruler is vertical in image
        NormalizeX = polyfit(PeakPointsLocation(:,2),PeakPointsLocation(:,1),1);
        ApproxX = polyval(NormalizeX,PeakPointsLocation(:,2));
        CorrectedPoints = [ApproxX,PeakPointsLocation(:,2)];
    end
    % Plot validation
%     figure(10);
%     imshow(sceneImage);
%     hold on;
%     line(PeakPointsLocation(:,2),ApproxX)
%     scatter(PeakPointsLocation(:,1),PeakPointsLocation(:,2),'.','g')
    %plot(ApproxX,PeakPointsLocation(:,2))
    %hold on
    %scatter(PeakPointsLocation(:,1),PeakPointsLocation(:,2))
    CorrectedMinDist = zeros(length(CorrectedPoints)-1,1);
    CorrectedPointsTrimmed = zeros(length(CorrectedPoints)-1,2);
    for i = 1:length(CorrectedPoints)
        LocationTemp = CorrectedPoints;
        Start = CorrectedPoints(i,:);
        LocationTemp(i,:) = [];
        % Euclidean distance between points
        distances = sqrt(sum(bsxfun(@minus, LocationTemp, Start).^2,2));
        
        % Row index of nearest point to Start
        k = dsearchn(LocationTemp,Start);
        % Coordinates of nearest point to Start
        ClosePoint = LocationTemp(k,:);
        % Take min distance
        CorrectedMinDist(i,1) = min(distances);
        if ((CorrectedMinDist(i,1)>=(.9*peakLocation)) && (CorrectedMinDist(i,1)<=(1.1*peakLocation)))
            CorrectedPointsTrimmed(i,:) = Start;
        elseif (CorrectedMinDist(i,1)<0.3)
            AvgPoint = [(Start(1,1)+ClosePoint(1,1))/2, (Start(1,2)+ClosePoint(1,2))/2];
            CorrectedPointsTrimmed(i,:) = AvgPoint;
        end
    end
    % Remove zero rows
    CorrectedPointsTrimmed( all(~CorrectedPointsTrimmed,2), : ) = [];
    % Remove Duplicates
    [~,index]=unique(CorrectedPointsTrimmed,'rows');
    CorrectedPointsTrimmed =  CorrectedPointsTrimmed(index,:);
    % Number of tickmarks identified
    handles.TickMarksFound = length(CorrectedPointsTrimmed(:,1));
    % Plot features for console
    axes(handles.axes1)
    imshow(handles.RGB)
    hold on
    scatter(CorrectedPoints(:,1),CorrectedPoints(:,2),'r','filled')
    scatter(CorrectedPointsTrimmed(:,1),CorrectedPointsTrimmed(:,2),'g','filled')
    line(newBoxPolygon(:, 1), newBoxPolygon(:, 2), 'Color', 'g')
    scatter(PointsOutPoly(:,1),PointsOutPoly(:,2),'r','.') 
    hold off
    %axes(handles.axes1)
    
    % Plot features for export
    h = figure;
    set(h, 'Visible', 'off');
    imshow(handles.RGB)
    hold on
    scatter(CorrectedPoints(:,1),CorrectedPoints(:,2),'r','filled')
    scatter(CorrectedPointsTrimmed(:,1),CorrectedPointsTrimmed(:,2),'g','filled')
    line(newBoxPolygon(:, 1), newBoxPolygon(:, 2), 'Color', 'g')
    scatter(PointsOutPoly(:,1),PointsOutPoly(:,2),'r','.') 
    hold off
    handles.Features = h;
    
    CorrectedMinDist1 = CorrectedMinDist;
    % Keep only distances that are within 40% of the original minimum
    % distances to avoid polyfit scewing 
    CorrectedMinDist1 = CorrectedMinDist1((CorrectedMinDist1(:,1)>=(.9*peakLocation)) & (CorrectedMinDist1(:,1)<=(1.1*peakLocation)));
    if isempty(CorrectedMinDist1)
        CorrectedMinDist = harmmean(CorrectedMinDist);
    else
        % Error Catch
        CorrectedMinDist = CorrectedMinDist1;
    end
    axes(handles.axes3)
    [peakDensityC,xiC] = ksdensity(CorrectedMinDist);
    plot(10*xi,peakDensity,10*xiC,peakDensityC)
    lgd = legend('Raw','Corrected');
    title(lgd, 'Metric Identification')
    xlabel('Pixel Distance (1cm)')
    ylabel('Frequency')
    %[peakDensity,xi] = ksdensity(MinDist);
    % PeakLocation is the uncorrected pixel distance equal to 1mm
    CorrectedPeakLocation = harmmean(CorrectedMinDist);
    
    axes(handles.axes1)
    % Save pixel distance for later conversion
    CorrectedPeakLocation1cm = 10*CorrectedPeakLocation;
    handles.DIST = CorrectedPeakLocation1cm;

    % Round for GUI formatting
    DIST = handles.DIST;
    DIST_disp = round(handles.DIST,3);
    set(handles.TickMarks,'string',sprintf('Tick Marks Identified = %d',handles.TickMarksFound));
    set(handles.DisplayDistance,'string',sprintf('Distance = %.6g pixels',DIST_disp))
    % Enable Mask tools
    set(handles.pushbuttonLeaf,'Enable','on');
    set(handles.pushbuttonBackground,'Enable','on');
    set(handles.CreateMask,'Enable','on');
    set(handles.RedoLeaf,'Enable','on');
% catch
%     % Construct a questdlg with three options
%     choice = questdlg('A compatible ruler could not be located in the chosen image.', ...
%         'Metric Conversion Failed', ...
%         'Load alternate ruler','Continue','Continue');
%     % Handle response
%     switch choice
%         case 'Load alternate ruler'
%             handles.ImageRulerFile = uigetfile({'*.JPG;*.jpg;*.jpeg;*.png'});
%             handles.Ruler = imread(handles.ImageRulerFile);
%             guidata(hObject,handles);
%             axes(handles.axes2);
%             height = length(handles.Ruler(:,1,1));
%             width = length(handles.Ruler(1,:,1));
%             if height > width
%                 handles.RulerDisp = imrotate(handles.Ruler,90);
%                 guidata(hObject,handles);
%                 imshow(handles.RulerDisp);
%             else
%                 imshow(handles.Ruler);
%             end
%             axes(handles.axes1)
%             MeasureDistance_Callback(hObject, eventdata, handles)
%         case 'Continue'
%             set(handles.LoadRuler,'BackgroundColor',[1 0 0]);
%     end
% end
% Loading icon end
set(gcf, 'pointer', oldpointer)
% Update UI data
guidata(hObject,handles);
end

% --- Executes on button press in MeasureManually.
function MeasureManually_Callback(hObject, eventdata, handles)
% hObject    handle to MeasureManually (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = guidata(hObject);

h = imdistline(gca);
% Get Scale ... the cm. distance
pause('on');
pause;
api = iptgetapi(h);
% Save pixel distance for later conversion
handles.DIST = api.getDistance();
% Round for GUI formatting
DIST = handles.DIST;
DIST_disp = round(handles.DIST);
set(handles.DisplayDistance,'string',sprintf('Distance = %d pixels',DIST_disp));
% Enable Mask tools
set(handles.pushbuttonLeaf,'Enable','on');
set(handles.pushbuttonBackground,'Enable','on');
set(handles.CreateMask,'Enable','on');
set(handles.RedoLeaf,'Enable','on');

%g = findobj('Tag','MeasureDistance'); % get rid of
%set(g.UserData,DIST); % get rid of
% Update UI data
guidata(hObject,handles);
end


% --- Executes during object creation, after setting all properties.
function DistanceCM_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


% Use normal button clicks to add points. 
% A shift-, right-, or double-click adds a final point and ends the selection. 
% Pressing Return or Enter ends the selection without adding a final point. 
% Pressing Backspace or Delete removes the previously selected point.

% --- Executes on button press in pushbuttonLeaf.
function pushbuttonLeaf_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonLeaf (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = guidata(hObject);
% Update Guide
set(handles.GUIDE,'string','Use normal button clicks to add points. A shift-, right-, or double-click adds a final point and ends the selection. Pressing Return or Enter ends the selection without adding a final point. Pressing Backspace or Delete removes the previously selected point.')
%Foreground - Select leaf
axes(handles.axes1);
imshow(handles.RGB);
[FOREGROUNDx, FOREGROUNDy] = getpts();
axes(handles.axes1);
guidata(hObject,handles);
imshow(handles.RGB);
h1 = impoly(gca,[round(FOREGROUNDx),round(FOREGROUNDy)],'Closed',false);
foresub = getPosition(h1);
handles.LEAF_INDICES = foresub;
foregroundInd = sub2ind(size(handles.RGB),foresub(:,2),foresub(:,1));
handles.foregroundInd = foregroundInd;
handles.foregroundInd_disp = strjoin(string(foregroundInd),' ');
strjoin(string(foregroundInd),',');
% Update UI data
guidata(hObject,handles);
end

% --- Executes on button press in pushbuttonBackground.
function pushbuttonBackground_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonBackground (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = guidata(hObject);
%imshow(handles.RGB);
[BACKGROUNDx, BACKGROUNDy] = getpts();
h2 = impoly(gca,[round(BACKGROUNDx), round(BACKGROUNDy)],'Closed',false);
backsub = getPosition(h2);
backgroundInd = sub2ind(size(handles.RGB),backsub(:,2),backsub(:,1));
handles.backgroundInd = backgroundInd;
handles.backgroundInd_disp = strjoin(string(backgroundInd),' ');
strjoin(string(backgroundInd),',');
% Update UI data
guidata(hObject,handles);
end

% --- Executes on button press in CreateMask.
function CreateMask_Callback(hObject, eventdata, handles)
handles = guidata(hObject);
% Loading icon setup
set(gcf, 'pointer', 'arrow') 
oldpointer = get(gcf, 'pointer'); 
set(gcf, 'pointer', 'watch') 
drawnow;
% Superpixels function for lazy snapping
SP = superpixels(handles.RGB,500);
BW = lazysnapping(handles.RGB,SP,handles.foregroundInd,handles.backgroundInd,...
    'EdgeWeightScaleFactor',750);%10-1000 default 500, usually 750 is best
% Create binary mask
maskedImage = handles.RGB;
maskedImage(repmat(~BW,[1 1 3])) = 0;
axes(handles.axes1);
imshow(maskedImage)
BINARY = im2bw(maskedImage,.1);
% Only show 5 largest objects
BINARY_OBJECT = bwareafilt(BINARY,5);
% Calculate the area of the leaf selected in step 2
%       if area of different leaf is desired, remove
%       ",handles.LEAF_INDICES(:,1),handles.LEAF_INDICES(:,2)"
AREA_IMAGE = bwselect(BINARY_OBJECT,handles.LEAF_INDICES(:,1),handles.LEAF_INDICES(:,2),4);
handles.Binary = AREA_IMAGE;
AREA = bwarea(AREA_IMAGE);
PERIMETER_P = struct2array(regionprops(AREA_IMAGE,'Perimeter'));
PERIMETER = round(PERIMETER_P/(handles.DIST/handles.SCALE),3);
handles.Perimeter = PERIMETER;
% Convert pixel area to cm^2
handles.AREA_cm = (1/(handles.DIST/handles.SCALE)^2)*AREA;
handles.AREA_cm_report = round(handles.AREA_cm,3); % Use this for exact area, rounded to 3 decimal points
% Show side-by-side comparison of original/mask
% Insert area on top of selected leaf
position = [mean(handles.LEAF_INDICES(:,1)),mean(handles.LEAF_INDICES(:,2))];
handles.RGBpair = imfuse(handles.RGB,AREA_IMAGE);
LeafID = strcat('A',num2str(handles.LeafIndex),'-',num2str(handles.AREA_cm_report));
PeriID = strcat('P',num2str(handles.LeafIndex),'-',num2str(handles.Perimeter));
TotalID = [LeafID,' ',PeriID];
handles.RGBinsert = insertText(handles.RGBpair,position,TotalID,'FontSize',60,'BoxColor',...
    'white','BoxOpacity',0.5,'TextColor','black','AnchorPoint','Center');
axes(handles.axes1);
imshow(handles.RGBinsert)
% Report Leaf Area
formatSpec = 'Leaf Area = %.3f cm^2';
AreaText = sprintf(formatSpec,handles.AREA_cm_report);
%handles.AREA_cm_report
set(handles.LeafAreaReport,'string',AreaText);
set(handles.SaveLeafArea,'Enable','on');
% Loading icon end
set(gcf, 'pointer', oldpointer)
% Update UI data
guidata(hObject,handles);
end


% --- Executes on button press in Quit.
function Quit_Callback(hObject, eventdata, handles)
close(GUI_Auto_Distance)
% run(path-to-gui2) % option to open a box 'are you sure you want to exit?'
end


% --- Executes on button press in SaveLeafArea.
function SaveLeafArea_Callback(hObject, eventdata, handles)
% hObject    handle to SaveLeafArea (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = guidata(hObject);
% Loading icon setup
set(gcf, 'pointer', 'arrow') 
oldpointer = get(gcf, 'pointer'); 
set(gcf, 'pointer', 'watch') 
drawnow;
%try 
    % Load previous data
    FILENAME = handles.BaseFilename;
    % Convert to cell array
    OriginalCSV = table2cell(handles.OriginalCSV);
    % Get time
    t = datestr(datetime('now','TimeZone','local','Format','d-MMM-y HH:mm:ss'));
    % New filename
    handles.NEWFILENAME = strcat('Leaf_Data/',FILENAME,'-',t,'.xlsx');
    % Add data to cell array, will be new row in data table
    N={handles.ImageFile,handles.ImageRulerFile,'species name',handles.LeafIndex,...
        handles.AREA_cm_report,handles.Perimeter,handles.DIST,handles.TickMarksFound,...
        t,handles.foregroundInd_disp,handles.backgroundInd_disp};
    % Convert back to table
    NewData = cell2table([OriginalCSV;N]);
    % Give the new table the same headers as previous table
    NewData.Properties.VariableNames = handles.CSVVariableNames;
    NewData
    % Save newdata table to hobject
    handles.OriginalCSV = NewData;
    %handles.NewData = [handles.OriginalCSV;NewData];



    %%% for writing data, each leaf % *** old method
    % Write the table to a new .xlsx file
    %writetable(NewData,NEWFILENAME);
    % *** Set the original file to be the newly created file, this keeps the
    % program from overwriting data ***
    %handles.OriginalCSV = readtable(NEWFILENAME);
    %%%

    % Save png comparison
    ImageFileParsed = strsplit(handles.ImageFile,'.');
    ImageFileParsed = char(ImageFileParsed(1,1));
    CompareJPEGFilename = strcat('Processed_Images/Summary_Images/',ImageFileParsed,'_Compare_','L',num2str(handles.LeafIndex),'_',t,'.png');
    % Remove misc. characters that cannot be in windows filenames
    CompareJPEGFilename = strrep(CompareJPEGFilename,'[','');
    CompareJPEGFilename = strrep(CompareJPEGFilename,']','');
    CompareJPEGFilename = strrep(CompareJPEGFilename,':','-');
    CompareJPEGFilename = strrep(CompareJPEGFilename,'','_');
    CompareJPEGFilename = strrep(CompareJPEGFilename,' ','_');
    imwrite(handles.RGBinsert,CompareJPEGFilename);
    % Save binary as png
    BinaryPNGFilename = strcat('Processed_Images/Binary_Masks/',ImageFileParsed,'_Binary_','L',num2str(handles.LeafIndex),'_',t,'.png');
    BinaryPNGFilename = strrep(BinaryPNGFilename,'[','');
    BinaryPNGFilename = strrep(BinaryPNGFilename,']','');
    BinaryPNGFilename = strrep(BinaryPNGFilename,':','-');
    BinaryPNGFilename = strrep(BinaryPNGFilename,'','_');
    BinaryPNGFilename = strrep(BinaryPNGFilename,' ','_');
    imwrite(handles.Binary,BinaryPNGFilename);
    % Save Matched Features as png
    MFPNGFilename = strcat('Processed_Images/Matched_Features/',ImageFileParsed,'_MatchedFeatures_','L',num2str(handles.LeafIndex),'_',t,'.png');
    MFPNGFilename = strrep(MFPNGFilename,'[','');
    MFPNGFilename = strrep(MFPNGFilename,']','');
    MFPNGFilename = strrep(MFPNGFilename,':','-');
    MFPNGFilename = strrep(MFPNGFilename,'','_');
    MFPNGFilename = strrep(MFPNGFilename,' ','_');
    print(handles.Features,'-dpng','-r400',MFPNGFilename)

    % Increase image leaf index by one for keeping track of multiple leaf
    % measurements from the same image
    handles.LeafIndex = handles.LeafIndex + 1;
    % Update the save destination in the GUI
    set(handles.FileSaveDisp,'string',strcat('Destination Set > ',char(handles.NEWFILENAME)),'ForegroundColor',[.47 .67 .19]);
    set(handles.SaveLeafArea,'Enable','off');
    set(handles.ExportSessionData,'Enable','on');
    set(handles.LeafAreaReport,'string','Leaf Area =');
% catch 
%     handles = guidata(hObject);
%     choice = questdlg('Select an export file.', ...
%         'Export Destination Not Set', ...
%         'Continue','Continue');
%     % Handle response
%     switch choice
%         case 'Continue'
%     end
%     guidata(hObject,handles);
% end
% Loading icon end
set(gcf, 'pointer', oldpointer)
guidata(hObject,handles);
end


% --- Executes on button press in OpenCSV.
function OpenCSV_Callback(hObject, eventdata, handles)
% hObject    handle to OpenCSV (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%OpenImage
handles = guidata(hObject);
% Have user open latest data file
FILE = uigetfile('*.xlsx');
% Parse filename
[NA,FILENAME]=fileparts(FILE);
FILENAMEsplit = strsplit(FILENAME,'-');
% Select Base filename so new time stamp can be added
handles.BaseFilename = char(FILENAMEsplit(1,1));
% read in data
handles.OriginalCSV = readtable(FILE);
% Define variable names i.e. column names
handles.CSVVariableNames = handles.OriginalCSV.Properties.VariableNames;
% Update GUI
set(handles.FileSaveDisp,'string',strcat('Destination Set > ',char(FILENAME)),'ForegroundColor',[.47 .67 .19]);
set(handles.OpenCSV,'BackgroundColor',[.47 .67 .19]);

guidata(hObject,handles);
end


% --- Executes on button press in ExportSessionData.
function ExportSessionData_Callback(hObject, eventdata, handles)
% hObject    handle to ExportSessionData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = guidata(hObject);
% Loading icon setup
set(gcf, 'pointer', 'arrow') 
oldpointer = get(gcf, 'pointer'); 
set(gcf, 'pointer', 'watch') 
drawnow;
% Remove problematic chars
handles.NEWFILENAME = strrep(handles.NEWFILENAME,'[','');
handles.NEWFILENAME = strrep(handles.NEWFILENAME,']','');
handles.NEWFILENAME = strrep(handles.NEWFILENAME,':','-');
handles.NEWFILENAME = strrep(handles.NEWFILENAME,'','_');
writetable(handles.OriginalCSV,handles.NEWFILENAME);
fileattrib(handles.NEWFILENAME, '+w')
set(handles.ExportSessionData,'Enable','off');

% Loading icon end
set(gcf, 'pointer', oldpointer)
guidata(hObject,handles);
end


% --- Executes on button press in RedoLeaf.
function RedoLeaf_Callback(hObject, eventdata, handles)
% hObject    handle to RedoLeaf (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = guidata(hObject);
set(handles.SaveLeafArea,'Enable','off');
axes(handles.axes1);
imshow(handles.RGB);
guidata(hObject,handles);
end


% --- Executes on button press in LoadRuler.
function LoadRuler_Callback(hObject, eventdata, handles)
% hObject    handle to LoadRuler (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = guidata(hObject);

handles.ImageRulerFile = uigetfile({'*.JPG;*.jpg;*.jpeg;*.png'});
handles.Ruler = imread(handles.ImageRulerFile);

set(handles.MeasureDistance,'Enable','on');
set(handles.LoadRuler,'BackgroundColor',[.47 .67 .19]);

axes(handles.axes2);
handles.RulerHeight = length(handles.Ruler(:,1,1));
handles.RulerWidth = length(handles.Ruler(1,:,1));
if handles.RulerHeight > handles.RulerWidth
    handles.Ruler = imrotate(handles.Ruler,90);
    guidata(hObject,handles);
    imshow(handles.Ruler);
else
    imshow(handles.Ruler);
end
guidata(hObject,handles);
end

% --- Executes on button press in ResetAll.
function ResetAll_Callback(hObject, eventdata, handles)
% hObject    handle to ResetAll (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = guidata(hObject);
try
    axes(handles.axes1);
    imshow(handles.RGB)
    % Reset pixel distance
    handles.DIST = 'NA';
    DIST_disp = 0;
    handles.TickMarksFound = 0;
    set(handles.TickMarks,'string',sprintf('Tick Marks Identified = %d',handles.TickMarksFound));
    set(handles.DisplayDistance,'string',sprintf('Distance = %d pixels',DIST_disp));
    set(handles.LeafAreaReport,'string','Leaf Area =');
    % Disable Mask tools
    set(handles.pushbuttonLeaf,'Enable','off');
    set(handles.pushbuttonBackground,'Enable','off');
    set(handles.CreateMask,'Enable','off');
    set(handles.RedoLeaf,'Enable','off');
    axes(handles.axes2);
    imshow(handles.Ruler);
    axes(handles.axes3);
    imshow(handles.placeholder3);
catch
    
end
guidata(hObject,handles);
end
