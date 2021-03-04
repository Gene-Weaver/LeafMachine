%%% Ruler Conversion Tool
% Takes output from YOLOv2 crop as input
% img = cropped RGB image from YOLOv2

% PATH 1: RCT_BlackTickMM
%       black mm tick marks --- pol. binary; local maxima scanlines 10,20,30
%       pixels tall; geommean within 2std of geommean

%%% TEMP %%% Load Image, REMOVE FOR FUNCTION
img_black1 = imread('D:/Dropbox/ML_Project/LM_YOLO_Training/YOLO_Test_Out-Avg/Cropped/Primary/HSC_HSC205048_H_bboxPrimary__2__black_Dual.jpg'); % 160 , its only CM!
img_white1 = imread('D:/Dropbox/ML_Project/LM_YOLO_Training/YOLO_Test_Out-Avg/Cropped/Primary/IMG_6384_bboxPrimary__2__barcode.jpg'); % ~7.4
img_white2 = imread('D:/Dropbox/ML_Project/LM_YOLO_Training/YOLO_Test_Out-Avg/Cropped/Primary/IMG_7126_bboxPrimary__2__whiteFull_Dual.jpg'); % ~7.5
img_silver = imread('D:/Dropbox/ML_Project/LM_YOLO_Training/YOLO_Test_Out-Avg/Cropped/Primary/IMG_4485_bboxPrimary__2__blackLong_Metric.jpg'); % ~6.1
img_bausch = imread('D:/Dropbox/ML_Project/LM_YOLO_Training/YOLO_Test_Out-Avg/Cropped/Primary/COLO_00154062_BETULACEAE_Alnus_incana_H_bboxPrimary__2__bauschWhite_Dual.jpg'); % ~12
image_list = {img_black1,img_white1,img_white2,img_silver,img_bausch};

function [convFactor] = rulerConversionTool(img)
    % Rotate the image so it is hor
    [H, W, ~] = size(img);
    if H > W, img = imrotate(img,90);end
    
    % Convert to grayscale
    imgGS = rgb2gray(img);
    
    % Get adaptive binary image
    imgBW = imbinarize(imgGS,'adaptive','ForegroundPolarity','dark','Sensitivity',0.5);

    % Fill in holes
    imgBW_1pass = imcomplement(imfill(imcomplement(imgBW),'holes'));
    imgBW_2pass = imcomplement(imfill(imgBW_1pass,'holes'));
    img_Passes = {imgBW_1pass,imgBW_2pass};
    colors = {'blue','green'};

    for IMGp=1:length(img_Passes)
            IMG_run = img_Passes{IMGp};
            PASS = cell(0,length(distHeaders));
            PASS = cell2table(PASS);
            PASS.Properties.VariableNames = distHeaders;
            for ii = 10:20
                NAME = strcat("img",string(IMG));
                SCAN = strcat("scan",string(ii));
                scanlineCropImgs = scanlineCrop(IMG_run,ii);
                distData = cell(0,length(distHeaders));
                distScanlines = cell2table(distData);
                distScanlines.Properties.VariableNames = distHeaders;
                for i=1:length(scanlineCropImgs)
                    yPosOverall = (ii/2)+i;
                    yPosScan = ii/2;
                    distScanlines = [distScanlines; fitTicks_MM_blackTicks(scanlineCropImgs{i},0,distHeaders,NAME,SCAN,yPosOverall,yPosScan)];
                end
                MIN = distScanlines.weighted_variance(:);
                [lowestVar, i_lowestVar] = min(MIN(MIN>0));
                lowestVar_data = distScanlines(i_lowestVar,:);
                PASS = [PASS; lowestVar_data];
                %LOWEST = [LOWEST; lowestVar_data];
            end
            std_PASS = std(PASS.dist_mean);
            Hmean_PASS = harmmean(PASS.dist_mean);
            i_stdSet_PASS = find(PASS.dist_mean(Hmean_PASS-std_PASS<PASS.dist_mean<Hmean_PASS+std_PASS));
            stdSet_PASS = PASS(i_stdSet_PASS,:);
            Hmean_stdSet_PASS = harmmean(stdSet_PASS.dist_mean);

            distSummaryt = cell(1,length(distHeaders2));
            distSummaryt = cell2table(distSummaryt);
            distSummaryt.Properties.VariableNames = distHeaders2;
            distSummaryt.name = NAME;
            distSummaryt.pass = string(IMGp);
            distSummaryt.calculated_dist = Hmean_stdSet_PASS;

            distSummary = [distSummary; distSummaryt];
            LOWEST = [LOWEST; PASS];
        end
end