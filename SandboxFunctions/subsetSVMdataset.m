% Randomly choose n rows from Excel file


FILE = readtable('D:\Dropbox\ML_Project\Image_Database\DwC_10RandImg_SVM_4Category\DwC_10RandImg_SVM_Dataset_notLeaf_only.xlsx');


RAND = sort(randi(height(FILE),7000,1));


FILEOUT = FILE(RAND,:);


writetable(FILEOUT,'D:\Dropbox\ML_Project\Image_Database\DwC_10RandImg_SVM_4Category\DwC_10RandImg_SVM_Dataset_notLeaf_subset7000.xlsx');