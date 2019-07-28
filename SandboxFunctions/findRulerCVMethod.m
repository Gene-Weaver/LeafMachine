%%%     Find Ruler in Image - CV Method
%%%     Developed for LeafMachine.org
%%%
%%%     William Weaver
%%%     University of Colorado, Boulder
%%%     Department of Ecology and Evolutionary Biology

%% For Dev testing only
    openDir = fullfile('..\Image_Database\Rulers_Cropped');
    [targetFiles,targetTypes,points] = buildTargetRulerDatabase(openDir);
    save('rulerDataPartial.mat','-v7.3')
    load(fullfile('D:\Dropbox\ML_Project\Image_Database', '\Rulers_Cropped\rulerData.mat');
    
    img1 = imread("D:\Dropbox\ML_Project\Image_Database\DwC_10RandImg\DOV_20245102_Fagaceae_Fagus_sylvatica.jpg");
    img2 = imread("D:\Dropbox\ML_Project\Image_Database\DwC_10RandImg\AASU_20809714_Asteraceae_Packera_aurea.jpg");
    sceneImage = img1;

%%

function [location] = findRulerCVMethod(sceneImage,targetImages)
    
    
    points_MinEigen = points{1,1};
    points_SURF = points{2};
    points_Harris = points{3};
    points_MSER = points{4};


    % Convert sceneImage to grayscale
    sceneImage = rgb2gray(sceneImage);
    
    % Get scenepoints from sceneImage
    scenepoints_MinEigen = detectMinEigenFeatures(sceneImage);
    scenepoints_SURF = detectSURFFeatures(sceneImage);
    scenepoints_Harris = detectHarrisFeatures(sceneImage);
    scenepoints_MSER = detectMSERFeatures(sceneImage);
    
    
    
    [boxFeatures, boxPoints] = extractFeatures(boxImage, boxPoints);
    [sceneFeatures, scenePoints] = extractFeatures(sceneImage, scenePoints);



    figure, imshow(img1), hold on, title('Detected features');
    plot(points1);
    figure, imshow(img2), hold on, title('Detected features');
    plot(points2);

end