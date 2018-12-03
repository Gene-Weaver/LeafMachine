%% Personal Notes
%%%%% use class object to store data
% methods for functions
% properties to store data
%%%%% seperate class to store individual leaves 
% store all leaves in matrix 

% add catch for having correct organizational directories

% to save ROI table as .mat, clear workspace, export from imagelabeler,
% then 'save ROI_test.mat' in console

%% Operational Notes
% The 'Create Mask' requirement is used to make sure old data is not
% partially used to save new data. For example, if the user saved data for
% leaf1 and partially measures leaf2, old data like the previous make may
% be residually present in the GUI data storage system. The requirement
% ensures that SaveLeafData cannot be pressed while data is in a partially
% updated state.

%% Exported Variables 
% handles.Boundary --> x and y coordinates of each pixel that comprise leaf boundary 




%% GUI Code
function varargout = GUI_Auto_Distance(varargin)
    % Begin initialization code - DO NOT EDIT    
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
                       'gui_Singleton',  gui_Singleton, ...
                       'gui_OpeningFcn', @GUI_Auto_Distance_OpeningFcn, ...
                       'gui_OutputFcn',  @GUI_Auto_Distance_OutputFcn, ...
                       'gui_ClosingFcn', @Quit_Callback,...
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
    
    % Check GPU status
    try
        gpuDevice;
        handles.GPUstatus = 'TRUE';
        sprintf("GPU Available")
    catch
        handles.GPUstatus = 'FALSE';
        sprintf("GPU Not Available")
    end
    
    addpath(genpath('Img'));
    addpath(genpath('Leaf_Data'));
    addpath(genpath('Processed_Images'));
    addpath(genpath('Raw_Images'));
    addpath(genpath('Ruler'));
    addpath(genpath('Networks'));
    addpath(genpath('SandboxFunctions'));
    addpath(genpath('Training_Images'));
    %addpath('SandboxFunctions');
    % Placeholder Images
    handles.workspace = load('Networks/LeafMachine_SegNet_v1.mat');
    handles.placeholder = imread('Img/StartLeaf.jpg');
    handles.placeholder2 = imread('Img/StartRuler.jpg');
    handles.placeholder3 = imread('Img/StartDiagram.jpg');
    handles.placeholder4 = imread('Img/Batch.jpg');
    handles.Ruler = handles.placeholder2;
    axes(handles.axes1);
    imshow(handles.placeholder);
    axes(handles.axes2);
    imshow(handles.placeholder2);
    axes(handles.axes3);
    imshow(handles.placeholder3);
    uibuttongroup1_CreateFcn(hObject, eventdata, handles);

    % Set Superpixels Slider UI controls
    set(handles.uibuttongroup1,'selectedobject',handles.Metric1cm);
    set(handles.Slider,'min',100);
    set(handles.Slider,'max',2000);
    set(handles.Slider, 'Value', 500);
    set(handles.SliderCaption,'String','Mask Sensitivity: 50%')

    handles.Metric1mm = .1;
    handles.Metric1cm = 1;
    handles.Metric10cm = 10;
    handles.A2Dui = -1;
    
    handles.Superpixel = 500; % Default
    handles.M_Type = "NA";

    handles.SCALE = handles.Metric1cm;                      % *** needs to be made dynamic
    
    guidata(hObject, handles);
end

% --- Executes during object creation, after setting all properties.
function uibuttongroup1_CreateFcn(hObject,~,~)
    handles = guidata(hObject);
    guidata(hObject,handles);
end

% --- Executes during object creation, after setting all properties.
function Slider_CreateFcn(hObject,~,~)
    if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor',[.9 .9 .9]);
    end
end

% --- Executes during object creation, after setting all properties.
function Area2DistanceUI_CreateFcn(hObject,~,~)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end

% --- Outputs from this function are returned to the command line.
function varargout = GUI_Auto_Distance_OutputFcn(~,~, handles) 
    varargout{1} = handles.output;
end

% --- Executes during object creation, after setting all properties.
function DistanceCM_CreateFcn(hObject,~,~)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end

%=============================================================
%=========== Pixel-Distance Radio Button =====================
%=============================================================
function uibuttongroup1_SelectionChangedFcn(hObject, eventdata,~)
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

%=============================================================
%=================== Load Next Image =========================
%=============================================================
function NextImage_Callback(hObject,~,~)
    handles = guidata(hObject);
    try
        % Get UI to select Leaf Image
        handles.ImageFile = uigetfile({'*.JPG;*.jpg;*.jpeg;*.png'});
        handles.RGB = imread(handles.ImageFile);
        handles.Gray = rgb2gray(handles.RGB);
        % PreProcess Image
        [handles.BinaryPre,handles.GradMag,handles.GraySmooth,handles.BinaryCorrected] = ImagePreProcessing(handles.Gray);
        guidata(hObject,handles);
        handles.ImageH = length(handles.RGB(:,1,1));
        handles.ImageW = length(handles.RGB(1,:,1));

        axes(handles.axes1);
        imshow(handles.RGB);
        % Restart Leaf index at 1 
        handles.LeafIndex = 1;
        % Reset pixel distance
        handles.DIST = 0;
        handles.TickMarksFound = 0;

        % Set GUI 
        set(handles.TickMarks,'string',sprintf('Tick Marks Identified = %d',handles.TickMarksFound));
        set(handles.DisplayDistance,'string',sprintf('Distance = %d pixels',handles.DIST))
        set(handles.LeafAreaReport,'string','Leaf Area =');
        % Disable Mask tools
        set(handles.pushbuttonLeaf,'Enable','off');
        set(handles.pushbuttonBackground,'Enable','off');
        set(handles.CreateMask,'Enable','off');
        set(handles.RedoLeaf,'Enable','off');
        set(handles.MeasureManually,'Enable','on');
        set(handles.Area2Distance,'Enable','on');
        set(handles.NextImage,'BackgroundColor',[.47 .67 .19]);

        axes(handles.axes2);
        imshow(handles.Ruler);
        axes(handles.axes3);
        imshow(handles.placeholder3);

        guidata(hObject,handles);
   catch
   end
end

%=============================================================
%======== Measure Pixel-Distance Automatically ===============
%=============================================================
function MeasureDistance_Callback(hObject,~,~)
handles = guidata(hObject);
WaitCursor();
% Get most recent radiobutton choice
set(handles.uibuttongroup1,'SelectionChangeFcn',@uibuttongroup1_SelectionChangedFcn)
% Update handles.M_Type
handles.M_Type = "Auto";
% Find and Measure Ruler
sceneImageRGB = handles.RGB;
sceneImage = rgb2gray(sceneImageRGB);
sceneImageSmooth = handles.GraySmooth;
boxImageRGB = handles.Ruler;
boxImage = rgb2gray(boxImageRGB);

% Imresize, faster option to fix double-tickmarking
%boxImage = imresize(boxImage,.6,'Antialiasing',false);
%sceneImage = imresize(sceneImage,.4,'Antialiasing',false);

boxPoints = detectHarrisFeatures(boxImage);
scenePoints = detectHarrisFeatures(sceneImage);
scenePointsSmooth = detectHarrisFeatures(sceneImageSmooth);
%boxPoints = detectSURFFeatures(boxImage);
%scenePoints = detectSURFFeatures(sceneImage);%66.9
%boxPoints = detectHarrisFeatures(boxImage,'MinQuality', 0.001);
%scenePoints = detectHarrisFeatures(sceneImage,'MinQuality', 0.001);%


% NOTES
% distorted = scene
% original = box

[boxFeatures, boxPoints] = extractFeatures(boxImage, boxPoints);
[sceneFeatures, scenePoints] = extractFeatures(sceneImage, scenePoints);
[handles.sceneFeaturesSmooth, handles.scenePointsSmooth] = extractFeatures(sceneImageSmooth, scenePointsSmooth);

%%%
axes(handles.axes2)
imshow(handles.Ruler)
hold on
plot(boxPoints);
hold off
axes(handles.axes1)
%try 
    %%% 
    % Determine rotation/scaling of ruler in herbarium image
%     indexPairs = matchFeatures(boxFeatures, sceneFeatures); %matchFeatures(featuresOriginal, featuresDistorted)
%     matchedOriginal  = boxPoints(indexPairs(:,1))
%     matchedDistorted = scenePoints(indexPairs(:,2))
%     
%     figure;
%     showMatchedFeatures(boxImage,sceneImage,matchedOriginal,matchedDistorted);
%     title('Putatively matched points (including outliers)');
    
    % OG
%     [tformPOLY, inlierDistorted, inlierOriginal] = estimateGeometricTransform(...
%     matchedDistorted, matchedOriginal, 'similarity');

    %tformPOLY = fitgeotrans(matchedDistorted.Location,matchedOriginal.Location,'nonreflectivesimilarity');
    %tformPOLY = fitgeotrans(matchedDistorted.Location,matchedOriginal.Location,'similarity');


    %figure;
    %howMatchedFeatures(boxImage,sceneImage,inlierOriginal,inlierDistorted);
    %title('Matching points (inliers only)');
    %legend('ptsOriginal','ptsDistorted');
    
%     Tinv = tformPOLY.invert.T
%     tformPOLY2 = projective2d(Tinv)
%     
%     ss = Tinv(2,1);
%     sc = Tinv(1,1);
%     scaleRecovered = sqrt(ss*ss + sc*sc)
%     thetaRecovered = atan2(ss,sc)*180/pi
%     outputView = imref2d(size(boxImage));
%     recovered  = imwarp(sceneImage,tformPOLY,'OutputView',outputView); % Use tform to rotate polygon around ruler
%     figure, imshowpair(boxImage,recovered,'montage')


    % Match features between ruler and image
    boxPairs = matchFeatures(boxFeatures, sceneFeatures);
    matchedBoxPoints = boxPoints(boxPairs(:, 1), :);
    matchedScenePoints = scenePoints(boxPairs(:, 2), :);
    [tform, ~, ~] = estimateGeometricTransform(matchedBoxPoints, matchedScenePoints, 'affine');
    %tformPOLY.T
    %tform.T
    % Create boundary around ruler based on matched features
    boxPolygon = [1, 1;...                           % top-left
            size(boxImage, 2), 1;...                 % top-right
            size(boxImage, 2), size(boxImage, 1);... % bottom-right
            1, size(boxImage, 1);...                 % bottom-left
            1, 1];                   % top-left again to close the polygon
    
    newBoxPolygon = transformPointsForward(tform, boxPolygon)
    %newBoxPolygon = transformPointsForward(tformPOLY2, boxPolygon)
    

    
    % Find matched points within the polygon
    ScenePointsX = scenePoints.Location(:,1);
    ScenePointsY = scenePoints.Location(:,2);
    [in,~] = inpolygon(ScenePointsX,ScenePointsY,newBoxPolygon(:,1),newBoxPolygon(:,2));
    PointsInPoly = [ScenePointsX(in),ScenePointsY(in)];
    PointsOutPoly = [ScenePointsX(~in),ScenePointsY(~in)];
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
    [peakDensity,xi] = ksdensity(MinDist);
    [~,peakIndex] = max(peakDensity);
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

    
    % Plot features for export
    h = figure;
    set(h, 'Visible', 'off');
    imshow(handles.RGB)
    hold on

    scatter(CorrectedPoints(:,1),CorrectedPoints(:,2),'r','filled') %Bad Points
    scatter(CorrectedPointsTrimmed(:,1),CorrectedPointsTrimmed(:,2),'g','filled') %Good Points
    line(newBoxPolygon(:, 1), newBoxPolygon(:, 2), 'Color', 'g')
    
    % Save Leaf Points from outside of ruler box 
    handles.ImageFeaturePoints = PointsOutPoly;
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
ArrowCursor();
guidata(hObject,handles);
end

%=============================================================
%============ Measure Pixel-Distance Manually ================
%=============================================================
function MeasureManually_Callback(hObject,~,~)
    handles = guidata(hObject);
    % Update Measurement Method
    handles.M_Type = "Manual";
    
    % Position Distance Tool
    axes(handles.axes1);
    h = imdistline(gca);
    pause('on');pause;
    api = iptgetapi(h);

    % Save pixel distance for later conversion
    handles.DIST = api.getDistance();
    
    % Round for GUI formatting
    DIST_disp = round(handles.DIST);
    set(handles.DisplayDistance,'string',sprintf('Distance = %d pixels',DIST_disp));
    
    % Enable Mask tools
    set(handles.pushbuttonLeaf,'Enable','on');
    set(handles.pushbuttonBackground,'Enable','on');
    set(handles.CreateMask,'Enable','on');
    set(handles.RedoLeaf,'Enable','on');

    api.delete();

    guidata(hObject,handles);
end


% --- Executes on button press in Area2Distance.
function Area2Distance_Callback(hObject, eventdata, handles)
    handles = guidata(hObject);
    % Update handles.M_Type
    handles.M_Type = "Area2Distance";
    handles.A2Dui = str2double(get(handles.Area2DistanceUI,'String'));
    %SelectForegound_A2D();
    axes(handles.axes1);
    imshow(handles.RGB);
    [FOREGROUNDx, FOREGROUNDy] = getpts();
    h1 = impoly(gca,[round(FOREGROUNDx),round(FOREGROUNDy)],'Closed',false);
    foresub1 = getPosition(h1);
    handles.A2DforegroundInd = sub2ind(size(handles.RGB),foresub1(:,2),foresub1(:,1));
    %handles.A2DforegroundInd_disp = strjoin(string(handles.foregroundInd),' ');
    %SelectBackgound_A2D();
    [BACKGROUNDx, BACKGROUNDy] = getpts();
    h2 = impoly(gca,[round(BACKGROUNDx), round(BACKGROUNDy)],'Closed',false);
    backsub2 = getPosition(h2);
    handles.A2DbackgroundInd = sub2ind(size(handles.RGB),backsub2(:,2),backsub2(:,1));
    %handles.A2DbackgroundInd_disp = strjoin(string(handles.backgroundInd),' ');
    WaitCursor();
    SP1 = superpixels(handles.RGB,handles.Superpixel);% 200, 500, 1000, 1200, 1500, hyper 2000
    BW1 = lazysnapping(handles.RGB,SP1,handles.A2DforegroundInd,handles.A2DbackgroundInd,...
            'EdgeWeightScaleFactor',750);
    BW1 = bwselect(BW1,foresub1(:,1),foresub1(:,2),4);
    %imshow(BW1);
    % Fill Holes
    BW1 = imfill(BW1,'holes');
    % Pad borders
    SE1 = strel('line',100,0);
    BW1 = imdilate(BW1,SE1);
    SE2 = strel('line',30,90);
    BW1 = imdilate(BW1,SE2);
    SE3 = strel('line',30,45);
    BW1 = imdilate(BW1,SE3);
    % Erode borders to original size
    SE1 = strel('line',100,0);
    BW1 = imerode(BW1,SE1);
    SE2 = strel('line',30,90);
    BW1 = imerode(BW1,SE2);
    SE3 = strel('line',30,45);
    BW1 = imerode(BW1,SE3);
    ArrowCursor();
    BW1_check = imfuse(handles.RGB,BW1);
    imshow(BW1_check)
    choice = questdlg('Is this mask acceptable?', ...
            'Redo?',...
            'Reject','Accept','Accept');
        switch choice
            case 'Accept'
                handles = guidata(hObject);
                %figure(1);
                %imshow(BW1);
                axes(handles.axes1);
                imshow(handles.RGB)
                hold on
                % Un-adjusted bounding box
                Bounds = regionprops(BW1,'BoundingBox');
                BoundsMatrix = vertcat(Bounds(:).BoundingBox);
                BW1_height = BoundsMatrix(:,3)%height
                BW1_width = BoundsMatrix(:,4)%width
                handles.A2D_pixel_distance = max([BW1_height,BW1_width])
                BoundingRect = struct2array(regionprops(BW1,'BoundingBox'));
                Points = bbox2points(BoundingRect);
                Points(end+1,:) = Points(1,:);
                plot(Points(:,1),Points(:,2), 'c-');
                hold off

                maskedImage = handles.RGB;
                maskedImage(repmat(~BW1,[1 1 3])) = 0;

                %imshow(BW1)
                %hold on
%                 figure('Name','remove');
%                 BW1_remove = bwmorph(BW1,'remove');
%                 imshow(BW1_remove);
% 
%                 figure('Name','tophat');
%                 BW1_tophat = bwmorph(BW1,'tophat');
%                 imshow(BW1_tophat);
% 
%                 figure('Name','bothat');
%                 BW1_bothat = bwmorph(BW1,'bothat');
%                 imshow(BW1_bothat);
%                 
%                 [remove_y,remove_x] = find(BW1_remove==1);
%                 [tophat_y,tophat_x] = find(BW1_tophat==1);
%                 [bothat_y,bothat_x] = find(BW1_bothat==1);
                
                harris_pts = detectHarrisFeatures(BW1);
                harris_Location = harris_pts.Location;
                harris_x = harris_pts.Location(:,1);
                harris_y = harris_pts.Location(:,2);
                cent = [mean(harris_x),mean(harris_y)];%Center
                
                n = 8;
                CORNERS = zeros(n,2);
                MINS = zeros(n,2);
                harris_Location_MIN = harris_Location;
                harris_Location_MAX = harris_Location;
                for i = 1:n
                    distances = sqrt(sum(bsxfun(@minus, harris_Location_MAX, cent).^2,2))
                    distances2 = sqrt(sum(bsxfun(@minus, harris_Location_MIN, cent).^2,2))
                    [max_distance,IND] = max(distances);
                    [min_distance,IND2] = min(distances2);
                    [I_row, I_col] = ind2sub(size(distances),IND);
                    [I_row2, I_col2] = ind2sub(size(distances2),IND2);
                    CORNERS(i,:) = harris_Location_MAX(I_row,:);
                    MINS(i,:) = harris_Location_MIN(I_row2,:);
                    harris_Location_MAX(I_row,:) = [];
                    harris_Location_MIN(I_row2,:) = [];
                end
                
%                 distances = sqrt(sum(bsxfun(@minus, harris_Location, cent).^2,2));
%                 
%                 for i = 1:length(harris_x)
%                     harris_Location(i,:) = [];
%                     % Euclidean distance between points
%                     distances = sqrt(sum(bsxfun(@minus, harris_Location, cent).^2,2));
%                     max_distance = max(distances);
%                     
%                     
%                     if ((PeakMin >=(.9*peakLocation)) & (PeakMin<=(1.1*peakLocation)))
%                         PeakPointsLocation(i,:) = cent;
%                     else
%                         PeakPointsLocation(i,:) = 0; % make rows 0 if it is not within the range
%                     end
%                 end
                figure(11);
                imshow(BW1);
                hold on
                %plot(remove_x,remove_y,'m*')
                %plot(tophat_x,tophat_y,'b*')
                %plot(bothat_x,bothat_y,'g*')
                plot(harris_x,harris_y,'m*')
                plot(cent(1,1),cent(1,2),'r*')
                plot(CORNERS(:,1),CORNERS(:,2),'g*')
                plot(MINS(:,1),MINS(:,2),'c*')

                guidata(hObject,handles);
            case 'Reject'
                axes(handles.axes1);
                imshow(handles.RGB)
        end
%     figure('Name','remove clean');
%     BW1_remove_clean = bwmorph(BW1_remove,'clean');
%     imshow(BW1_remove_clean);
%     
%     figure('Name','thin');
%     BW1_thin = bwmorph(BW1,'thin',Inf); % CPU Intensive
%     imshow(BW1_thin);
%     
%     figure('Name','thin thicken');
%     BW1_thin_thicken = bwmorph(BW1_thin,'thicken',Inf);
%     imshow(BW1_thin_thicken);
    

    % Convert A2D_pixel_distance into pixel distance for 1 cm.
    handles.DIST = handles.A2D_pixel_distance/handles.A2Dui;
    DIST_disp = round(handles.DIST,3);
    set(handles.DisplayDistance,'string',sprintf('Distance = %.6g pixels',DIST_disp))
    
    % Enable Mask tools
    set(handles.pushbuttonLeaf,'Enable','on');
    set(handles.pushbuttonBackground,'Enable','on');
    set(handles.CreateMask,'Enable','on');
    set(handles.RedoLeaf,'Enable','on');
    % Update handles.M_Type
    handles.M_Type = "Area2Distance";
    guidata(hObject,handles);
end


function Area2DistanceUI_Callback(hObject, ~, ~)
    handles = guidata(hObject);
    try
        handles.A2Dui = str2double(get(handles.Area2DistanceUI,'String'));
    catch
        sprintf("Distance must be numeric")
    end
    guidata(hObject,handles);
end

%=============================================================
%=========== Get UI to Select Leaf in Image ==================
%=============================================================
function pushbuttonLeaf_Callback(hObject,~,~)
    handles = guidata(hObject);
    set(handles.GUIDE,'string',...
        'Clicks to add points. Double-click to add final point. Press "Return" or "Enter" to finish. Press "Backspace" or "Delete" to remove previous point.')
    %Foreground - Select leaf
    axes(handles.axes1);
    imshow(handles.RGB);
    [FOREGROUNDx, FOREGROUNDy] = getpts();
    h1 = impoly(gca,[round(FOREGROUNDx),round(FOREGROUNDy)],'Closed',false);
    foresub = getPosition(h1);

    handles.LEAF_INDICES = foresub;
    handles.foregroundInd = sub2ind(size(handles.RGB),foresub(:,2),foresub(:,1));
    handles.foregroundInd_disp = strjoin(string(handles.foregroundInd),' ');

    guidata(hObject,handles);
end


%=============================================================
%======== Get UI to Select Background in Image ===============
%=============================================================
function pushbuttonBackground_Callback(hObject,~,~)
    handles = guidata(hObject);
    
    [BACKGROUNDx, BACKGROUNDy] = getpts();
    h2 = impoly(gca,[round(BACKGROUNDx), round(BACKGROUNDy)],'Closed',false);
    backsub = getPosition(h2);
    
    handles.backgroundInd = sub2ind(size(handles.RGB),backsub(:,2),backsub(:,1));
    handles.backgroundInd_disp = strjoin(string(handles.backgroundInd),' ');
    
    guidata(hObject,handles);
end


%=============================================================
%============ Extract Leaf Mask from Image ===================
%=============================================================
function CreateMask_Callback(hObject,~,~)
tic
handles = guidata(hObject);
% Loading icon setup
set(gcf, 'pointer', 'arrow') 
set(gcf, 'pointer', 'watch') 
drawnow;

% Text ID
ocrResults = ocr(handles.RGB);
handles.Text = ocrResults.Text;
% figure;
% imshow(handles.RGB);
% text(600, 150, handles.Text, 'BackgroundColor', [1 1 1]);                                   %********



% Define superpixel size
%handles.Superpixel = 1200;
% Move to GPU if available

try
    status = ('GPU Computing Enabled')
    gpuRGB = gpuArray(handles.RGB);
    % Superpixels function for lazy snapping
    SP = superpixels(handles.RGB,handles.Superpixel);% 200, 500, 1000, 1200, 1500, hyper 2000
    sprintf(size(SP))
    sprintf(size(handles.Superpixel))
    sprintf(size(handles.RGB))
    BW = gpuArray(lazysnapping(handles.RGB,SP,...
        handles.foregroundInd,handles.backgroundInd,...
        'EdgeWeightScaleFactor',750)); %10-1000 default 500, usually 750 is best
    BW = gather(BW);
    status = ('GPU Computing Enabled-Done')
catch
    status = ('GPU Computing FAILED')
    SP = superpixels(handles.RGB,handles.Superpixel);% 200, 500, 1000, 1200, 1500, hyper 2000
%     size(SP)
%     size(handles.Superpixel)
%     size(handles.RGB)
    handles.foregroundInd
    BW = lazysnapping(handles.RGB,SP,handles.foregroundInd,handles.backgroundInd,...
    'EdgeWeightScaleFactor',750);%10-1000 default 500, usually 750 is best
    status = ('GPU Computing FAILED-Done')
end
%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% Testing
% [~,IFP] = kmeans(handles.ImageFeaturePoints,70);
% IFP = round(IFP);
% figure(22);
% BM = boundarymask(SP);
% imshow(imoverlay(handles.BinaryCorrected,BM,'cyan'));
% hold on
% scatter(IFP(:,1),IFP(:,2),50,'r*');
% hold off
% 
% %%% Index values of binary to cross-ref with kmeans points
% % Find leaf in binary image
% [row,col] = find(~handles.BinaryCorrected);
% LeafCoor = [row,col];
% % Round extracted features to enable matching with LeafCoor
% ROUNDImageFeaturePoints = floor(handles.ImageFeaturePoints);
% % Find intersection between features and binary points
% AllPointsinLeaf = intersect(ROUNDImageFeaturePoints,LeafCoor,'rows');
% % Kmeans of AllPointsinLeaf
% [~,ALLFP] = kmeans(AllPointsinLeaf,70);
% % Round for matching
% ALLFP = floor(ALLFP);
% % Find intersection
% KMeansinLeaf = intersect(ALLFP,LeafCoor,'rows');
% figure(23);
% imshow(handles.BinaryCorrected)
% hold on
% scatter(AllPointsinLeaf(:,1),AllPointsinLeaf(:,2),10,'go');
% scatter(handles.ImageFeaturePoints(:,1),handles.ImageFeaturePoints(:,2),10,'r.');
% scatter(KMeansinLeaf(:,1),KMeansinLeaf(:,2),100,'m*'); % Used for Leaf Identification


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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
handles.AREA_P = bwarea(AREA_IMAGE);
PERIMETER_P = struct2array(regionprops(AREA_IMAGE,'Perimeter'));
PERIMETER = round(PERIMETER_P/(handles.DIST/handles.SCALE),3);
handles.Perimeter = PERIMETER;
% Convert pixel area to cm^2
handles.AREA_cm = (1/(handles.DIST/handles.SCALE)^2)*handles.AREA_P;
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

%figure();
[handles.Boundary,~] = bwboundaries(handles.Binary,'noholes');                             %*******
%imshow(handles.RGB)
%hold on
%plot(handles.Boundary{1}(:,2), handles.Boundary{1}(:,1), 'g', 'LineWidth', 3)
%hold off


% Report Leaf Area
formatSpec = 'Leaf Area = %.3f cm^2';
AreaText = sprintf(formatSpec,handles.AREA_cm_report);
%handles.AREA_cm_report
set(handles.LeafAreaReport,'string',AreaText);
set(handles.SaveLeafArea,'Enable','on');
% Loading icon end
set(gcf, 'pointer', 'arrow')
drawnow;
% Update UI data
guidata(hObject,handles);
toc


end


%=============================================================
%========== Save Data/Images from Single Leaf ================
%=============================================================
function SaveLeafArea_Callback(hObject,~,~)
    handles = guidata(hObject);
    function fileOut = SymbolStrip(fileIn)
        fileIn = strrep(fileIn,'[','');
        fileIn = strrep(fileIn,']','');
        fileIn = strrep(fileIn,':','-');
        fileIn = strrep(fileIn,'','_');
        fileOut = strrep(fileIn,' ','_');
    end
    WaitCursor()
    
    % **********************
    % **** EXPORT .xlsx **** Get filename from .xlsx filename, requires handles.BaseFilename to exist
    % **********************
    try 
        FILENAME = handles.BaseFilename;
    catch
        choice = questdlg('Select an export file.', ...
            'Export Destination Not Set', ...
            'Continue','Continue');
        switch choice
            case 'Continue'
                handles = guidata(hObject);
                Out = OpenCSV_StandAlone();
                handles.OriginalCSV = Out{1};handles.BaseFilename = Out{2};
                handles.CSVVariableNames = Out{3};FILENAME = Out{4};
                set(handles.FileSaveDisp,'string',strcat('Destination Set > ',...
                    char(FILENAME)),'ForegroundColor',[.47 .67 .19]);
                set(handles.OpenCSV,'BackgroundColor',[.47 .67 .19]);
                guidata(hObject,handles);
        end
    end
    % Convert to cell array
    OriginalCSV = table2cell(handles.OriginalCSV);
    % Get time
    t = datestr(datetime('now','TimeZone','local','Format','d-MMM-y HH:mm:ss'));
    % New filename
    handles.NEWFILENAME = strcat('Leaf_Data/',FILENAME,'-',t,'.xlsx');
    % Add data to cell array, will be new row in data table
    if handles.M_Type == "Manual" 
        handles.ImageRulerFile = "NA";
        handles.TickMarksFound = "NA";
    elseif handles.M_Type == "Area2Distance"
        handles.ImageRulerFile = "NA";
        handles.TickMarksFound = "NA";
    else
    end
    N={handles.ImageFile,'species name',...
        handles.LeafIndex,handles.DIST,...
        handles.AREA_P,handles.AREA_cm_report,...
        handles.Perimeter,handles.TickMarksFound,...
        handles.Superpixel,handles.M_Type,...
        handles.ImageRulerFile,t,...
        handles.foregroundInd_disp,handles.backgroundInd_disp,...
        handles.Text};
    % Convert back to table
    NewData = cell2table([OriginalCSV;N]);
    % Give the new table the same headers as previous table
    NewData.Properties.VariableNames = handles.CSVVariableNames % Show in command window for validation
    % Save newdata table to hobject
    handles.OriginalCSV = NewData;

    % for writing data, each leaf % *** old method
    % Write the table to a new .xlsx file
    %writetable(NewData,NEWFILENAME);
    % *** Set the original file to be the newly created file, this keeps the
    % program from overwriting data ***
    %handles.OriginalCSV = readtable(NEWFILENAME);

    ImageFileParsed = strsplit(handles.ImageFile,'.');
    ImageFileParsed = char(ImageFileParsed(1,1));
    % ********************************
    % **** EXPORT .png Comparison **** 
    % ********************************
    CompareJPEGFilename = strcat('Processed_Images/Summary_Images/',ImageFileParsed,...
        '_Compare_','L',num2str(handles.LeafIndex),'_',t,'.png');
    CompareJPEGFilename = SymbolStrip(CompareJPEGFilename);
    imwrite(handles.RGBinsert,CompareJPEGFilename);
    
    % ********************************
    % *** EXPORT .png Binary Mask **** 
    % ********************************
    BinaryPNGFilename = strcat('Processed_Images/Binary_Masks/',ImageFileParsed,...
        '_Binary_','L',num2str(handles.LeafIndex),'_',t,'.png');
    BinaryPNGFilename = SymbolStrip(BinaryPNGFilename);
    imwrite(handles.Binary,BinaryPNGFilename);
    
    % *************************************
    % *** EXPORT .png Matched Features **** Only saves when auto-distance is used
    % *************************************
    try
        MFPNGFilename = strcat('Processed_Images/Matched_Features/',ImageFileParsed,...
            '_MatchedFeatures_','L',num2str(handles.LeafIndex),'_',t,'.png');
        MFPNGFilename = SymbolStrip(MFPNGFilename);
        print(handles.Features,'-dpng','-r400',MFPNGFilename)
    catch
    end
    
    % *******************************
    % **** SETUP for Next Image ***** 
    % *******************************
    handles.LeafIndex = handles.LeafIndex + 1;
    % Update the save destination in the GUI display
    set(handles.FileSaveDisp,'string',strcat('Destination Set > ',char(handles.NEWFILENAME)),...
        'ForegroundColor',[.47 .67 .19]);
    set(handles.SaveLeafArea,'Enable','off');
    set(handles.ExportSessionData,'Enable','on');
    set(handles.LeafAreaReport,'string','Leaf Area =');


ArrowCursor()
guidata(hObject,handles);
end


%=============================================================
%=========== UI to Select Export .xlsx. File =================
%=============================================================
function OpenCSV_Callback(hObject,~,~)
    try
        %OpenImage
        handles = guidata(hObject);
        % Have user open latest data file
        FILE = uigetfile('*.xlsx');
        % Parse filename
        [~,FILENAME]=fileparts(FILE);
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
    catch
    end
    guidata(hObject,handles);
end


%=============================================================
%=========== Write Session Data to .xlsx File ================
%=============================================================
function ExportSessionData_Callback(hObject,~,~)
    handles = guidata(hObject);
    WaitCursor();
    % Remove problematic chars
    handles.NEWFILENAME = strrep(handles.NEWFILENAME,'[','');
    handles.NEWFILENAME = strrep(handles.NEWFILENAME,']','');
    handles.NEWFILENAME = strrep(handles.NEWFILENAME,':','-');
    handles.NEWFILENAME = strrep(handles.NEWFILENAME,'','_');
    writetable(handles.OriginalCSV,handles.NEWFILENAME);
    fileattrib(handles.NEWFILENAME, '+w')
    set(handles.ExportSessionData,'Enable','off');

    ArrowCursor();
    guidata(hObject,handles);
end


%=============================================================
%======= Get UI to Select Ruler for AutoDistance ============= 
%=============================================================
function LoadRuler_Callback(hObject,~,~)
    handles = guidata(hObject);
    try
        handles.ImageRulerFile = uigetfile({'*.JPG;*.jpg;*.jpeg;*.png'});
        handles.Ruler = imread(handles.ImageRulerFile);

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

        set(handles.MeasureDistance,'Enable','on');
        set(handles.LoadRuler,'BackgroundColor',[.47 .67 .19]);
    catch
    end
    guidata(hObject,handles);
end

%=============================================================
%============ Reset Major Variables to NA/NULL =============== 
%=============================================================
function ResetAll_Callback(hObject,~,~)
    handles = guidata(hObject);
    try
        axes(handles.axes1);
        imshow(handles.RGB);
        axes(handles.axes2);
        imshow(handles.Ruler);
        axes(handles.axes3);
        imshow(handles.placeholder3);
        % Reset pixel distance
        handles.DIST = 'NA';
        DIST_disp = 0;
        handles.A2Dui = -1;
        handles.TickMarksFound = 0;
        handles.M_Type = "NA";
        set(handles.TickMarks,'string',sprintf('Tick Marks Identified = %d',handles.TickMarksFound));
        set(handles.DisplayDistance,'string',sprintf('Distance = %d pixels',DIST_disp));
        set(handles.LeafAreaReport,'string','Leaf Area =');
        % Disable Mask tools
        set(handles.pushbuttonLeaf,'Enable','off');
        set(handles.pushbuttonBackground,'Enable','off');
        set(handles.CreateMask,'Enable','off');
        set(handles.RedoLeaf,'Enable','off');
    catch
    end
    guidata(hObject,handles);
end


%=============================================================
%=========== Redo a Leaf Selection =========================== 
%=============================================================
function RedoLeaf_Callback(hObject,~,~)
    handles = guidata(hObject);
    set(handles.SaveLeafArea,'Enable','off');
    axes(handles.axes1);
    imshow(handles.RGB);
    guidata(hObject,handles);
end

%=============================================================
%========= Slider Selection Tool for Superpixels ============= 
%=============================================================
function Slider_Callback(hObject,~,~)
    handles = guidata(hObject);
    handles.Superpixel = round(get(hObject,'Value'));
    caption = round(handles.Superpixel/10);
    caption = sprintf('Mask Sensitivity: %d',caption);
    set(handles.SliderCaption,'String',strcat(caption,'%'))
    % Hints: get(hObject,'Value') returns position of slider
    %        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
    guidata(hObject,handles);
end

%=============================================================
%=========== Select Folder for Batch Processing ============== 
%=============================================================
function Batch_Callback(hObject,~,~)
    handles = guidata(hObject);
    LeafMachineBatchGUI
%     [handles.BatchFolder] = uigetdir('Choose Folder for Batch Processing');
%     addpath(handles.BatchFolder)
%     fOut = strsplit(handles.BatchFolder,'\');
%     fOut = fOut((length(fOut)-1));
%     handles.BatchFolderName = char(fOut(1));
%     handles.BatchFolderOutName = strcat(handles.BatchFolderName,'_Output');
%     
%     choice2 = questdlg('Output segmented image, montage, or both?', ...
%         'Segmentation Options',...
%         'Both','Montage Only','Segment Only','Segment Only');
%     switch choice2
%         case 'Montage Only'
%             segOpts = 'Montage';
%         case 'Segment Only'
%             segOpts = 'Segment';
%         case 'Both'
%             segOpts = 'Both';
%     end
%     choice3 = questdlg('Display images while processing? (Will run slower)', ...
%         'Show Images?',...
%         'Yes','No','No');
%     switch choice3
%         case 'Yes'
%             visOpts = 'show';
%         case 'No'
%             visOpts = 'noshow';
%     end
%     choice4 = questdlg('Use local GPU? Requires at least 8GB of GPU RAM', ...
%         'Use GPU?',...
%         'Yes','No','No');
%     switch choice4
%         case 'Yes'
%             gpu_cpu = 'gpu';
%         case 'No'
%             gpu_cpu = 'cpu';
%     end
%     WaitCursor();
%     axes(handles.axes2)
%     imshow(handles.placeholder4);
%     
%     [nFiles,BatchTime] = LeafMachineBatchSegmentation(handles.BatchFolder,segOpts,handles.workspace.vgg16_180730_v6_5ClassesNarrower,5,gpu_cpu,visOpts,'_Seg',handles.BatchFolderOutName,handles)
%     
%     % GUI
%     ArrowCursor();
%     axes(handles.axes2)
%     imshow(handles.placeholder2);
%     axes(handles.axes1)
%     imshow(handles.placeholder);
%     set(handles.FileSaveDisp,'String',strcat(nFiles," Images Processed in ",BatchTime," Seconds"),'ForegroundColor',[0 .45 .74]);
    guidata(hObject,handles);
end


%=============================================================
%========================== Quit GUI ========================= 
%=============================================================
function Quit_Callback(~,~,~)
    closereq
end

%<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
%>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
%-------------------- Non-GUI Functions ----------------------
%<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
%>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
function Export = OpenCSV_StandAlone()
    FILE = uigetfile('*.xlsx');
    [~,FILENAME]=fileparts(FILE);
    FILENAMEsplit = strsplit(FILENAME,'-');
    handles.BaseFilename = char(FILENAMEsplit(1,1));
    handles.OriginalCSV = readtable(FILE);
    handles.CSVVariableNames = handles.OriginalCSV.Properties.VariableNames;
    Export = {handles.OriginalCSV,handles.BaseFilename,handles.CSVVariableNames,FILENAME};
end

function WaitCursor()
set(gcf, 'pointer', 'watch') 
drawnow;
end

function ArrowCursor()
    set(gcf, 'pointer', 'arrow')
    drawnow;
end

%=============================================================
%================ Select Foreground ==========================
%=============================================================
function SelectForegound_A2D()
    axes(handles.axes1);
    imshow(handles.RGB);
    [FOREGROUNDx, FOREGROUNDy] = getpts();
    h1 = impoly(gca,[round(FOREGROUNDx),round(FOREGROUNDy)],'Closed',false);
    foresub = getPosition(h1);

    handles.A2DforegroundInd = sub2ind(size(handles.RGB),foresub(:,2),foresub(:,1));
    handles.A2DforegroundInd_disp = strjoin(string(handles.foregroundInd),' ');
end


%=============================================================
%====================== Select Background ====================
%=============================================================
function SelectBackgound_A2D()
    [BACKGROUNDx, BACKGROUNDy] = getpts();
    h2 = impoly(gca,[round(BACKGROUNDx), round(BACKGROUNDy)],'Closed',false);
    backsub = getPosition(h2);
    
    handles.A2DbackgroundInd = sub2ind(size(handles.RGB),backsub(:,2),backsub(:,1));
    handles.A2DbackgroundInd_disp = strjoin(string(handles.backgroundInd),' ');
end
