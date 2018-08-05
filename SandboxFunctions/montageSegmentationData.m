%%%     Montage Segmentation
%%%     Developed for LeafMachine.org
%%%
%%%     William Weaver
%%%     University of Colorado, Boulder
%%%     Department of Ecology and Evolutionary Biology


function [PLOT,leaf_Centers] = montageSegmentationData(net,filename,...
    destinationDirectory,image,cpu_gpu,nClasses)

    addpath('SandboxFunctions');
    
    %*% temp
    load('Networks\LeafMachine_SegNet.mat');
    net = vgg16_180730_v6_5ClassesNarrower;
    cpu_gpu = 'gpu';
    image = 'Salicacea_Populus_tremuloides_10.jpg';
    
    
    % Read image
    image = imread(image);
    SP1 = superpixels(image,500);
    % Segmentation
    [C,~,~] = semanticseg(image,net,'ExecutionEnvironment',cpu_gpu);
    
    % Label overlay
    B = labeloverlay(image,C);
    
    % Retrieve binary masks
    Stem = C == 'Stem';
    Stem = 255 * repmat(uint8(Stem), 1, 1, 3);
    Leaf = C == 'Leaf';
    Leaf2 = 255 * repmat(uint8(Leaf), 1, 1, 3);
    Text_Black = C == 'Text_Black';
    Text_Black = 255 * repmat(uint8(Text_Black), 1, 1, 3);
    Fruit_Flower = C == 'Fruit_Flower';
    Fruit_Flower = 255 * repmat(uint8(Fruit_Flower), 1, 1, 3);
    Background = C == 'Background';
    Background2 = 255 * repmat(uint8(Background), 1, 1, 3);
    
    [r_Back,c_Back] = find(C=='Background');
    background = [r_Back,c_Back];
    [r_Leaf,c_Leaf] = find(C=='Leaf');
    leaf_B_Points = [r_Leaf,c_Leaf];
    
    % Draw oulines for use in SVM 
    imshow(Leaf)
    leaf_Perimeters = bwmorph(Leaf,'remove');
    % img erode to remove non-leaves
    se = strel('disk',25);
    leaf_Erode = imerode(Leaf,se);
    imshow(leaf_Erode)
    % Count leaves
    [labeledLeaves, nLeaves] = bwlabel(leaf_Erode);
    % Stats
    stats = regionprops('table',leaf_Erode,'Centroid',...
        'MajorAxisLength','MinorAxisLength');
    % Centers, export to overlay leaf count numbers
    leaf_Centers = stats.Centroid;
    
    % Skeleton
    leaf_Skel = bwmorph(leaf_Erode,'skel',inf);
    imshow(leaf_Skel)
    stats_Skel = regionprops('table',leaf_Skel,'Centroid',...
        'MajorAxisLength','MinorAxisLength');
    skel_Centers = stats_Skel.Centroid;
    [labeledSkel, nSkel] = bwlabel(leaf_Skel);
    % Create skel boundary for all leaf area
    [c_allskel,r_allskel] = find(labeledSkel);
    skel_Background = [r_allskel,c_allskel];
    xx = skel_Background(:,1);
    yy = skel_Background(:,2);
    jj = boundary(xx,yy,0);
    polyin2 = polyshape(xx(jj),yy(jj));
    imshow(image)
    hold on;
    plot(xx(jj),yy(jj));
    polyout = polybuffer(polyin2,150);
    plot(polyout)
    
    for i= 1:nSkel
        [c,r] = find(labeledSkel == i);
        forground = [r,c];
        rand1 = randi([1 length(forground(:,1))],1,3);
        rand2 = randi([1 length(background(:,1))],1,10);
        
        forgroundPoints = forground(rand1,:);
        backgroundPoints = background(rand2,:);
        
%         x = forgroundPoints(:,1)
%         y = forgroundPoints(:,2)
%         j = boundary(x,y,0);
%         polyin = polyshape(x(j),y(j))
%         imshow(image)
%         hold on;
%         plot(x(j),y(j));
%         polyout = polybuffer(polyin,100);
%         plot(polyout)
        
             
        px = backgroundPoints(:,1);
        py = backgroundPoints(:,2);
        [in,~] = inpolygon(px,py,polyout.Vertices(:,1),polyout.Vertices(:,2));
%         PointsInPoly = [px(in),py(in)];
        PointsOutPoly = [px(~in),py(~in)];
        PY = px(~in);
        PX = py(~in);
        
        forgroundInd = sub2ind(size(image),forgroundPoints(:,1),forgroundPoints(:,2));
        backgroundInd = sub2ind(size(image),PointsOutPoly(:,1),PointsOutPoly(:,2));
        
        
        
        
        % Traveling Salesmen for background
        idxs = nchoosek(1:length(backgroundInd),2);
        dist = hypot(PX(idxs(:,1)) - PX(idxs(:,2)), ...
             PY(idxs(:,1)) - PY(idxs(:,2)));
        lendist = length(dist);
        tsp = optimproblem;
        trips = optimvar('trips',lendist,1,'Type','integer','LowerBound',0,'UpperBound',1);
        tsp.Objective = dist'*trips;
        constr2trips = optimconstr(length(backgroundInd),1);
        for stops = 1:length(backgroundInd)
            whichIdxs = (idxs == stops);
            whichIdxs = any(whichIdxs,2); % start or end at stops
            constr2trips(stops) = sum(trips(whichIdxs)) == 2;
        end
        tsp.Constraints.constr2trips = constr2trips;
        opts = optimoptions('intlinprog','Display','off','Heuristics','round-diving',...
            'IPPreprocess','none');
        tspsol = solve(tsp,'options',opts)
        tours = detectSubtours(tspsol.trips,idxs);
        numtours = length(tours); % number of subtours
        fprintf('# of subtours: %d\n',numtours);
        % Index of added constraints for subtours
        k = 1;
        while numtours > 1 % repeat until there is just one subtour
            % Add the subtour constraints
            for ii = 1:numtours
                subTourIdx = tours{ii}; % Extract the current subtour
        %         The next lines find all of the variables associated with the
        %         particular subtour, then add an inequality constraint to prohibit
        %         that subtour and all subtours that use those stops.
                variations = nchoosek(1:length(subTourIdx),2);
                a = false(length(idxs),1);
                for jj = 1:length(variations)
                    whichVar = (sum(idxs==subTourIdx(variations(jj,1)),2)) & ...
                               (sum(idxs==subTourIdx(variations(jj,2)),2));
                    a = a | whichVar;
                end
                tsp.Constraints.(sprintf('subtourconstr%i',k)) = sum(trips(a)) <= length(subTourIdx)-1;
                k = k + 1;
            end
            % Try to optimize again
            [tspsol,fval,exitflag,output] = solve(tsp,'options',opts);

            % How many subtours this time?
            tours = detectSubtours(tspsol.trips,idxs);
            numtours = length(tours); % number of subtours
            fprintf('# of subtours: %d\n',numtours);
        end
        tours2 = cell2mat(tours);
        backgroundIndSorted = backgroundInd(tours2)
        
        
        BW = lazysnapping(image,SP1,forgroundInd,backgroundIndSorted,...
            'EdgeWeightScaleFactor',750);

        imshow(Leaf)
        hold on
        plot(forgroundPoints(:,1),forgroundPoints(:,2),'g*')
        plot(PointsOutPoly(:,1),PointsOutPoly(:,2),'r*')
%         plot(lines(backgroundIndSorted));
        
        maskedImage = image;
        maskedImage(repmat(~BW,[1 1 3])) = 0;

        imshow(maskedImage)
    end
BINARY = im2bw(maskedImage,.1);
% Only show 5 largest objects
BINARY_OBJECT = bwareafilt(BINARY,5);
% Calculate the area of the leaf selected in step 2
%       if area of different leaf is desired, remove
%       ",handles.LEAF_INDICES(:,1),handles.LEAF_INDICES(:,2)"
AREA_IMAGE = bwselect(BINARY_OBJECT,forgroundPoints(:,1),forgroundPoints(:,2),4);
Binary = AREA_IMAGE;
AREA_P = bwarea(AREA_IMAGE);
PERIMETER_P = struct2array(regionprops(AREA_IMAGE,'Perimeter'));
PERIMETER = round(PERIMETER_P/(DIST/SCALE),3);
handles.Perimeter = PERIMETER;
% Convert pixel area to cm^2
handles.AREA_cm = (1/(DIST/SCALE)^2)*AREA_P;
handles.AREA_cm_report = round(AREA_cm,3); % Use this for exact area, rounded to 3 decimal points
% Show side-by-side comparison of original/mask
% Insert area on top of selected leaf
position = [mean(forgroundPoints(:,1)),mean(forgroundPoints(:,2))];
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
        
        
        
        
        
        
        
        
        
        imshow(Leaf)
        hold on
        plot(leaf_Centers(:,1),leaf_Centers(:,2),'c*')
        plot(skel_Centers(:,1),skel_Centers(:,2),'g*')
        plot(forground(:,1),forground(:,2),'r*')
        plot(backgroundPoints(:,1),backgroundPoints(:,2),'y*')
        
    %end
   
    imshow(Leaf)
    hold on
    plot(background(:,1),background(:,2),'c*')
    plot(leaf_Centers(:,1),leaf_Centers(:,2),'c*')
    plot(skel_Centers(:,1),skel_Centers(:,2),'g*')

h1 = impoly(gca,[34,298;114,140;195,135;...
    259,200;392,205;467,283;483,104],'Closed',false);
foresub = getPosition(h1);
foregroundInd = sub2ind(size(image),foresub(:,2),foresub(:,1));
    
    
    
    
    % Plot options
    if nClasses == 7
        PLOT = [image,Leaf2,Stem,Text_Black;
            B,Fruit_Flower,Background2,image];
    elseif nClasses == 6
        PLOT = [image,Leaf2,Stem,Text_Black;
            B,Fruit_Flower,Background2,image];
    else
        PLOT = [image,Leaf2,Stem,Text_Black;
            B,Fruit_Flower,Background2,image];
    end
    
    % Output
    destDir = fullfile(destinationDirectory,filename);
    imwrite(PLOT,destDir);
end




