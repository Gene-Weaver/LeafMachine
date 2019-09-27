

filesToMove = readtable('D:\Dropbox\ML_Project\Image_Database\LeafMachine_OverviewStats\RhodesRejectedImages.xlsx');
imgDir = 'D:\Dropbox\ML_Project\Image_Database\RhodesImages\LowRes';
outDir = 'D:\Dropbox\ML_Project\Image_Database\LeafMachine_OverviewStats\RhodesRejectedImages';
for i=1:height(filesToMove)
    fname = string(filesToMove{i,:});
    IMG = imread(fullfile(imgDir,fname));
    imwrite(IMG,fullfile(outDir,fname))
end