%% Ruler detector
image = imread('~/Dropbox/ML_Project/Image_Database/RhodesImages/FullRes/13189213_Ginkgoaceae_Ginkgo_biloba.jpeg');
load('~/Dropbox/ML_Project/LeafMachine/SandboxFunctions/anchorBoxesRulerExtended.mat');

% Redmon, Joseph, and Ali Farhadi. "YOLO9000: Better, Faster, Stronger." 2017 IEEE Conference on Computer Vision and Pattern Recognition (CVPR). IEEE, 2017.
gTruth_raw = load("~/Dropbox/ML_Project/Image_Database/DwC_10RandImg_gTruth/gTruth_AllRulerTypesValidated-WK.mat");

% for i = 1:length(gTruth_raw.gTruth.DataSource)
%     fullFileName = gTruth_raw.gTruth.DataSource{i}
%     if exist(fullFileName, 'file')
%       % File exists.  Do stuff....
%     else
%       % File does not exist.
%       warningMessage = sprintf('Warning: file does not exist:\n%s', fullFileName);
%       uiwait(msgbox(warningMessage));
%     end
% end
gTruth = gTruth_raw.gTruth;

rulerLabelData = gTruth.LabelData;
 
objects = selectLabelsByName(gTruth,gTruth.LabelDefinitions.Name);
trainingData = objectDetectorTrainingData(objects);
%imageSize = [128 128 3];
imageSize = [360 360 3];
numClasses = width(rulerLabelData);

rng(0);
shuffledIdx = randperm(height(trainingData));
trainingData = trainingData(shuffledIdx,:);

imds = imageDatastore(trainingData.imageFilename);

blds = boxLabelDatastore(trainingData(:,2:end));

ds = combine(imds, blds);

% network = resnet50();
% analyzeNetwork(network)

segnet = load('Networks/deeplabV3Plus_Lexi_dynamicCrop_MWK_network.mat');
segnet = segnet.deeplabV3Plus_Lexi_dynamicCrop_MWK;
analyzeNetwork(segnet)

anchorBoxes = [1 1;4 6;5 3;9 6];
%anchorBoxes = anchorBoxes24;
%featureLayer = 'activation_49_relu';
featureLayer = 'dec_crop2';
lgraph = yolov2Layers(imageSize,numClasses,anchorBoxes,segnet,featureLayer);

analyzeNetwork(lgraph)
plot(lgraph)

layers = lgraph.Layers;
layers(1:99) = freezeWeights(layers(1:99)); 

options = trainingOptions('sgdm',...
          'InitialLearnRate',0.03,...
          'Verbose',true,...
          'MiniBatchSize',48,...
          'MaxEpochs',30,...
          'Shuffle','never',...
          'VerboseFrequency',10,...
          'ExecutionEnvironment','gpu',...
          'CheckpointPath',tempdir);

[detectorYOLO_LM_Ruler,info] = trainYOLOv2ObjectDetector(ds,lgraph,options);




[bboxes, scores, labels] = detect(detectorYOLO_LM_Ruler, image,'SelectStrongest',false)
[bboxes, scores, labels] = detect(detectorYOLO_LM_Ruler, image,'ExecutionEnvironment','gpu','Threshold',.01);

detectedI = insertObjectAnnotation(image,'Rectangle',bboxes,cellstr(labels));
figure(1);
imshow(detectedI)
sendEmailOnFailure('YOLO_DeeplabV3','YOLO_DeeplabV3 Yolo training done',detectedI)

%% Old school - FAILED
image = imread('~/Dropbox/ML_Project/Image_Database/RhodesImages/FullRes/13189213_Ginkgoaceae_Ginkgo_biloba.jpeg');
load('~/Dropbox/ML_Project/LeafMachine/SandboxFunctions/anchorBoxesRulerExtended.mat');

% Redmon, Joseph, and Ali Farhadi. "YOLO9000: Better, Faster, Stronger." 2017 IEEE Conference on Computer Vision and Pattern Recognition (CVPR). IEEE, 2017.
gTruth_raw = load("~/Dropbox/ML_Project/Image_Database/DwC_10RandImg_gTruth/gTruth_AllRulerTypesValidated-WK.mat");

% for i = 1:length(gTruth_raw.gTruth.DataSource)
%     fullFileName = gTruth_raw.gTruth.DataSource{i}
%     if exist(fullFileName, 'file')
%       % File exists.  Do stuff....
%     else
%       % File does not exist.
%       warningMessage = sprintf('Warning: file does not exist:\n%s', fullFileName);
%       uiwait(msgbox(warningMessage));
%     end
% end
gTruth = gTruth_raw.gTruth;

rulerLabelData = gTruth.LabelData;
 
objects = selectLabelsByName(gTruth,gTruth.LabelDefinitions.Name);
trainingData = objectDetectorTrainingData(objects);
imageSize = [128 128 3];
%imageSize = [360 360 3];
numClasses = width(rulerLabelData);

rng(0);
shuffledIdx = randperm(height(trainingData));
trainingData = trainingData(shuffledIdx,:);

imds = imageDatastore(trainingData.imageFilename);

blds = boxLabelDatastore(trainingData(:,2:end));

ds = combine(imds, blds);

network = resnet50();
analyzeNetwork(network)

anchorBoxes = [100 100;40 60;50 30;90 60;10 100;100 10];
%anchorBoxes = anchorBoxes24;
featureLayer = 'activation_49_relu';
lgraph = yolov2Layers(imageSize,numClasses,anchorBoxes,network,featureLayer);

options = trainingOptions('sgdm',...
          'InitialLearnRate',0.01,...
          'Verbose',true,...
          'MiniBatchSize',48,...
          'MaxEpochs',10,...
          'Shuffle','never',...
          'VerboseFrequency',10,...
          'ExecutionEnvironment','gpu',...
          'CheckpointPath',tempdir);

[detectorYOLO_Ruler,info] = trainYOLOv2ObjectDetector(ds,lgraph,options);



[bboxes, scores, labels] = detect(detectorYOLO_Ruler, image,'SelectStrongest',false)
%[bboxes, scores, labels] = detect(detectorYOLO_Ruler, image,'ExecutionEnvironment','gpu','Threshold',.01);

detectedI = insertObjectAnnotation(image,'Rectangle',bboxes,cellstr(labels));
figure(1);
imshow(detectedI)
%sendEmailOnFailure('YOLO_Old','YOLO_Old Yolo training done',detectedI)
