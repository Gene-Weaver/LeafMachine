%%%     Crop Rulers from gTruth dataset
%%%     Developed for LeafMachine.org
%%%
%%%     William Weaver
%%%     University of Colorado, Boulder
%%%     Department of Ecology and Evolutionary Biology

gTruth = load('D:\Dropbox\ML_Project\Image_Database\DwC_10RandImg_gTruth\gTruth_AllRulerTypesValidated-PC.mat');
ruler = selectLabels(gTruth.gTruth,gTruth.gTruth.LabelDefinitions.Name);

outDir = fullfile('D:\Dropbox\ML_Project\Image_Database', '\Rulers_Cropped2');

for i = 1:length(ruler.DataSource.Source)
    % Get label names of rulers
    labels = ruler.LabelDefinitions.Name;  
    
    % Get each image
    imgLoc = ruler.DataSource.Source{i};
    img = imread(imgLoc);
    
    % Get associated row, get rois for cropping
    rois = ruler.LabelData{i,:};
    roisLabels = find(~cellfun(@isempty,rois));
    rois = rois(~cellfun('isempty',rois));
    roisLen = length(rois);
    
    % Loop through rois and crop
    try
        for j = 1:roisLen
           imgLabel = labels{roisLabels(j)};
           imgROIcrop = rois{j};
           imgCrop = imcrop(img,imgROIcrop);
           fname = strjoin({imgLabel,int2str(i),int2str(j)},'__');
           fname = strjoin({fname,'.jpg'},'');
           imwrite(imgCrop,fullfile(outDir,fname));
        end 
    catch
        imgLoc
    end
end












