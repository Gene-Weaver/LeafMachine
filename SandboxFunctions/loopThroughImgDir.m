%% List megapixels for the training DwC dataset

Directory = "D:\Dropbox\ML_Project\Image_Database\DwC_10RandImg"

imgFiles = dir(char(Directory));
imgFiles = imgFiles(~ismember({imgFiles.name},{'.','..'}));
fLen = length(imgFiles);
fLen = string(fLen);

headers = {'filename','MP'};
data = cell(fLen,length(headers));
DwC10RandImg_MP = cell2table(data);
DwC10RandImg_MP.Properties.VariableNames = headers;

I = 1;

for file = imgFiles'
    img0 = char(file.name);
    filename = strsplit(string(img0),".");
    filename = char(filename{1})
    filenameRead = [Directory,string(img0)];
    filenameRead = strjoin(filenameRead,"\");
    img = imread(filenameRead);

    [DimN,DimM,DimZ] = size(img);
    Dim = min(DimN,DimM);
    megapixels = DimN*DimM/1000000;
    
    DwC10RandImg_MP.filename{I} = filename;    
    DwC10RandImg_MP.MP{I} = megapixels;
    I = I + 1;
end
writetable(DwC10RandImg_MP,"D:\Dropbox\ML_Project\Image_Database\LeafMachine_OverviewStats\DwC_10RandImg_MegapixelByFilename.xlsx")

%% Create lists: all COLO low res images, COLO low res in the 20 families w/catalog number in its own column for matching with high res COLO
 
% Directory = "G:\DwC_Archive\DwC_COLO_FixedNames"
% DirectoryOut = "G:\DwC_Archive\DwC_COLO_FixedNames_SelectFamilies"
Directory = "D:\Dropbox\ML_Project\Image_Database\RhodesImages\FullRes";
DirectoryOut = "D:\Dropbox\ML_Project\Image_Database\RhodesImages\FullRes_SelectFamilies";

% Wanted Families
wantedFam = {'Ulmaceae', 'Betulaceae', 'Fagaceae', 'Magnoliaceae','Lauraceae',...
    'Ericaceae', 'Sapindaceae', 'Aceraceae', 'Oleaceae','Myrtaceae', ...
    'Malvaceae', 'Rhamnaceae', 'Salicaceae', 'Caprifoliaceae','Vitaceae',...
    'Adoxaceae', 'Solanaceae','Ginkoaceae','Platanaceae','Anacardiaceae','Cannabaceae'};
wantedFam = upper(wantedFam);

imgFiles = dir(char(Directory));
imgFiles = imgFiles(~ismember({imgFiles.name},{'.','..'}));
fLen = length(imgFiles);
fLen = string(fLen);

headers = {'filename','catalogID','family','MP'};
data = cell(fLen,length(headers));
COLO_LR_SelectFamilies = cell2table(data);
COLO_LR_SelectFamilies.Properties.VariableNames = headers;

data = cell(fLen,length(headers));
COLO_LR_All = cell2table(data);
COLO_LR_All.Properties.VariableNames = headers;

I = 1;
II = 1;

for file = imgFiles'
    img0 = char(file.name);
    filenameWrite = [DirectoryOut,string(img0)];
    filenameWrite = strjoin(filenameWrite,"\");
    filename = strsplit(string(img0),".");
    filename = char(filename{1});
    filenameRead = [Directory,string(img0)];
    filenameRead = strjoin(filenameRead,"\");
    img = imread(filenameRead);
    
    splitID = strsplit(filename,"_");
    try 
        %family = upper(char(splitID(3)));
        family = upper(char(splitID(2)));
    catch 
        family = "NA";
    end
    
    %catalogID = char(splitID(2));
    catalogID = "NA";
    
    [DimN,DimM,DimZ] = size(img);
    Dim = min(DimN,DimM);
    megapixels = DimN*DimM/1000000;
    
    COLO_LR_All.filename{I} = filename;    
    COLO_LR_All.catalogID{I} = catalogID;
    COLO_LR_All.family{I} = family;
    COLO_LR_All.MP{I} = megapixels;
    I = I + 1
    
    if ismember(family,wantedFam)
        sprintf(filename)
        COLO_LR_SelectFamilies.filename{II} = filename;    
        COLO_LR_SelectFamilies.catalogID{II} = catalogID;
        COLO_LR_SelectFamilies.family{II} = family;
        COLO_LR_SelectFamilies.MP{II} = megapixels;
        imwrite(img,filenameWrite);
        II = II + 1;
    end
end
% writetable(COLO_LR_All,"DwC_COLO_All.xlsx")
% writetable(COLO_LR_SelectFamilies,"DwC_COLO_SelectFamilies.xlsx")
% writetable(COLO_LR_All,"D:\Dropbox\ML_Project\Image_Database\COLO_CatalogID_LRFR_Matching\DwC_Rhodes_All.xlsx")
% writetable(COLO_LR_SelectFamilies,"D:\Dropbox\ML_Project\Image_Database\COLO_CatalogID_LRFR_Matching\DwC_Rhodes_SelectFamilies.xlsx")

%% Go through dir recursively until get to jpgs, match with low res catalogID

%Directory = "D:\Dropbox\ML_Project\Image_Database\DwC_10RandImg_SVM_4Category_Images" %for testing locally
%COLO_LR = readtable("D:\Dropbox\ML_Project\Image_Database\COLO_CatalogID_LRFR_Matching\DwC_COLO_SelectFamilies.xlsx");
Directory = "/media/data/COLO" 
DirectoryOut = "/media/data/COLO_SelectFamilies/"

COLO_LR = readtable("/home/brlab/Documents/COLO_LRFR_Matching/DwC_COLO_SelectFamilies.xlsx");
% Add zeros to catalog numbers
for j = 1:height(COLO_LR);
    catalogIDtemp = string(COLO_LR.catalogID(j));
    clen = strlength(catalogIDtemp);
    if clen ~= 8
        cadd0 = 8 - clen;
        cadd0_n = repmat('0',1,cadd0);
        cjoin = [string(cadd0_n),catalogIDtemp];
        catalogIDtemp = strjoin(cjoin,"");
    end
    COLO_LR.catalogID{j} = char(catalogIDtemp);
end

filelist = dir(fullfile(Directory, '**\*.*'));  
filelist = filelist(~[filelist.isdir]);

fLen = length(filelist);

for i = 1:fLen
    FRcatalogIDsplit = string(filelist.name{i});
    FRcatalogIDsplit = strsplit(FRcatalogIDsplit,".");
    FRcatalogID = FRcatalogIDsplit(1);
    FRcatalogIDlocation = filelist.folder{i};
    FRopenDir = [FRcatalogIDlocation,filelist.name{i}];
    FRopenDir = strjoin(FRopenDir);
    
    if ismember(FRcatalogID,COLO_LR.catalogID)
        LRindex = find(COLO_LR.catalogID == FRcatalogID);
        LR_Info = COLO_LR.catalogID(LRindex,:)
        
        FR_Image = imread(FRopenDir);
        FR_New_Name = [DirectoryOut,LR_Info.filename,".jpg"];
        FR_New_Name = strjoin(FR_New_Name,"")
        imwrite(FR_Image,FR_New_Name)
    end
end


