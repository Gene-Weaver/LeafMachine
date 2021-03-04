%%% Get manual pixel distance measurements from the 2,684 training images



D = "D:\Will Files\Dropbox\ML_Project\Image_Database\DwC_10RandImg";
outDir = "D:\Will Files\Dropbox\ML_Project\Image_Database\DwC_10RandImg_pixelDistanceValidation";
if ~exist(outDir, 'dir')
   mkdir(outDir)
end

measurements = {};
S = dir(fullfile(D,'*.jpg')); % pattern to match filenames.
%for i = 1:numel(S)
for i = 1:5
    file = fullfile(D,S(i).name);
    fName = strsplit(S(i).name,'.');
    fName = fName{1};
    
    img = imread(file);
    imshow(img)
    h = imdistline(gca,[50 50],[50 150]) ;
end