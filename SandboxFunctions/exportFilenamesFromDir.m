%% Simple
% Img Dir
Directory = "/home/brlab/Dropbox/ML_Project/Image_Database/LeafMachine_Validation_Images/Manuscript_Vouchers/COLO_CatalogID_LRFR_Matching/COLO_LR_Out/Segmentation";
imgFiles = dir(char(Directory));
imgFiles = imgFiles(~ismember({imgFiles.name},{'.','..'}));
fLen = length(imgFiles);

filenames = struct2table(imgFiles);

writetable(filenames,"/home/brlab/Dropbox/ML_Project/Image_Database/LeafMachine_Validation_Images/Manuscript_Vouchers/Manuscript_Image_Names_COLO.xlsx")

Directory = "/home/brlab/Dropbox/ML_Project/Image_Database/LeafMachine_Validation_Images/Manuscript_Vouchers/RhodesFullRes_SelectFamilies/Segmentation";
imgFiles = dir(char(Directory));
imgFiles = imgFiles(~ismember({imgFiles.name},{'.','..'}));
fLen = length(imgFiles);

filenames = struct2table(imgFiles);

writetable(filenames,"/home/brlab/Dropbox/ML_Project/Image_Database/LeafMachine_Validation_Images/Manuscript_Vouchers/Manuscript_Image_Names_Rhodes.xlsx")
%% Herb Dir
dirDirectory = "/home/brlab/Dropbox/ML_Project/Image_Database/DwC";
dirFiles = dir(char(dirDirectory));
dirFiles = dirFiles(~ismember({dirFiles.name},{'.','..'}));
fLenDir = length(dirFiles);

dirNames = struct2table(dirFiles);
dirNamesShort = [];
for j = 1:fLenDir
    temp = strsplit(dirNames.name{j},["-","_"]);
    dirNamesShort{j}  = temp{1};
end

% Img Dir
Directory = "/home/brlab/Dropbox/ML_Project/Image_Database/DwC_10RandImg";
imgFiles = dir(char(Directory));
imgFiles = imgFiles(~ismember({imgFiles.name},{'.','..'}));
fLen = length(imgFiles);

filenames = struct2table(imgFiles);

headers = {'HerbCode','coreID','coreIDocc','indexImages','indexOcc','catalogNumber','urlFR','urlLR'};
filenamesOUTdata = cell(fLen,length(headers));
filenamesOUT = cell2table(filenamesOUTdata);
filenamesOUT.Properties.VariableNames = headers;


runningHerbID = "NA";
imagesFile = [];
occFile = [];
COUNT = 1;
for i=1:fLen
    file = filenames.name{i};
    parts = strsplit(file,["_","."]);
    HerbID = string(parts{1});
    coreID = string(parts{2});
    coreIDn = double(parts{2});
    
    [~,ind] = ismember(HerbID,dirNamesShort);
    if HerbID ~= runningHerbID
        formatSpec = "Getting new files... OLD: %s --- NEW: %s \n";
        fprintf(formatSpec,runningHerbID,HerbID)
        
        runningHerbID = HerbID;
        imagesFile = readtable(fullfile(fullfile(dirNames.folder{ind},dirNames.name{ind}),"images.csv"));
        opts = detectImportOptions(fullfile(fullfile(dirNames.folder{ind},dirNames.name{ind}),"occurrences.csv"));
        opts = setvartype(opts,{'id','catalogNumber'},{'double','char'});
        occFile = readtable(fullfile(fullfile(dirNames.folder{ind},dirNames.name{ind}),"occurrences.csv"),opts);
        
        COUNT = 1;
    elseif COUNT >= 20
        formatSpec = "Getting new files!!! OLD: %s --- NEW: %s \n";
        fprintf(formatSpec,runningHerbID,HerbID)
        
        runningHerbID = HerbID;
        imagesFile = readtable(fullfile(fullfile(dirNames.folder{ind+1},dirNames.name{ind+1}),"images.csv"));
        opts = detectImportOptions(fullfile(fullfile(dirNames.folder{ind+1},dirNames.name{ind+1}),"occurrences.csv"));
        opts = setvartype(opts,{'id','catalogNumber'},{'double','char'});
        occFile = readtable(fullfile(fullfile(dirNames.folder{ind+1},dirNames.name{ind+1}),"occurrences.csv"),opts);
        
        COUNT = 1;
    else
        formatSpec = "Processing Herb %s Image %s \n";
        fprintf(formatSpec,HerbID,coreID)
        
        runningHerbID = HerbID;
        imagesFile = imagesFile;
        occFile = occFile;
        COUNT = COUNT+1;
    end
    indexImages = find(imagesFile.coreid==double(coreID));
    indexOcc = find(occFile.id == double(coreID));
    if length(indexImages) >1;indexImages = indexImages(1);end
    if length(indexOcc) >1;indexOcc = indexOcc(1);end
    
    try
        coreIDocc = occFile.id{indexOcc};
    catch
        coreIDocc = occFile.id(indexOcc);
    end
    
    try
        catalogNumber = occFile.catalogNumber{indexOcc};
    catch
        catalogNumber = occFile.catalogNumber(indexOcc);
    end
    
    urlFR = imagesFile.accessURI{indexImages};
    urlLR = imagesFile.goodQualityAccessURI{indexImages};
    
    filenamesOUT.HerbCode{i} = HerbID;
    filenamesOUT.coreID{i} = coreID;
    filenamesOUT.coreIDocc{i} = coreIDocc;
    filenamesOUT.indexImages{i} = indexImages;
    filenamesOUT.indexOcc{i} = indexOcc;
    filenamesOUT.catalogNumber{i} = catalogNumber;
    filenamesOUT.urlFR{i} = urlFR;
    filenamesOUT.urlLR{i} = urlLR;
    
end
writetable(filenamesOUT,"/home/brlab/Dropbox/ML_Project/Image_Database/LeafMachine_Validation_Images/Manuscript_Vouchers/Manuscript_Details_for_DwC10RandImg.xlsx")