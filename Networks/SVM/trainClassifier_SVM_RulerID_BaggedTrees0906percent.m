function [trainedClassifier, validationAccuracy] = trainClassifier(trainingData)
% [trainedClassifier, validationAccuracy] = trainClassifier(trainingData)
% returns a trained classifier and its accuracy. This code recreates the
% classification model trained in Classification Learner app. Use the
% generated code to automate training the same model with new data, or to
% learn how to programmatically train models.
%
%  Input:
%      trainingData: a table containing the same predictor and response
%       columns as imported into the app.
%
%  Output:
%      trainedClassifier: a struct containing the trained classifier. The
%       struct contains various fields with information about the trained
%       classifier.
%
%      trainedClassifier.predictFcn: a function to make predictions on new
%       data.
%
%      validationAccuracy: a double containing the accuracy in percent. In
%       the app, the History list displays this overall accuracy score for
%       each model.
%
% Use the code to train the model with new data. To retrain your
% classifier, call the function from the command line with your original
% data or new data as the input argument trainingData.
%
% For example, to retrain a classifier trained with the original data set
% T, enter:
%   [trainedClassifier, validationAccuracy] = trainClassifier(T)
%
% To make predictions with the returned 'trainedClassifier' on new data T2,
% use
%   yfit = trainedClassifier.predictFcn(T2)
%
% T2 must be a table containing at least the same predictor columns as used
% during training. For details, enter:
%   trainedClassifier.HowToPredict

% Auto-generated by MATLAB on 07-Jun-2019 17:59:10


% Extract predictors and response
% This code processes the data into the right shape for training the
% model.
inputTable = trainingData;
predictorNames = {'area', 'areaI', 'majorAxisLen', 'majorAxisLenI', 'minorAxisLen', 'minorAxisLenI', 'eccentricity', 'eccentricityI', 'eqDiameter', 'eqDiameterI', 'count', 'countI', 'avgBbox', 'avgBboxI'};
predictors = inputTable(:, predictorNames);
response = inputTable.class;
isCategoricalPredictor = [false, false, false, false, false, false, false, false, false, false, false, false, false, false];

% Train a classifier
% This code specifies all the classifier options and trains the classifier.
template = templateTree(...
    'MaxNumSplits', 5070);
classificationEnsemble = fitcensemble(...
    predictors, ...
    response, ...
    'Method', 'Bag', ...
    'NumLearningCycles', 30, ...
    'Learners', template, ...
    'ClassNames', categorical({'binary_barcode'; 'binary_bauschWhite_Dual'; 'binary_blackLong_Metric'; 'binary_blackSplit_Dual'; 'binary_blackStrip_MM'; 'binary_black_Dual'; 'binary_black_Inch'; 'binary_black_Metric'; 'binary_blocks_Metric'; 'binary_clear_Dual'; 'binary_complexHighContrast_Metric'; 'binary_greyKodak_Dual'; 'binary_greyTiffen_Dual'; 'binary_highContrastMini_Metric'; 'binary_highContrastWhite_Metric'; 'binary_highContrast_Metric'; 'binary_smallGrey_Dual'; 'binary_whiteCONV_Dual'; 'binary_whiteCarolina_Dual'; 'binary_whiteComplex10CM_Metric'; 'binary_whiteFull_Dual'; 'binary_whiteFurman_Dual'; 'binary_whiteLong'; 'binary_whiteStrip_Inch'; 'binary_whiteStrip_Metric'; 'binary_whiteUSFS_Dual'; 'binary_whiteVG_Dual'; 'binary_white_Inch'; 'binary_white_Metric'}));

% Create the result struct with predict function
predictorExtractionFcn = @(t) t(:, predictorNames);
ensemblePredictFcn = @(x) predict(classificationEnsemble, x);
trainedClassifier.predictFcn = @(x) ensemblePredictFcn(predictorExtractionFcn(x));

% Add additional fields to the result struct
trainedClassifier.RequiredVariables = {'area', 'areaI', 'avgBbox', 'avgBboxI', 'count', 'countI', 'eccentricity', 'eccentricityI', 'eqDiameter', 'eqDiameterI', 'majorAxisLen', 'majorAxisLenI', 'minorAxisLen', 'minorAxisLenI'};
trainedClassifier.ClassificationEnsemble = classificationEnsemble;
trainedClassifier.About = 'This struct is a trained model exported from Classification Learner R2019a.';
trainedClassifier.HowToPredict = sprintf('To make predictions on a new table, T, use: \n  yfit = c.predictFcn(T) \nreplacing ''c'' with the name of the variable that is this struct, e.g. ''trainedModel''. \n \nThe table, T, must contain the variables returned by: \n  c.RequiredVariables \nVariable formats (e.g. matrix/vector, datatype) must match the original training data. \nAdditional variables are ignored. \n \nFor more information, see <a href="matlab:helpview(fullfile(docroot, ''stats'', ''stats.map''), ''appclassification_exportmodeltoworkspace'')">How to predict using an exported model</a>.');

% Extract predictors and response
% This code processes the data into the right shape for training the
% model.
inputTable = trainingData;
predictorNames = {'area', 'areaI', 'majorAxisLen', 'majorAxisLenI', 'minorAxisLen', 'minorAxisLenI', 'eccentricity', 'eccentricityI', 'eqDiameter', 'eqDiameterI', 'count', 'countI', 'avgBbox', 'avgBboxI'};
predictors = inputTable(:, predictorNames);
response = inputTable.class;
isCategoricalPredictor = [false, false, false, false, false, false, false, false, false, false, false, false, false, false];

% Perform cross-validation
partitionedModel = crossval(trainedClassifier.ClassificationEnsemble, 'KFold', 5);

% Compute validation predictions
[validationPredictions, validationScores] = kfoldPredict(partitionedModel);

% Compute validation accuracy
validationAccuracy = 1 - kfoldLoss(partitionedModel, 'LossFun', 'ClassifError');
