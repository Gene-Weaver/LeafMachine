
%%%% Dev for dealing with multiple leaves per image
n = load('Networks/LeafMachine_SegNet_v1.mat');  
net = n.LeafMachine_SegNet_v1;
imgAvg = 'D:\Dropbox\ML_Project\LeafMachine\Networks\Training_Images\Low_Res\LR_Whole\Aceraceae_Acer_glabrum.jpg';
imgAvg2 = 'D:\Dropbox\ML_Project\LeafMachine\Networks\Training_Images\Low_Res\LR_Whole\Fagaceae_Quercus_velutina.jpg';
imgLong = 'D:\Dropbox\ML_Project\LeafMachine\Networks\Training_Images\Low_Res\LR_Whole\Agavaceae_Yucca_baccata.jpg';
imgHuge = 'D:\Dropbox\ML_Project\LeafMachine\Networks\Training_Images\Low_Res\LR_Whole\Asteraceae_Wyethia_helenioides.jpg';
imgThin = 'D:\Dropbox\ML_Project\LeafMachine\Networks\Training_Images\Low_Res\LR_Whole\Juncaceae_Luzula_subcapitata.jpg';
imgTiny = 'D:\Dropbox\ML_Project\LeafMachine\Networks\Training_Images\Low_Res\LR_Whole\Ericaceae_Vaccinium_cespitosum.jpg';

img = {imgAvg,imgLong,imgHuge,imgThin,imgTiny};
rgbImg = imread(imgAvg);
rgbImg2 = imread(imgAvg2);
rgbImg3 = imread(imgHuge);
% Segmentation
[imgOut1,C1,score1,allScores1] = basicSegmentation(net,'test1.jpg','DELETE_LATER',img{1},'cpu');
[imgOut2,C2,score2,allScores2] = basicSegmentation(net,'test2.jpg','DELETE_LATER',img{2},'cpu');
[imgOut3,C3,score3,allScores3] = basicSegmentation(net,'test3.jpg','DELETE_LATER',img{3},'cpu');
[imgOut4,C4,score4,allScores4] = basicSegmentation(net,'test4.jpg','DELETE_LATER',img{4},'cpu');
[imgOut5,C5,score5,allScores5] = basicSegmentation(net,'test5.jpg','DELETE_LATER',img{5},'cpu');
binaryMasks1 = getBinaryMasks(C1);
binaryMasks2 = getBinaryMasks(C2);
binaryMasks3 = getBinaryMasks(C3);
binaryMasks4 = getBinaryMasks(C4);
binaryMasks5 = getBinaryMasks(C5);
binaryMasks = {binaryMasks1,binaryMasks2,binaryMasks3,binaryMasks4,binaryMasks5};

% Retrieve binary masks
% Stem = C == 'Stem';
% Stem = 255 * repmat(uint8(Stem), 1, 1, 3);
% Leaf = C == 'Leaf';
% Leaf = 255 * repmat(uint8(Leaf), 1, 1, 3);
% Text_Black = C == 'Text_Black';
% Text_Black = 255 * repmat(uint8(Text_Black), 1, 1, 3);
% Fruit_Flower = C == 'Fruit_Flower';
% Fruit_Flower = 255 * repmat(uint8(Fruit_Flower), 1, 1, 3);
% Background = C == 'Background';
% Background = 255 * repmat(uint8(Background), 1, 1, 3);
% binaryImages = {Leaf,Background,Stem,Text_Black,Fruit_Flower};
binaryImages = getBinaryImages(C);

% for feature = 1:5
%     imshow(binaryMasks{feature})
% end

BW = binaryMasks{1}{1};

r = 30;
n = 4;
SE1 = strel('diamond',r);
SE2 = strel('disk',r,n);
SE3 = strel('octagon',r);
SE4 = strel('line',r,0);%Long leaves
SE5 = strel('line',r,45);%Long leaves
SE6 = strel('line',r,90);%Long leaves
SE7 = strel('line',r,135);%Long leaves
SE = {SE1,SE2,SE3,SE4,SE5,SE6,SE7};
for i = 1:4
    for ii = 1:7
        erode = imerode(binaryMasks{i}{1},SE{ii});
        figure, imshow(erode)
    end
end


% Get composite of "line strel" imerode masks
compositeLine = fuseLineBinary(binaryMasks{1},SE,1);
imshow(compositeLine)
% erode0 = imerode(binaryMasks{4}{1},SE{4});
% erode45 = imerode(binaryMasks{4}{1},SE{5});
% erode90 = imerode(binaryMasks{4}{1},SE{6});
% erode135 = imerode(binaryMasks{4}{1},SE{7});
% 
% compositeLineDouble = erode0+erode45+erode90+erode135;
% compositeLine = logical(compositeLineDouble);
% imshow(compositeLine)

% Get INTERSECTION of globular imerode masks
compositeGlobular = fuseGlobularBinary(binaryMasks{1},SE,1);
imshow(compositeGlobular)
% diamond = imerode(binaryMasks{4}{1},SE{1});
% disk = imerode(binaryMasks{4}{1},SE{2});
% octagon = imerode(binaryMasks{4}{1},SE{3});
% compositeGlobularDouble = diamond+disk+octagon;
% maxVal = max(max(compositeGlobularDouble));
% compositeGlobularDoubleMax = compositeGlobularDouble == maxVal;
% compositeGlobular = logical(compositeGlobularDoubleMax);

% Intersection *These were redundant
% compositeBinaryMin1= compositeLine+compositeGlobular;
% maxVal = max(max(compositeBinaryMin1));
% compositeBinaryMin2 = compositeBinaryMin1 == maxVal;
% compositeBinaryMin = logical(compositeBinaryMin2);
% imshow(compositeBinaryMin)
% % Union
% compositeBinaryMax1= compositeLine+compositeGlobular;
% compositeBinaryMax = logical(compositeBinaryMax1);
% imshow(compositeBinaryMax)


% All of the above
% ======== Main Function ================
for i = 1:length(img)
    IMG = imread(img{i});
    [compositeGlobular,compositeLine,globData,lineData] = findLeavesBinaryStrel(IMG,C1,1,30,4);
end

% Count # of blobs i.e. potential solitary leaves. In the future this will
% be as SVM task
[labelGlob, nGlob] = bwlabel(compositeGlobular);
[labelLine, nLine] = bwlabel(compositeLine);

% globAreas = regionprops(labelGlob, 'Area');
% lineAreas = regionprops(labelLine, 'Area');


% [globData,lineData] = runLazySnappingForBlobs(labelGlob,labelLine,nGlob,nLine,imread(img{1}));
% imshow(lineData{6}{1})


% Isolate skels for each blob ~5 seconds
%%% Glob version 
globID = cell(1,nGlob);
globSkel = cell(1,nGlob);
globNode = cell(1,nGlob);
globBox = cell(1,nGlob);
globSP = cell(1,nGlob);
globLS = cell(1,nGlob);
globCropLS = cell(1,nGlob);
img = imread(img{1});
for i = 1:nGlob
    globBox{i} = regionprops(labelGlob==i,'Area', 'BoundingBox');
    % Crop to quicken lazy snap
    bound = round(globBox{i}.BoundingBox);
    bound2 = [bound(1)-70 bound(2)-70 bound(3)+140 bound(4)+140];
    imgCrop = imcrop(img,bound2);
    labelGlobCrop = imcrop(labelGlob,bound2);

    % Skeletonize and get nodes
    globSkel{i} = bwmorph(labelGlobCrop==i,'skel',Inf);
    globNode{i} = bwmorph(globSkel{i},'branchpoints');
    %BW2 = bwulterode(labelGlobCrop==i,'quasi-euclidean')

    % Get Background Indices
    [cX,cY,cZ] = size(imgCrop);
    [dimX,dimY,SPS] = setBackgoundPoints(cX,cY);
    backgroundInd = sub2ind([cX,cY,cZ],dimY,dimX);
    % Get leaf indices
    [y, x] = find(globNode{i});
    foregroundInd = sub2ind([cX,cY,cZ],y,x);

    % Superixels and lazysnapping
    globSP{i} = superpixels(imgCrop,SPS);% 200, 500, 1000, 1200, 1500, hyper 2000
    LS = lazysnapping(imgCrop,globSP{i},foregroundInd,backgroundInd,'EdgeWeightScaleFactor',750);
    globLS{i} = LS;

    % Show leaf
    imgCrop(repmat(~LS,[1 1 3])) = 0;
    globCropLS{i} = imgCrop;
    
    % Binarize output from lazysnapping
    imgCropBinary = imbinarize(rgb2gray(imgCrop));
    
    % Take only largest blog if there are multiple
    imgCropBinaryMessy = bwareafilt(imgCropBinary,1);
    imshow(imgCropBinaryMessy)

    % Shrink leaf to find outliers, used for mask in imimposemin()
    mask = imerode(imgCropBinaryMessy,strel('octagon',9));
    
    % Watershed segmentation prep
    W = -bwdist(~imgCropBinaryMessy,'quasi-euclidean');
    W(~imgCropBinaryMessy) = -inf;  
    
    % Correct oversegmentation 
    mask2 = imimposemin(W,mask);
    W2 = watershed(mask2);
    cleanLeaf = imgCropBinaryMessy;
    cleanLeaf(W2 == 0) = 0;

    % Keep only larest object
    cleanLeaf = bwareafilt(cleanLeaf,1);
    
    % Fill small holes
    cleanLeaf = imfill(cleanLeaf,'holes');

    imshow(cleanLeaf)
    
    
    % *** Below goes in measureLeafFeatures()
    % Get area
    cleanLeaf_Area = bwarea(cleanLeaf);
    % Get Perimeter
    [rowsP, columnsP] = find(bwperim(cleanLeaf));
    cleanLeaf_Perimeter = struct2array(regionprops(cleanLeaf,'Perimeter'));
    cleanLeaf_Centroid = struct2array(regionprops(cleanLeaf,'Centroid'));
    cleanLeaf_Centroid = [cleanLeaf_Centroid(1,1)+bound2(1),cleanLeaf_Centroid(1,2)+bound2(2)];
    cleanLeaf_PerimeterOverlay = [columnsP+bound2(1),rowsP+bound2(2)];
    
    
    imshow(img)
    hold on
    scatter(cleanLeaf_PerimeterOverlay(:,1),cleanLeaf_PerimeterOverlay(:,2),3,pickColor(1,COLOR))
    T = ['Leaf(',num2str(i),')','A:',num2str(cleanLeaf_Area),'-','P:',num2str(cleanLeaf_Perimeter)]
    
    insertText(img,cleanLeaf_Centroid,text_str,'FontSize',18,'BoxColor',box_color,'BoxOpacity',0.4,'TextColor','white');
    
    
    % Get area
    cleanLeaf_Area = bwarea(cleanLeaf);
    

    
    

end




% Test mechanics of enlarging bounding box
AAA = round(lineBox{2}.BoundingBox);
imgCrop = imcrop(imread(img{1}),AAA);
figure,imshow(imgCrop)
imgCrop = imcrop(imread(img{1}),[AAA(1)-50 AAA(2)-50 AAA(3)+100 AAA(4)+100]);
figure,imshow(imgCrop)

% Get Background Indices
[cX,cY,cZ] = size(imgCrop)
dimX = [5;5;cY-5;cY-5]
dimY = [5;cX-5;cX-5;5]
backgroundInd = sub2ind([cX,cY,cZ],dimY,dimX)

% Get leaf indices
AAA = bwmorph(bwmorph(labelLine==1,'skel',Inf),'branchpoints');
foregroundInd = sub2ind([cX,cY,cZ],dimYY,dimXX)


% From GUI_Auto_Distance
% imshow(imgCrop)
% [FOREGROUNDx, FOREGROUNDy] = getpts();
% h1 = impoly(gca,[round(FOREGROUNDx),round(FOREGROUNDy)],'Closed',false);
% foresub = getPosition(h1);
% foregroundInd = sub2ind(size(imgCrop),foresub(:,2),foresub(:,1));

SP = superpixels(imgCrop,500);% 200, 500, 1000, 1200, 1500, hyper 2000
LS = lazysnapping(imgCrop,SP,foregroundInd,backgroundInd,'EdgeWeightScaleFactor',750);


    lineBox{1} = regionprops(labelLine==2,'Area', 'BoundingBox');
    % Crop to quicken lazy snap
    bound = round(lineBox{1}.BoundingBox);
    bound2 = [bound(1)-50 bound(2)-50 bound(3)+100 bound(4)+100];
    imgCrop = imcrop(rgbImg,bound2);
    labelLineCrop = imcrop(labelLine,bound2);
    
    lineSkel{1} = bwmorph(labelLineCrop==1,'skel',Inf);
    lineNode{1} = bwmorph(lineSkel{1},'branchpoints');
    
    % Get Background Indices
    [cX,cY,cZ] = size(imgCrop);
    dimX = [5;5;cY-5;cY-5];
    dimY = [5;cX-5;cX-5;5];
    backgroundInd = sub2ind([cX,cY,cZ],dimY,dimX);
    % Get leaf indices
    [y, x] = find(lineNode{1});
    foregroundInd = sub2ind([cX,cY,cZ],y,x)
    
    SP = superpixels(imgCrop,500);% 200, 500, 1000, 1200, 1500, hyper 2000
    LS = lazysnapping(imgCrop,SP,foregroundInd,backgroundInd,'EdgeWeightScaleFactor',750);

    
    BINARY = logical(maskedImage,.1);
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







% Cooresponding parameters
item.Filename = 'filename';
item.Species = 'Ginko_biloba';
item.LeafID = 4;
item.PixelDistance = 423;
item.PixelArea = 4235;
item.PixelPerimeter = 4425;
item.MetricDistance = 3;
item.MetricArea = 44;
item.MetricPerimeter = 345;
item.FeatureCoordinates = [23 100 100 22];
item.TickMarksFound = 99;
item.MaskOpts = 50;
item.MeasurementType = 'Automated';
item.FilenameRuler = 'Ruler.jpg';
item.ImageDim = [1200,2000,3];
item.TimeStamp = '9/8/2017  11:37:00 AM';
item.ProcessingDuration = 200;

T = {item.Filename,item.Species,item.LeafID,item.PixelDistance,item.PixelArea,item.PixelPerimeter,...
     item.MetricDistance,item.MetricArea,item.MetricPerimeter,item.FeatureCoordinates,item.TickMarksFound,item.MaskOpts,...
     item.MeasurementType,item.FilenameRuler,item.ImageDim,item.TimeStamp,item.ProcessingDuration};
                           
% Variable names
colNames = {'Filename','Species','LeafID','PixelDistance','PixelArea','PixelPerimeter',...
                               'MetricDistance','MetricArea','MetricPerimeter','FeatureCoordinates','TickMarksFound','MaskOpts',...
                               'MeasurementType','FilenameRuler','ImageDim','TimeStamp','ProcessingDuration'};
                           
T2 = cell2table(T);
T2.Properties.VariableNames = colNames;
writetable(T2,'test.xlsx')

for i=1:10
    item(i).Filename = strcat('F',int2str(i));
end
