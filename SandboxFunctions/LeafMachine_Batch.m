%%%     LeafMachine Batch Processing
%%%             Version 2.0.0
%%%             Uses CNN: vgg16_LM180725_v4_longer2.mat
%%%             Training/validation set: gTruth_LM180707_Train_HRLR_Done.mat
%%%
%%%     Developed for LeafMachine.org
%%%
%%%     William Weaver
%%%     University of Colorado, Boulder
%%%     Department of Ecology and Evolutionary Biology



% vgg16_180725_v4_maxIterations VA: 85.47%   Iterations: 85,500

%% Load image directory for segmentation and processing
% if image is ~2000 pixels, it will be too large for gpu, too small when
% cropped for segHR

% Setup
addpath(genpath('Img'));
addpath(genpath('Leaf_Data'));
addpath(genpath('Processed_Images'));
addpath(genpath('Raw_Images'));
addpath(genpath('Ruler'));
addpath(genpath('Networks'));
addpath(genpath('SandboxFunctions'));
addpath(genpath('Training_Images'));
S = load('Networks/LeafMachine_SegNet_v1.mat');  
LeafMachine_SegNet_v1 = S.LeafMachine_SegNet_v1;
%addpath('CNN_LM180707_Checkpoints')
%addpath('Validation_Images')
%addpath('POC_Images')
%addpath('HR_Crop')
%addpath('LR_Whole')
%load vgg16_180725_v4_longer2
%load vgg16_180725_v4_maxIterations
%load('vgg16_180730_v6_5ClassesNarrower.mat','vgg16_180730_v6_5ClassesNarrower')


% [fLen,T] = LeafMachineBatchSegmentation_GUI(Directory,Segment_Montage_Both,net,nClasses,gpu_cpu,local_url,url_col,show,filenameSuffix,destinationDirectory,handles)
% Segment
LeafMachineBatchSegmentation_GUI('Networks/Training_Images','Both',vgg16_180730_v6_5ClassesNarrower,5,'gpu','url','goodQualityAccessURI','show',...
    '_vgg16_180730_v6_5ClassesNarrower','POC_Images_vgg16_180730_v6_5ClassesNarrower2_RhodesURLTest')
LeafMachineBatchSegmentation_GUI('POC_Images','Both',vgg16_180730_v6_5ClassesNarrower,5,'gpu','url','accessURI','show',...
    '_vgg16_180730_v6_5ClassesNarrower','POC_Images_vgg16_180730_v6_5ClassesNarrower2_RhodesURLTest')



tic()
LeafMachineBatchSegmentation('HR_Crop','Segment',vgg16_180730_v6_5ClassesNarrower,5,'gpu','noshow','_vgg16_180730_v6_5ClassesNarrower','HR_Crop_vgg16_180730_v6_5ClassesNarrower_SEG')
toc() % 24 seconds

tic()
LeafMachineBatchSegmentation('LR_Whole','Segment',vgg16_180730_v6_5ClassesNarrower,5,'gpu','noshow','_vgg16_180730_v6_5ClassesNarrower','LR_Whole_vgg16_180730_v6_5ClassesNarrower_SEG')
toc() % 109 sec... 2.3/image 1400x2100 





% Open Rhodes images from url
url = char("https://bisque.cyverse.org/image_service/image/00-iHqsNjjDUyCKUNwpj86enM?resize=4000&format=jpeg");
image = imread(url);




