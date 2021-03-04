% Convert gTruth from Will-PC to Workstation

data = load('D:\Will Files\Dropbox\ML_Project\Image_Database\DwC_10RandImg_gTruth\gTruth_AllRulerTypesValidated-PC.mat');
%data = load('D:\Dropbox\ML_Project\Image_Database\DwC_10RandImg_gTruth\gTruth_AllRulerTypesValidated-PC.mat');
data2 = data.gTruth;

oldPath = "D:\Dropbox\ML_Project\Image_Database\DwC_10RandImg";
newPath = fullfile("D:\Will Files\Dropbox\ML_Project\Image_Database\DwC_10RandImg");
% oldPath = "D:\Will Files\Dropbox\ML_Project\Image_Database\DwC_10RandImg";
% newPath = fullfile("D:\Dropbox\ML_Project\Image_Database\DwC_10RandImg");

alterPaths = {[oldPath newPath]};
unresolvedPath = changeFilePaths(data2,alterPaths);
data.gTruth = data2;

% then open imageLabeler
% import labels from workspace
% export labels as gTruth_1-15-19-4-WK.mat


%SENEY_10225204_Isoetaceae_IsoA?«tes__H.jpg

data = load('D:\Dropbox\ML_Project\Image_Database\DwC_10RandImg_PixelSeg\gTruth\gTruth_3-7-19.mat');
%data = load('D:\Dropbox\ML_Project\Image_Database\DwC_10RandImg_gTruth\gTruth_AllRulerTypesValidated-PC.mat');
data2 = data.gTruth;

oldPath = "/Volumes/EBIO/DwC_10RandImg/SENEY_10225204_Isoetaceae_IsoA?«tes_.jpg";
newPathPC = fullfile("D:\Dropbox\ML_Project\Image_Database\DwC_10RandImg\SENEY_10225204_Isoetaceae_Isoates_.jpg");
% oldPath = "D:\Will Files\Dropbox\ML_Project\Image_Database\DwC_10RandImg";
% newPath = fullfile("D:\Dropbox\ML_Project\Image_Database\DwC_10RandImg");

alterPaths = {[oldPath newPathPC]};
unresolvedPath = changeFilePaths(data2,alterPaths);
data.gTruth = data2;

%% Lexi files
data = load('D:\Dropbox\ML_Project\Image_Database\DwC_10RandImg_PixelSeg\gTruth_Training_dynamicCrop__Lexi.mat');
%data = load('D:\Dropbox\ML_Project\Image_Database\DwC_10RandImg_gTruth\gTruth_AllRulerTypesValidated-PC.mat');
data2 = data.gTruth;

data = gTruth_Training_dynamicCrop__Lexi;
data2 = data;

oldPath = "D:\Dropbox\ML_Project\Image_Database\DwC_10RandImg_PixelSeg";
newPath = fullfile("D:\Will Files\Dropbox\ML_Project\Image_Database\DwC_10RandImg_PixelSeg");
% oldPath = "D:\Will Files\Dropbox\ML_Project\Image_Database\DwC_10RandImg";
% newPath = fullfile("D:\Dropbox\ML_Project\Image_Database\DwC_10RandImg");

alterPaths = {[oldPath newPath]};
unresolvedPath = changeFilePaths(data2,alterPaths);
data.gTruth = data2;


%% Mich WK
data = load('D:\Dropbox\ML_Project\Image_Database\DwC_10RandImg_PixelSeg\gTruth_Validation_dynamicCrop__Lexi.mat');
data2 = data.gTruth_Validation_dynamicCrop__Lexi;

oldPathDataSource = "D:\Dropbox\ML_Project\Image_Database\DwC_10RandImg__dynamicCrop_FILES_Validation";
newPathDataSource = fullfile("/home/brlab/Documents/MATLAB/Test/Images/DwC_10RandImg__dynamicCrop_FILES_Validation");
% pxlds = pixelLabelDatastore(data2.LabelData,data2.LabelDefinitions.Name,data2.LabelDefinitions.PixelLabelID)
oldPathPixelLabel = 'D:\Dropbox\ML_Project\Image_Database\DwC_10RandImg_PixelSeg\PixelLabelData__dynamicCrop_gTruth_Validation_LabelData';
newPathPixelLabel = fullfile("/home/brlab/Documents/MATLAB/Test/Images/PixelLabelData__dynamicCrop_gTruth_Validation_LabelData");

alterPaths = {[oldPathDataSource newPathDataSource];[oldPathPixelLabel newPathPixelLabel]};
unresolvedPath = changeFilePaths(data2,alterPaths);
data.gTruth = data2;
gTruth_Validation_Mich = data2;