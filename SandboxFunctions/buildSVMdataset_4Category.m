%%%     Build SVM dataset - 4 Categories ~4 hours for 200,000 images
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


%% For Good Leaves
outDir = fullfile('D:\Dropbox\ML_Project\Image_Database\DwC_10RandImg_SVM_4Category');
if ~exist(outDir, 'dir')
   mkdir(outDir)
end

% DwC_10RandImg parameters for matching binary image with data about the
% full res parent image
matchInfo = readtable('D:\Dropbox\ML_Project\Image_Database\DwC_10RandImg_SVM_4Category\DwC_10RandImg_SVM_parameters.xlsx');

% Loop through 4 categories
categoriesI = {'\leaf' '\notLeaf' '\partialLeaf' '\clump'};
categories = {'leaf' 'notLeaf' 'partialLeaf' 'clump'};

% Count nImages to be processed for table preallocation
nImages = 0;
for i = 1:length(categoriesI)
    baseFolder = fullfile('D:\Dropbox\ML_Project\Image_Database\DwC_10RandImg_SVM_4Category_Images', categoriesI{i});
    nImages = nImages + length(dir(fullfile(baseFolder, '*.png')));
end

% Set output headers
headers = {'category','id','family','megapixels','area','bbRatio','majorAxisLen','minorAxisLen','eccentricity','eqDiameter','extent','roundness','perimeter'};
data = cell(nImages,length(headers));
parametersLeaf = cell2table(data);
parametersLeaf.Properties.VariableNames = headers;

f = waitbar(0,"Categories");
ff = waitbar(0,"Files in Category");
IND = 0;
for i = 1:length(categoriesI) %%% Loop through each of the 4 categories 
    f = waitbar(i/length(categoriesI),f,"Categories");
    % Get category
    baseFolder = fullfile('D:\Dropbox\ML_Project\Image_Database\DwC_10RandImg_SVM_4Category_Images', categoriesI{i});
    files = dir(fullfile(baseFolder, '*.png'));
    
    saveName = ['DwC_10RandImg_',categories{i}];
    fprintf('Processing folder %s\n', saveName);
    
    for p = 1:length(files) %%% Loop through each file in the category
        ff = waitbar(p/length(files),ff,"Files in Category");
        IND = IND + 1;
        img = imread(fullfile(files(p).folder,files(p).name));

        % Process binary img
        img = bwareafilt(img,1);
        img = imfill(img,'holes');
        values = regionprops(img,'Area','BoundingBox','MajorAxisLength','MinorAxisLength','Eccentricity','EquivDiameter','Extent','Perimeter');

        % Save values
        n = strsplit(files(p).name,'.');
        nn = strsplit(n{1},'_');
        nID = nn{2};
        
        % High res t/f
        highRes = ismember('H',nn);
        
        % Family & Megapixel selection
        preMatch = matchInfo(matchInfo.id == str2double(nID),:);
        if height(preMatch) == 2
            if highRes % high res
                if preMatch.megapixels(1) > preMatch.megapixels(2) % first row is high res
                    parametersLeaf.family{IND} = preMatch.family(1);
                    parametersLeaf.megapixels{IND} = preMatch.megapixels(1);
                elseif preMatch.megapixels(1) < preMatch.megapixels(2) % second row is high res
                    parametersLeaf.family{IND} = preMatch.family(2);
                    parametersLeaf.megapixels{IND} = preMatch.megapixels(2);
                elseif preMatch.megapixels(1) == preMatch.megapixels(2) % same res for both
                    parametersLeaf.family{IND} = preMatch.family(1);
                    parametersLeaf.megapixels{IND} = preMatch.megapixels(1);
                end
            else % low res
                if preMatch.megapixels(1) > preMatch.megapixels(2) % first row is high res
                    parametersLeaf.family{IND} = preMatch.family(2);
                    parametersLeaf.megapixels{IND} = preMatch.megapixels(2);
                elseif preMatch.megapixels(1) < preMatch.megapixels(2) % second row is high res
                    parametersLeaf.family{IND} = preMatch.family(1);
                    parametersLeaf.megapixels{IND} = preMatch.megapixels(1);
                elseif preMatch.megapixels(1) == preMatch.megapixels(2) % same res for both
                    parametersLeaf.family{IND} = preMatch.family(1);
                    parametersLeaf.megapixels{IND} = preMatch.megapixels(1);
                end
            end
        elseif height(preMatch) == 1
            parametersLeaf.family{IND} = preMatch.family(1);
            parametersLeaf.megapixels{IND} = preMatch.megapixels(1);
        else
            sprintf("More than 2 matches in matchInfo")
        end
        
        % Other parameters
        parametersLeaf.category{IND} = categories{i};
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
    tempSaveName = ['DwC_10RandImg_SVM_Dataset_',categories{i},'.xlsx'];
    writetable(parametersLeaf,fullfile(outDir,tempSaveName));
end
writetable(parametersLeaf,fullfile(outDir,'DwC_10RandImg_SVM_Dataset.xlsx'));

close(f);
close(ff);
