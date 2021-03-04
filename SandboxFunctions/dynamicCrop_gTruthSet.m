%%% dynamicCrop Lexi Training Set
% Once you edit Lexi's set and add to it, you should be able to just load
% the new gTruth file and let this run, but WITHOUT the 425 file limit.
% ALSO NEED TO ADD THE LOWRESLOWQ FILES

% Load gtruth and dynamicCrop the images
try
    gTruth_All = load('D:\Will Files\Dropbox\ML_Project\Image_Database\DwC_10RandImg_PixelSeg\gTruth\gTruth_Lexi_Final.mat');
catch
    gTruth_All = load('D:\Dropbox\ML_Project\Image_Database\DwC_10RandImg_PixelSeg\gTruth\gTruth_Lexi_Final.mat');
end
%gTruth_Validation = load('D:\Will Files\Dropbox\ML_Project\Image_Database\GroundTruth\gTruth_LM180707_22_NB.mat');
% Better way to partition data in the future
% [imdsTrain, imdsVal, imdsTest, pxdsTrain, pxdsVal, pxdsTest] = partitionCamVidData(imds,pxds);
gTruth_All = gTruth_All.gTruth;

% Take first 425 for prelim training
gTruth_Training_LabelData = gTruth_All.LabelData(1:350,:);
gTruth_Validation_LabelData = gTruth_All.LabelData(351:425,:);
% Directory for datasource images
FILES_Training = cell2table(gTruth_All.DataSource.Source(1:350,:)); 
FILES_Validation = cell2table(gTruth_All.DataSource.Source(351:425,:)); 

% Crop and save
LIST = {gTruth_Training_LabelData gTruth_Validation_LabelData FILES_Training FILES_Validation};
LISTn = {'gTruth_Training_LabelData','gTruth_Validation_LabelData','FILES_Training','FILES_Validation'};
LIST_OUT = {};
for L = 1:4
    images = LIST{L};
    setName = LISTn{L};
    setCropNames = [];
    for i = 1:height(images)
        fNameFull = cell2mat(table2cell(images(i,1)));
        imgCropNames = dynamicCrop(fNameFull,setName);
        setCropNames = [setCropNames;imgCropNames];
    end
    LIST_OUT{L} = setCropNames;
end
gTruth_Training_LabelData_dynamicCrop = LIST_OUT{1};
gTruth_Validation_LabelData_dynamicCrop = LIST_OUT{2};
FILES_Training_dynamicCrop = LIST_OUT{3};
FILES_Validation_dynamicCrop = LIST_OUT{4};

gTruth_Training_LabelData_dynamicCrop.Properties.VariableNames = {'PixelLabelData'};
gTruth_Validation_LabelData_dynamicCrop.Properties.VariableNames = {'PixelLabelData'};

writetable(gTruth_Training_LabelData_dynamicCrop,'gTruth_Training_LabelData_dynamicCrop__Lexi.xlsx')
writetable(gTruth_Validation_LabelData_dynamicCrop,'gTruth_Validation_LabelData_dynamicCrop__Lexi.xlsx')
writetable(FILES_Training_dynamicCrop,'FILES_Training_dynamicCrop__Lexi.xlsx')
writetable(FILES_Validation_dynamicCrop,'FILES_Validation_dynamicCrop__Lexi.xlsx')

trainingDataSource = groundTruthDataSource(table2cell(FILES_Training_dynamicCrop));
validationDataSource = groundTruthDataSource(table2cell(FILES_Validation_dynamicCrop));

gTruth_Training_dynamicCrop__Lexi = groundTruth(trainingDataSource,gTruth_All.LabelDefinitions,gTruth_Training_LabelData_dynamicCrop);
gTruth_Validation_dynamicCrop__Lexi = groundTruth(validationDataSource,gTruth_All.LabelDefinitions,gTruth_Validation_LabelData_dynamicCrop);

% Need to save and then manually delete extra variables, resave after
save gTruth_Training_dynamicCrop__Lexi
save gTruth_Validation_dynamicCrop__Lexi

