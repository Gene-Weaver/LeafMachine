%%%     Evaluate CNN Accuracy
%%%     Developed for LeafMachine.org
%%%
%%%     William Weaver
%%%     University of Colorado, Boulder
%%%     Department of Ecology and Evolutionary Biology

pxdsTruth = pixelLabelDatastore(validationSet.PixelLabelData,validationSet.ClassNames,pixelLabelID); 
pxdsResults = semanticseg(imageDatastore(validationSet.Images), vgg16_180730_v6_5ClassesNarrower, "WriteLocation", tempdir, 'MiniBatchSize',10,'ExecutionEnvironment','gpu');

metrics = evaluateSemanticSegmentation(pxdsResults, pxdsTruth);

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
metrics = evaluateSemanticSegmentation(pxdsResults, pxdsTruth, "Metrics", evaluationMetrics);
% Display metrics for each class.
metrics.ClassMetrics