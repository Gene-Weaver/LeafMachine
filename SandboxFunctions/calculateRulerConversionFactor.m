%%%     Run text masks through SVM
%%%
%%%     Developed for LeafMachine.org
%%%
%%%     William Weaver
%%%     University of Colorado, Boulder
%%%     Department of Ecology and Evolutionary Biology

function [conversionFactor] = calculateRulerConversionFactor(img,Dim,C,feature,netSVMruler,filename,destinationDirectory)
    imgGS = rgb2gray(img);
    
    binaryMasks = getBinaryMasks(C);
    composite = bwareaopen(binaryMasks{feature},50);
    [label, n] = bwlabel(composite);
%     strelSize = round((Dim(1)*0.015),0);
%     label = imdilate(label,strel('disk',strelSize,4));
%     [label, n] = bwlabel(label);
    %imshow(label)
    
    imgBW = imbinarize(imgGS,'adaptive','ForegroundPolarity','dark','Sensitivity',0.4);
    imgBW = 255 * repmat(uint8(imgBW), 1, 1, 3);
    
    % Loop through text blobs to find ruler
    for i = 1:n
        % Crop imgOrig to the bounds + a bit extra 
        blobBox_temp = regionprops(label==i, 'BoundingBox');
        bound = round(blobBox_temp.BoundingBox);
        
        % Expand bbox a bit
        A = bound(1)-70;
        B = bound(2)-70;
        C = bound(3)+140;
        D = bound(4)+140;
        if A < 0, A = 0; end
        if B < 0, B = 0; end
        if A+C > Dim(2), C = Dim(2)-A; end
        if B+D > Dim(1), D = Dim(1)-B; end
        bound = [A B C D];
        
        % Crop
        imgCropBlob = imcrop(imgBW,bound);
%         figure(3);imshow(imgCropBlob);
        %labelBlobCrop = imcrop(label==i,bound); % want to use the polarized binary image
        
        UNKNOWN = buildSVMdataset_ruler(logical(imgCropBlob));
        
        if ~isempty(UNKNOWN)
            prediction = netSVMruler.predictFcn(UNKNOWN);
            if class(prediction) == "categorical"
                yfit = string(prediction);
            elseif class(prediction) == "cell"
                yfit = string(cell2mat(prediction));
            else
                sprintf("ruler prediction fail - initial blob");
            end

            if yfit ~= "binary_barcode"                
                saveBinaryMasks(filename,destinationDirectory,imgCropBlob,['rulerType__',string(yfit),'__',int2str(i)]);
%                 % Save binary --optional, used for SVM training
%                 saveBinaryMasks(filename,destinationDirectory,labelBlobCrop,['initialBlob__CHOSEN__',int2str(i)]);
% 
%                 % Get color
%                 blobTable.color{INDblob} = pickColor(i,COLOR);
%                 blobTable.colorReport{INDblob} = strjoin(['[',strjoin(string(pickColor(i,COLOR)),' '),']'],''); 
% 
%                 % Get measurements
%                 blobTable.measurements{INDblob} = measureLeafFeatures(labelBlobCrop,bound);
% 
%                 %%% Save measurements upon "leaf" success
%                 % Export final leaf binary
%                 blobTable.id{INDblob} = i;
%                 %lineTable.bbox{INDglob} = strjoin(['[',strjoin(string(lineBox_temp),' '),']'],'');
%                 blobTable.bbox{INDblob} = blobBox_temp;
%                 blobTable.bboxReport{INDblob} = strjoin(['[',strjoin(string(blobBox_temp.BoundingBox),' '),']'],'');
%                 %blobTable.bbox{INDblob} = blobBox_temp;
%                 blobTable.area{INDblob} = bwarea(labelBlobCrop);
%                 blobTable.perimeter{INDblob} = struct2array(regionprops(labelBlobCrop,'Perimeter'));
% 
%                 INDblob = INDblob + 1;
            elseif yfit == "binary_barcode"       
                saveBinaryMasks(filename,destinationDirectory,imgCropBlob,['barcode__',string(yfit),'__',int2str(i)]);
                
%                 saveBinaryMasks(filename,destinationDirectory,labelBlobCrop,['initialBlob__SVMREJECT__',int2str(i)]);
%                 blobFails{INDblob_fail} = labelBlobCrop;
%                 INDblob_fail = INDblob_fail + 1;
            else
                sprintf("Ruler Prediction SVM Error")
            end
        else
            sprintf("Not a ruler")
        end
    end
    
    
    

    conversionFactor = 1;

end