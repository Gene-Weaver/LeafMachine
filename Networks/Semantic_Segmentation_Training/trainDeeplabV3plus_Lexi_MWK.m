%%%     Train DeeplabV3+ with resnet18 transfer learning
%%%
%%%     Developed for LeafMachine.org
%%%
%%%     William Weaver
%%%     University of Colorado, Boulder
%%%     Department of Ecology and Evolutionary Biology

addpath('/home/brlab/Dropbox/ML_Project/LeafMachine/SandboxFunctions') 

load('/home/brlab/Documents/MATLAB/Test/LMv2_CNN_wkspace.mat');

% load('/home/brlab/Documents/MATLAB/Test/Images/gTruth_Training_dynamicCrop__Lexi_WK.mat');
% gTruth_V = load('/home/brlab/Documents/MATLAB/Test/Images/gTruth_Validation_dynamicCrop__Lexi_WK.mat');

largeSize = [360 360 3];
lgraph = helperDeeplabv3PlusResnet18(largeSize, 5);

gTruth_Training_dynamicCrop__Lexi_WK = gTruth_Training;

gTruth_Validation_dynamicCrop__Lexi_WK = gTruth_Validation;

% Generate random numbers for choosing subset of training
factor = 0.75;
nCrop = height(gTruth_Training_dynamicCrop__Lexi_WK.LabelData);
INDEX = randsample(nCrop,round(factor.*nCrop));
nCrop2 = height(gTruth_Validation_dynamicCrop__Lexi_WK.LabelData);
INDEX2 = randsample(nCrop2,round(factor.*nCrop2));
writematrix(INDEX,'gTruth_Training_dynamicCrop__Lexi_WK_subsetindex75percent2.xlsx');
writematrix(INDEX2,'gTruth_Validation_dynamicCrop__Lexi_WK_subsetindex75percent2.xlsx');

gTruth_Training_LabelData = gTruth_Training_dynamicCrop__Lexi_WK.LabelData(INDEX,:);
%gTruth_Validation_LabelData = gTruth_Validation_dynamicCrop__Lexi_WK.LabelData(:,:);
gTruth_Validation_LabelData = gTruth_Validation_dynamicCrop__Lexi_WK.LabelData(INDEX2,:);

% Directory for datasource images
FILES_Training = gTruth_Training_dynamicCrop__Lexi_WK.DataSource.Source(INDEX,:); 
%FILES_Validation = gTruth_Validation_dynamicCrop__Lexi_WK.DataSource.Source(:,:); 
FILES_Validation = gTruth_Validation_dynamicCrop__Lexi_WK.DataSource.Source(INDEX2,:); 


pxDir_Training = table2cell(gTruth_Training_LabelData);
pxDir_Validation = table2cell(gTruth_Validation_LabelData);

classNames = table2cell(gTruth_Training_dynamicCrop__Lexi_WK.LabelDefinitions(:,1));
pixelLabelID = table2cell(gTruth_Training_dynamicCrop__Lexi_WK.LabelDefinitions(:,3));

% Create datastore object for val training images
imds_Training = imageDatastore(FILES_Training);
pxds_Training = pixelLabelDatastore(pxDir_Training,classNames,pixelLabelID);
imds_Validation = imageDatastore(FILES_Validation);
pxds_Validation = pixelLabelDatastore(pxDir_Validation,classNames,pixelLabelID);

gTruth_Training = groundTruth(groundTruthDataSource(FILES_Training),gTruth_Training_dynamicCrop__Lexi_WK.LabelDefinitions,gTruth_Training_LabelData);
gTruth_Validation = groundTruth(groundTruthDataSource(FILES_Validation),gTruth_Training_dynamicCrop__Lexi_WK.LabelDefinitions,gTruth_Validation_LabelData);

gTruth_Validation_LabelData = gTruth_Validation_dynamicCrop__Lexi_WK.LabelData;
pxDir_Validation = table2cell(gTruth_Validation_LabelData);
classNames = table2cell(gTruth_Training_dynamicCrop__Lexi_WK.LabelDefinitions(:,1));
pixelLabelID = table2cell(gTruth_Training_dynamicCrop__Lexi_WK.LabelDefinitions(:,3));
pxds_Validation = pixelLabelDatastore(pxDir_Validation,classNames,pixelLabelID);

%Use these when you don't have to subset
% plimds_Training_dynamicCrop = pixelLabelImageDatastore(gTruth_Training_dynamicCrop__Lexi_WK);
% plimds_Validation_dynamicCrop = pixelLabelImageDatastore(gTruth_Validation_dynamicCrop__Lexi_WK);
%Use these when you DO have to subset
plimds_Training_dynamicCrop = pixelLabelImageDatastore(gTruth_Training);
plimds_Validation_dynamicCrop = pixelLabelImageDatastore(gTruth_Validation);


%deepLabV2_parts = load('deeplab-res101-v2.mat');
%net = vl_simplenn_tidy(deepLabV2_parts);

nClasses = 5;
tbl = countEachLabel(pxds_Validation);
frequency = tbl.PixelCount/sum(tbl.PixelCount);
bar(1:nClasses,frequency)
xticks(1:nClasses) 
xticklabels(tbl.Name)
xtickangle(45)
ylabel('Frequency')
imageFreq = tbl.PixelCount ./ tbl.ImagePixelCount;
imageFreq(isnan(imageFreq))=0.0001;
classWeights = median(imageFreq) ./ imageFreq;
pxLayer = pixelClassificationLayer('Name','labels','Classes',tbl.Name,'ClassWeights',classWeights);
lgraph = replaceLayer(lgraph,"classification",pxLayer);
%parpool(2)
Gopts = trainingOptions('sgdm', ...
    'MaxEpochs',10, ...
    'InitialLearnRate', 1e-2, ...
    'LearnRateSchedule', 'piecewise', ...
    'ExecutionEnvironment','gpu',...
    'LearnRateDropFactor', 0.1, ...
    'LearnRateDropPeriod', 4, ...
    'MiniBatchSize', 150, ...
    'Shuffle','every-epoch', ...
    'Plots','training-progress', ...
    'Verbose',false, ...
    'ValidationData',plimds_Validation_dynamicCrop,...
    'ValidationPatience',Inf,...
    'ValidationFrequency',10,...
    'CheckpointPath','/home/brlab/Documents/MATLAB/Test/Images/checkpoints80percent');
%% Train
deeplab_v2_Lexi_dynamicCrop_MWK_August80percent = trainNetwork(plimds_Training_dynamicCrop,lgraph,Gopts);
save deeplab_v2_Lexi_dynamicCrop_MWK_August80percent

%% Test
net_SEQ1 = load('/home/brlab/Downloads/network_SEQnet1.mat');
net_SEQ4 = load('/home/brlab/Downloads/network_SEQnet4.mat');
net_SEQ5 = load('/home/brlab/Downloads/network_SEQnet5.mat');
net_SEQ1 = net_SEQ1.net1;
net_SEQ4 = net_SEQ4.net4;
net_SEQ5 = net_SEQ5.net5;
net = net_SEQ5;

image1 = imread("/home/brlab/Downloads/NCZP_3843305_LAMIACEAE_Collinsonia_canadensis_H.jpg");
image2 = imread("/home/brlab/Downloads/NCZP_3842639_ASTERACEAE_Heterotheca_subaxillaris.jpg");
image3 = imread("/home/brlab/Downloads/NCZP_3842639_ASTERACEAE_Heterotheca_subaxillaris_H.jpg");
image4 = imread("/home/brlab/Downloads/SEL_6824703_Cyperaceae_Rhynchospora_globularis.jpg");
image5 = imread("/home/brlab/Downloads/SEL_6824703_Cyperaceae_Rhynchospora_globularis_H.jpg");

ishow = image3;
[C,~,~] = semanticseg(ishow,net,'ExecutionEnvironment','gpu');
CC = size(C);
B = labeloverlay(imcrop(ishow,[0 0 CC(2) CC(1)]),C);
figure(1);
imshow(B)

sendEmailOnFailure('deeplab_v2_Lexi_dynamicCrop_MWK_August75percent','deeplab_v2_Lexi_dynamicCrop_MWK_August75percent',B);

%% Evaluate
load("/home/brlab/Dropbox/ML_Project/LeafMachine/Networks/deeplabV3Plus_Lexi_dynamicCrop_MWK_network.mat");
imgDS_ImageOrder = readtable("/home/brlab/Dropbox/ML_Project/Image_Database/LeafMachine_Validation_Images/LM_Testing_Validation75set/imageOrder.xlsx");

labels = "/home/brlab/Dropbox/ML_Project/Image_Database/LeafMachine_Validation_Images/LM_Testing_Validation75set/pixelLabelData";
imgDS = imageDatastore("/home/brlab/Dropbox/ML_Project/Image_Database/LeafMachine_Validation_Images/LM_Testing_Validation75set/img");
imgDS.Files = table2cell(imgDS_ImageOrder);

pxdsTest = pixelLabelDatastore(labels,gTruth_Validation.LabelDefinitions.Name,pixelLabelID);


%% validation of matching images
% fOrder = imgDS.Files;
%writetable(cell2table(fOrder),"/home/brlab/Dropbox/ML_Project/Image_Database/LeafMachine_Validation_Images/LM_Testing_Validation75set/imageOrder.xlsx");
% NNN = 15;
for NNN = 1:length(pxdsTest.Files)
    temp = strsplit(pxdsTest.Files{NNN},"/");
    NAMEstr = temp{length(temp)};
    NAMEstr2 = strsplit(NAMEstr,".");
    NAMEstr3 = NAMEstr2{1};
    %NAME = strjoin(["/home/brlab/Dropbox/ML_Project/Image_Database/LeafMachine_Validation_Images/LM_Testing_Validation75set/pixelLabelDatajpg/","new_",NAMEstr3,".jpg"],"");
    %imwrite(C,NAME)
    
    fs = "File N ==>  %d      %s \n";
    fprintf(fs,NNN,imgDS.Files{NNN})
    f1 = figure('Name',NAMEstr3);
    figure(f1);
    I = readimage(imgDS,NNN);
    C = uint8(readimage(pxdsTest,NNN)).*50;
    


    imshowpair(I,C,'montage')
    pause(.5)
end

%% Subset images by resolution, based on imageOrder file
res_HighOrLow = readtable("/home/brlab/Dropbox/ML_Project/Image_Database/LeafMachine_Validation_Images/LM_Testing_Validation75set/imageOrder_Res.xlsx");

labels_FR = "/home/brlab/Dropbox/ML_Project/Image_Database/LeafMachine_Validation_Images/LM_Testing_Validation75set/pixelLabelData_FullRes";
labels_LR = "/home/brlab/Dropbox/ML_Project/Image_Database/LeafMachine_Validation_Images/LM_Testing_Validation75set/pixelLabelData_LowRes";

% Subset 
sub_High_Px = pixelLabelDatastore(labels_FR,gTruth_Validation.LabelDefinitions.Name,pixelLabelID);
sub_Low_Px = pixelLabelDatastore(labels_LR,gTruth_Validation.LabelDefinitions.Name,pixelLabelID);

sub_High_Img = subset(imgDS,find(res_HighOrLow.FullRes)); 
sub_Low_Img = subset(imgDS,find(res_HighOrLow.FullRes==0)); 

%% Overall accuracy 
try
    pxdsResults = semanticseg(imgDS, deeplabV3Plus_Lexi_dynamicCrop_MWK, "WriteLocation", tempdir, 'MiniBatchSize',24,'ExecutionEnvironment','gpu');
catch
    try
        pxdsResults = semanticseg(imgDS, deeplabV3Plus_Lexi_dynamicCrop_MWK, "WriteLocation", tempdir, 'MiniBatchSize',12,'ExecutionEnvironment','gpu');

    catch
        pxdsResults = semanticseg(imgDS, deeplabV3Plus_Lexi_dynamicCrop_MWK, "WriteLocation", tempdir, 'MiniBatchSize',6,'ExecutionEnvironment','gpu');
    end
end

metrics = evaluateSemanticSegmentation(pxdsResults, pxdsTest);

metrics.ConfusionMatrix
metrics.NormalizedConfusionMatrix
metrics.DataSetMetrics
metrics.ClassMetrics
metrics.ImageMetrics

normConfMatData = metrics.NormalizedConfusionMatrix.Variables;
figure
h = heatmap(classNames, classNames, 100 * normConfMatData);
h.XLabel = 'Predicted Class';
h.YLabel = 'True Class';
h.Title  = 'Normalized Confusion Matrix (%)';

evaluationMetrics = ["accuracy" "iou"];
metrics = evaluateSemanticSegmentation(pxdsResults, pxdsTest, "Metrics", evaluationMetrics);
% Display metrics for each class.
metrics.ClassMetrics

%% Accuracy by resolution FULL RES
try
    pxdsResultsFR = semanticseg(sub_High_Img, deeplabV3Plus_Lexi_dynamicCrop_MWK, "WriteLocation", tempdir, 'MiniBatchSize',24,'ExecutionEnvironment','gpu');
catch
    try
        pxdsResultsFR = semanticseg(sub_High_Img, deeplabV3Plus_Lexi_dynamicCrop_MWK, "WriteLocation", tempdir, 'MiniBatchSize',12,'ExecutionEnvironment','gpu');

    catch
        pxdsResultsFR = semanticseg(sub_High_Img, deeplabV3Plus_Lexi_dynamicCrop_MWK, "WriteLocation", tempdir, 'MiniBatchSize',6,'ExecutionEnvironment','gpu');
    end
end

metrics = evaluateSemanticSegmentation(pxdsResultsFR, sub_High_Px);

metrics.ConfusionMatrix
metrics.NormalizedConfusionMatrix
metrics.DataSetMetrics
metrics.ClassMetrics
metrics.ImageMetrics

normConfMatData = metrics.NormalizedConfusionMatrix.Variables;
figure
h = heatmap(classNames, classNames, 100 * normConfMatData);
h.XLabel = 'Predicted Class';
h.YLabel = 'True Class';
h.Title  = 'Normalized Confusion Matrix (%)';

evaluationMetrics = ["accuracy" "iou"];
metrics = evaluateSemanticSegmentation(pxdsResultsFR, sub_High_Px, "Metrics", evaluationMetrics);
% Display metrics for each class.
metrics.ClassMetrics

%% Accuracy by resolution  LOW RES
try
    pxdsResultsLR = semanticseg(sub_Low_Img, deeplabV3Plus_Lexi_dynamicCrop_MWK, "WriteLocation", tempdir, 'MiniBatchSize',24,'ExecutionEnvironment','gpu');
catch
    try
        pxdsResultsLR = semanticseg(sub_Low_Img, deeplabV3Plus_Lexi_dynamicCrop_MWK, "WriteLocation", tempdir, 'MiniBatchSize',12,'ExecutionEnvironment','gpu');

    catch
        pxdsResultsLR = semanticseg(sub_Low_Img, deeplabV3Plus_Lexi_dynamicCrop_MWK, "WriteLocation", tempdir, 'MiniBatchSize',6,'ExecutionEnvironment','gpu');
    end
end

metrics = evaluateSemanticSegmentation(pxdsResultsLR, sub_Low_Px);

metrics.ConfusionMatrix
metrics.NormalizedConfusionMatrix
metrics.DataSetMetrics
metrics.ClassMetrics
metrics.ImageMetrics

normConfMatData = metrics.NormalizedConfusionMatrix.Variables;
figure
h = heatmap(classNames, classNames, 100 * normConfMatData);
h.XLabel = 'Predicted Class';
h.YLabel = 'True Class';
h.Title  = 'Normalized Confusion Matrix (%)';

evaluationMetrics = ["accuracy" "iou"];
metrics = evaluateSemanticSegmentation(pxdsResultsLR, sub_Low_Px, "Metrics", evaluationMetrics);
% Display metrics for each class.
metrics.ClassMetrics


