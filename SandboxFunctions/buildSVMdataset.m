%%%     Build SVM dataset
%%%     Developed for LeafMachine.org
%%%
%%%     William Weaver
%%%     University of Colorado, Boulder
%%%     Department of Ecology and Evolutionary Biology

% Bag Classification Using Support Vector Machines
% Uri Kartoun, Helman Stern, Yael Edan
% https://scholar.harvard.edu/files/kartoun/files/1ca003_225e1f90fc02d788a6a390665a58091b.pdf

% Open folders, rename each image, store new name as entry in table,
% calculate Area, BBox Ratio, Major Axis Length, Minor Axis
% Length, Eccentricity, Equivalent Diameter, Extent, Roundness, Convex Perimeter

%% For rulerID SVM
outDir = fullfile('D:\Dropbox\ML_Project\Image_Database\DwC_10RandImg_SVM_Rulers_Cropped_binaryAdaptiveForegroundPolarity');
if ~exist(outDir, 'dir')
   mkdir(outDir)
end
baseFolder = fullfile('D:\Dropbox\ML_Project\Image_Database\DwC_10RandImg__Rulers_Cropped_binaryAdaptiveForegroundPolarity');

imgFiles = dir(char(baseFolder));
imgFiles = imgFiles(~ismember({imgFiles.name},{'.','..'}));
fLenI = length(imgFiles);
fLen = string(fLenI);

headers = {'id','class','area','areaI','majorAxisLen','majorAxisLenI','minorAxisLen','minorAxisLenI',...
    'eccentricity','eccentricityI','eqDiameter','eqDiameterI','count','countI','avgBbox','avgBboxI'};
data = cell(fLenI,16);
parametersRuler = cell2table(data);
parametersRuler.Properties.VariableNames = headers;



for k = 1:fLenI
    k
    file = fullfile(imgFiles(k).folder,imgFiles(k).name);
    
    img = imread(file);

    % Process binary img
    values = regionprops(imcomplement(img),'Area','BoundingBox','MajorAxisLength','MinorAxisLength','Eccentricity','EquivDiameter');
    [labeledImage, nObjects] = bwlabel(imcomplement(img));
    
    valuesInverted = regionprops(img,'Area','BoundingBox','MajorAxisLength','MinorAxisLength','Eccentricity','EquivDiameter');
    [labeledImageInverted, nObjectsInverted] = bwlabel(img);

    BB = [];
    BBi = [];
    for i = 1 : length(values)
        BB{i} = values(i).BoundingBox(3)/values(i).BoundingBox(4);
    end
    for i = 1 : length(valuesInverted)
        BBi{i} = valuesInverted(i).BoundingBox(3)/valuesInverted(i).BoundingBox(4);
    end
    BB = cell2mat(BB);
    BBi = cell2mat(BBi);
    
    % Save values
    n = strsplit(imgFiles(k).name,'.');
    nn = strsplit(imgFiles(k).name,'__');
    parametersRuler.id{k} = n(1);
    parametersRuler.class{k} = nn(1);
    parametersRuler.area{k} = nanmean([values.Area]);
    parametersRuler.majorAxisLen{k} = nanmean([values.MajorAxisLength]);
    parametersRuler.minorAxisLen{k} = nanmean([values.MinorAxisLength]);
    parametersRuler.eccentricity{k} = nanmean([values.Eccentricity]);
    parametersRuler.eqDiameter{k} = nanmean([values.EquivDiameter]);
    parametersRuler.avgBbox{k} = harmmean(BB, 'omitnan');
    parametersRuler.count{k} = length(values);
    
    parametersRuler.areaI{k} = nanmean([valuesInverted.Area]);
    parametersRuler.majorAxisLenI{k} = nanmean([valuesInverted.MajorAxisLength]);
    parametersRuler.minorAxisLenI{k} = nanmean([valuesInverted.MinorAxisLength]);
    parametersRuler.eccentricityI{k} = nanmean([valuesInverted.Eccentricity]);
    parametersRuler.eqDiameterI{k} = nanmean([valuesInverted.EquivDiameter]);
    parametersRuler.avgBboxI{k} = harmmean(BBi, 'omitnan');
    parametersRuler.countI{k} = length(valuesInverted);
   
    
end
writetable(parametersRuler,fullfile(outDir,'SVM_Data_Rulers_Cropped_binaryAdaptiveForegroundPolarity.xlsx'));


%% For Good Leaves
outDir = fullfile('D:\Dropbox\ML_Project\Image_Database\Leafsnap_SVM');
if ~exist(outDir, 'dir')
   mkdir(outDir)
end
baseFolder = fullfile('D:\Dropbox\ML_Project\Image_Database\Leafsnap_SVM', '\Leafsnap_Leaf');
subFolders = genpath(baseFolder);
%subFolders = baseFolder;
subFolders_0 = subFolders;

headers = {'id','area','bbRatio','majorAxisLen','minorAxisLen','eccentricity','eqDiameter','extent','roundness','perimeter'};
data = cell(10000,10);
parametersLeaf = cell2table(data);
parametersLeaf.Properties.VariableNames = headers;

listOfFolderNames_Location = {};
while true
	[singleSubFolder, subFolders_0] = strtok(subFolders_0, ';');
	if isempty(singleSubFolder)
		break;
	end
	listOfFolderNames_Location = [listOfFolderNames_Location singleSubFolder];
end
numberOfFolders_Location = length(listOfFolderNames_Location);


IND = 0;
% Get info from DwC files
for k = 2 : numberOfFolders_Location
	% Get this folder and print it out.
	thisFolder = listOfFolderNames_Location{k};
    parsing = strsplit(thisFolder,'\');
    lp = length(parsing);
    saveName1 = parsing{lp};
    saveName2 = parsing{lp-1};
    saveName3 = parsing{lp-2};
    saveName = [saveName3,'_',saveName2,'_',saveName1];
    
    % ***Begin everything
    fprintf('Processing folder %s\n', saveName);
    
    files = dir(fullfile(thisFolder, '*.png'));
       
    for p = 1:length(files)
        IND = IND + 1;
        img = imread(fullfile(files(p).folder,files(p).name));
        
        % Process binary img
        img = bwareafilt(img,1);
        img = imfill(img,'holes');
        values = regionprops(img,'Area','BoundingBox','MajorAxisLength','MinorAxisLength','Eccentricity','EquivDiameter','Extent','Perimeter');

        % Save values
        n = strsplit(files(p).name,'.');
        parametersLeaf.id{IND} = strjoin([saveName,'_',n(1)],'');
        parametersLeaf.area{IND} = values.Area;
        parametersLeaf.bbRatio{IND} = values.BoundingBox(3)/values.BoundingBox(4);
        parametersLeaf.majorAxisLen{IND} = values.MajorAxisLength;
        parametersLeaf.minorAxisLen{IND} = values.MinorAxisLength;
        parametersLeaf.eccentricity{IND} = values.Eccentricity;
        parametersLeaf.eqDiameter{IND} = values.EquivDiameter;
        parametersLeaf.extent{IND} = values.Extent;
        parametersLeaf.roundness{IND} = (values.Perimeter .^ 2) ./ (4 * pi * values.Area);
        parametersLeaf.perimeter{IND} = values.Perimeter;
        
    end 
    
end
writetable(parametersLeaf,fullfile(outDir,'leafsnapSVM_Leaf.xlsx'));

%% For Bad Leaves/junk
outDir = fullfile('D:\Dropbox\ML_Project\Image_Database\Leafsnap_SVM\SVM_smallTest');
baseFolder = fullfile('D:\Dropbox\ML_Project\Image_Database\Leafsnap_SVM', '\SVM_smallTest');
subFolders = genpath(baseFolder);
%subFolders = baseFolder;
subFolders_0 = subFolders;

headers = {'id','area','bbRatio','majorAxisLen','minorAxisLen','eccentricity','eqDiameter','extent','roundness','perimeter'};
data = cell(10000,10);
parametersLeaf = cell2table(data);
parametersLeaf.Properties.VariableNames = headers;

listOfFolderNames_Location = {};
while true
	[singleSubFolder, subFolders_0] = strtok(subFolders_0, ';');
	if isempty(singleSubFolder)
		break;
	end
	listOfFolderNames_Location = [listOfFolderNames_Location singleSubFolder];
end
numberOfFolders_Location = length(listOfFolderNames_Location);


IND = 0;
% Get info from DwC files
for k = 2 : numberOfFolders_Location
	% Get this folder and print it out.
	thisFolder = listOfFolderNames_Location{k};
    parsing = strsplit(thisFolder,'\');
    lp = length(parsing);
    saveName1 = parsing{lp};
    saveName2 = parsing{lp-1};
    saveName3 = parsing{lp-2};
    saveName = [saveName3,'_',saveName2,'_',saveName1];
    
    % ***Begin everything
    fprintf('Processing folder %s\n', saveName);
    
    files = dir(fullfile(thisFolder, '*.png'));
       
    for p = 1:length(files)
        IND = IND + 1;
        img = imread(fullfile(files(p).folder,files(p).name));
        
        % Process binary img
        img = bwareafilt(img,1);
        img = imfill(img,'holes');
        values = regionprops(img,'Area','BoundingBox','MajorAxisLength','MinorAxisLength','Eccentricity','EquivDiameter','Extent','Perimeter');
        % circularity = (values.Perimeter .^ 2) ./ (4 * pi * values.Area);
        % values_bbox_ratio = values.BoundingBox(3)/values.BoundingBox(4);

        % Save values
        n = strsplit(files(p).name,'.');
        parametersLeaf.id{IND} = strjoin([saveName,'_',n(1)],'');
        parametersLeaf.area{IND} = values.Area;
        parametersLeaf.bbRatio{IND} = values.BoundingBox(3)/values.BoundingBox(4);
        parametersLeaf.majorAxisLen{IND} = values.MajorAxisLength;
        parametersLeaf.minorAxisLen{IND} = values.MinorAxisLength;
        parametersLeaf.eccentricity{IND} = values.Eccentricity;
        parametersLeaf.eqDiameter{IND} = values.EquivDiameter;
        parametersLeaf.extent{IND} = values.Extent;
        parametersLeaf.roundness{IND} = (values.Perimeter .^ 2) ./ (4 * pi * values.Area);
        parametersLeaf.perimeter{IND} = values.Perimeter;
        
    end 
    
end
%writetable(parametersLeaf,fullfile(outDir,'leafsnapSVM_notLeaf.xlsx'));
writetable(parametersLeaf,fullfile(outDir,'SVM_test_baggedTrees_937.xlsx'));
