%%%     Initial SVM check for leaf candidate masks
%%%
%%%     Developed for LeafMachine.org
%%%
%%%     William Weaver
%%%     University of Colorado, Boulder
%%%     Department of Ecology and Evolutionary Biology

%%% Run watershed cleanup
%%% 




function [blobTable,blobFails] = initialSVMcheckAndClean(label,n,imgOrig,family,megapixels,imfillMasks,netSVM,saveLeafCandidateMasks,filename,destinationDirectory)
    % Blob
    blobHeaders = {'id','SVMprediction','time','color','colorReport','bbox','bboxReport','area','perimeter','measurements'};
    blobData = cell(n,length(blobHeaders));
    blobTable = cell2table(blobData);
    blobTable.Properties.VariableNames = blobHeaders;
    
    INDblob = 1;
    
    INDblob_fail = 1;
    blobFails = {};
   
    % Iterate through glob candidate blobs
    if n > 0
        for i = 1:n
            % Crop imgOrig to the bounds + a bit extra 
            
            blobBox_temp = regionprops(label==i, 'BoundingBox');
            blobBox_tempLeaf = regionprops(label==i, 'BoundingBox');
            
            bound = round(blobBox_temp.BoundingBox);
            % Expand bbox a bit
    %         A = bound(1)-70;
    %         B = bound(2)-70;
    %         C = bound(3)+140;
    %         D = bound(4)+140;
    %         if A < 0, A = 0; end
    %         if B < 0, B = 0; end
    %         if A+C > imgOrigSize(2), C = imgOrigSize(2)-A; end
    %         if B+D > imgOrigSize(1), D = imgOrigSize(1)-B; end
    %         bound2 = [A B C D];
            % Crop
            if imfillMasks == "True"
                imgCropBlob = imcrop(imgOrig,bound);
                labelBlobCrop = imcrop(label==i,bound);
                labelBlobCropLeaf = imcrop(imfill(label==i,'holes'),bound);
                
%                 figure(1);
%                 imshow(labelBlobCrop);
%                 figure(2);
%                 imshow(labelBlobCropLeaf);
                
            elseif imfillMasks == "False"
                imgCropBlob = imcrop(imgOrig,bound);
                labelBlobCrop = imcrop(label==i,bound);
                labelBlobCropLeaf = imcrop(label==i,bound);
                
%                 figure(1);
%                 imshow(labelBlobCrop);
%                 figure(2);
%                 imshow(labelBlobCropLeaf);
                
            end
            

            % Put label into SVM
            % ***Run binary blob through SVM***
            %sprintf("initial")

            UNKNOWN = buildSVMdataset_oneImage(logical(labelBlobCrop),family,megapixels);
            if ~isempty(UNKNOWN)
                [prediction,score] = netSVM.predictFcn(UNKNOWN);
                if class(prediction) == "categorical"
                    yfit = string(prediction);
                elseif class(prediction) == "cell"
                    yfit = string(cell2mat(prediction));
                else
                    "prediction fail - initial blob"
                end
                %yfit = string(cell2mat(netSVM.predictFcn(UNKNOWN)));original
                if yfit == "leaf"
                    % Save binary --optional, used for SVM training
                    saveBinaryMasks(filename,fullfile(destinationDirectory,'Leaf'),labelBlobCropLeaf,['Leaf__SVM__BINARY__',int2str(i)]);
                    saveBinaryMasks(filename,fullfile(destinationDirectory,'Leaf'),imgCropBlob,['Leaf__SVM__RGB__',int2str(i)]);

                    % Get color
                    blobTable.color{INDblob} = [0.4660, 0.6740, 0.1880];%pickColor(i,COLOR);
                    blobTable.colorReport{INDblob} = strjoin(['[',strjoin(string([0.4660, 0.6740, 0.1880]),' '),']'],''); 

                    % Get measurements
                    blobTable.measurements{INDblob} = measureLeafFeatures(labelBlobCropLeaf,bound);

                    %%% Save measurements upon "leaf" success
                    % Export final leaf binary
                    blobTable.id{INDblob} = i;
                    blobTable.SVMprediction{INDblob} = 'Leaf';
                    blobTable.time{INDblob} = datestr(now,'mm-dd-yyyy HH-MM-SS.FFF');
                    blobTable.bbox{INDblob} = blobBox_tempLeaf;
                    blobTable.bboxReport{INDblob} = strjoin(['[',strjoin(string(blobBox_tempLeaf.BoundingBox),' '),']'],'');
                    blobTable.area{INDblob} = bwarea(labelBlobCropLeaf);
                    blobTable.perimeter{INDblob} = struct2array(regionprops(labelBlobCropLeaf,'Perimeter'));

                    INDblob = INDblob + 1;

                elseif yfit == "partialLeaf"
                    %*** I turned on the imfill option for all classes for
                    %the validation images. Turn on %*% lines for
                    %production
                    
                    % Save binary --optional, used for SVM training
                    saveBinaryMasks(filename,fullfile(destinationDirectory,'Leaf_Partial'),labelBlobCropLeaf,['LeafPartial__SVM__BINARY__',int2str(i)]);
                    %*%saveBinaryMasks(filename,fullfile(destinationDirectory,'Leaf_Partial'),labelBlobCrop,['LeafPartial__SVM__BINARY__',int2str(i)]);
                    saveBinaryMasks(filename,fullfile(destinationDirectory,'Leaf_Partial'),imgCropBlob,['LeafPartial__SVM__RGB__',int2str(i)]);

                    % Get color
                    blobTable.color{INDblob} = [0, 0.4470, 0.7410];%pickColor(i,COLOR);
                    blobTable.colorReport{INDblob} = strjoin(['[',strjoin(string([0, 0.4470, 0.7410]),' '),']'],''); 

                    % Get measurements
                    blobTable.measurements{INDblob} = measureLeafFeatures(labelBlobCropLeaf,bound);
                    %*%blobTable.measurements{INDblob} = measureLeafFeatures(labelBlobCrop,bound);

                    %%% Save measurements upon "leaf" success
                    % Export final leaf binary
                    blobTable.id{INDblob} = i;
                    blobTable.SVMprediction{INDblob} = 'Leaf_Partial';
                    blobTable.time{INDblob} = datestr(now,'mm-dd-yyyy HH-MM-SS.FFF');
                    blobTable.bbox{INDblob} = blobBox_temp;
                    blobTable.bboxReport{INDblob} = strjoin(['[',strjoin(string(blobBox_temp.BoundingBox),' '),']'],'');
                    blobTable.area{INDblob} = bwarea(labelBlobCropLeaf);
                    %*%blobTable.area{INDblob} = bwarea(labelBlobCrop);
                    blobTable.perimeter{INDblob} = struct2array(regionprops(labelBlobCropLeaf,'Perimeter'));
                    %*%blobTable.perimeter{INDblob} = struct2array(regionprops(labelBlobCrop,'Perimeter'));

                    blobFails{INDblob_fail} = labelBlobCropLeaf;
                    %*%blobFails{INDblob_fail} = labelBlobCrop;
                    INDblob_fail = INDblob_fail + 1;

                    INDblob = INDblob + 1;

                elseif yfit == "clump"
                    % Save binary --optional, used for SVM training
                    saveBinaryMasks(filename,fullfile(destinationDirectory,'Leaf_Clump'),labelBlobCropLeaf,['LeafClump__SVM__BINARY__',int2str(i)]);
                    %*%saveBinaryMasks(filename,fullfile(destinationDirectory,'Leaf_Clump'),labelBlobCrop,['LeafClump__SVM__BINARY__',int2str(i)]);
                    saveBinaryMasks(filename,fullfile(destinationDirectory,'Leaf_Clump'),imgCropBlob,['LeafClump__SVM__RGB__',int2str(i)]);

                    % Get color
                    blobTable.color{INDblob} = [0.8500, 0.3250, 0.0980];%pickColor(i,COLOR);
                    blobTable.colorReport{INDblob} = strjoin(['[',strjoin(string([0.8500, 0.3250, 0.0980]),' '),']'],''); 

                    % Get measurements
                    blobTable.measurements{INDblob} = measureLeafFeatures(labelBlobCropLeaf,bound);
                    %*%blobTable.measurements{INDblob} = measureLeafFeatures(labelBlobCrop,bound);

                    %%% Save measurements upon "leaf" success
                    % Export final leaf binary
                    blobTable.id{INDblob} = i;
                    blobTable.SVMprediction{INDblob} = 'Leaf_Clump';
                    blobTable.time{INDblob} = datestr(now,'mm-dd-yyyy HH-MM-SS.FFF');
                    blobTable.bbox{INDblob} = blobBox_temp;
                    blobTable.bboxReport{INDblob} = strjoin(['[',strjoin(string(blobBox_temp.BoundingBox),' '),']'],'');
                    blobTable.area{INDblob} = bwarea(labelBlobCropLeaf);
                    %*%blobTable.area{INDblob} = bwarea(labelBlobCrop);
                    blobTable.perimeter{INDblob} = struct2array(regionprops(labelBlobCropLeaf,'Perimeter'));
                    %*%blobTable.perimeter{INDblob} = struct2array(regionprops(labelBlobCrop,'Perimeter'));

                    blobFails{INDblob_fail} = labelBlobCropLeaf;
                    %*%blobFails{INDblob_fail} = labelBlobCrop;
                    INDblob_fail = INDblob_fail + 1;

                    INDblob = INDblob + 1;

                elseif yfit == "notLeaf"
                    if saveLeafCandidateMasks
                        saveBinaryMasks(filename,fullfile(destinationDirectory,'Leaf_Fail'),labelBlobCrop,['LeafFail__SVM__BINARY__',int2str(i)]);
                        saveBinaryMasks(filename,fullfile(destinationDirectory,'Leaf_Fail'),imgCropBlob,['LeafFail__SVM__RGB__',int2str(i)]);
                        % Currently, this is turned off for efficiency 
%                         blobFails{INDblob_fail} = labelBlobCrop;
%                         INDblob_fail = INDblob_fail + 1;
                    else
                    end
                end
            else
                sprintf("SVM lacked blob to measure -- initialSVM")
            end
        end
        idx = all(cellfun(@isempty,blobTable{:,:}),2);
        blobTable(idx,:) = [];
    end
    if INDblob == 1
        blobTable = [];
    end
    
end