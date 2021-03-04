%%%     Get type and location of target rulers for CV ID
%%%     Developed for LeafMachine.org
%%%
%%%     William Weaver
%%%     University of Colorado, Boulder
%%%     Department of Ecology and Evolutionary Biology

function [targetFiles,targetTypes,points] = buildTargetRulerDatabase(openDir)
    % targetImages = imageDatastore(fullfile('..\Image_Database\Rulers_Cropped'));
    targetImages = imageDatastore(openDir);
    targetFiles = cell2table(targetImages.Files);
    targetTypes = cell(height(targetFiles(:,1)),1);

    points_MinEigen = cell(height(targetFiles(:,1)),1);
    points_SURF = cell(height(targetFiles(:,1)),1);
    points_Harris = cell(height(targetFiles(:,1)),1);
    points_MSER = cell(height(targetFiles(:,1)),1);
    
    features_MinEigen = cell(height(targetFiles(:,1)),1);
    features_SURF = cell(height(targetFiles(:,1)),1);
    features_Harris = cell(height(targetFiles(:,1)),1);
    features_MSER = cell(height(targetFiles(:,1)),1);
    for i = 1:height(targetFiles(:,1))
        round(100*(i/height(targetFiles(:,1))),2)
        splitName = strsplit(string(targetFiles{i,1}),"\");
        splitName2 = splitName(1,length(splitName));
        splitName3 = strsplit(splitName2,"__");
        targetTypes{i,1} = splitName3{1,1};
        targetImage = rgb2gray(imread(fullfile(string(targetFiles{i,1}))));
        
        % Detect points
        points_MinEigen{i,1} = detectMinEigenFeatures(targetImage);
        points_SURF{i,1} = detectSURFFeatures(targetImage);
        points_Harris{i,1} = detectHarrisFeatures(targetImage);
        points_MSER{i,1} = detectMSERFeatures(targetImage);
        
        % Extract features
        features = extractFeatures(targetImage,points_MinEigen{i,1});
        features_MinEigen{i,1} = features;
        features = extractFeatures(targetImage,points_SURF{i,1});
        features_SURF{i,1} = features;
        features = extractFeatures(targetImage,points_Harris{i,1});
        features_Harris{i,1} = features;
        features = extractFeatures(targetImage,points_MSER{i,1});
        features_MSER{i,1} = features;
    end
    points = {points_MinEigen,points_SURF,points_Harris,points_MSER,features_MinEigen,features_SURF,features_Harris,features_MSER};
end
