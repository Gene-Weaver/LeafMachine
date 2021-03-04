%%%     Initial SVM check for leaf candidate masks
%%%
%%%     Developed for LeafMachine.org
%%%
%%%     William Weaver
%%%     University of Colorado, Boulder
%%%     Department of Ecology and Evolutionary Biology


function [blobTable,blobFails] = initialSVMcheckAndClean(label,n,imgOrig,family,megapixels,imfillMasks,imfillMasksPartial,imfillMasksClump,netSVM,meanColorLeaf,meanColorBg,saveLeafCandidateMasks,filename,destinationDirectory)
    % Blob
    blobHeaders = {'id','SVMprediction','time','color','colorReport','bbox','bboxReport','area','perimeter','measurements'};
    blobData = cell(n,length(blobHeaders));
    blobTable = cell2table(blobData);
    blobTable.Properties.VariableNames = blobHeaders;
    
    [h,w,~] = size(imgOrig);
    
    INDblob = 1;
    
    INDblob_fail = 1;
    blobFails = {};
   
    % Iterate through glob candidate blobs
    if n > 0
        for i = 1:n
            % Crop imgOrig to the bounds + a bit extra 
            
            blobBox_temp = regionprops(label==i, 'BoundingBox');
            blobBox_tempLeaf = regionprops(label==i, 'BoundingBox');
            
            % Expand bbox a bit
            bound = round(blobBox_temp.BoundingBox);
            if megapixels < 18, FACTOR = h*.01; else, FACTOR = h*.01; end
            A = round(bound(1)-FACTOR);
            B = round(bound(2)-FACTOR);
            C = round(bound(3)+(FACTOR*2));
            D = round(bound(4)+(FACTOR*2));
            if A < 0, A = 0; end
            if B < 0, B = 0; end
            if A+C > w, C = w; end
            if B+D > h, D = h; end
            bound = [A B C D];
    
            % Crop
            imgCropBlob = imcrop(imgOrig,bound);
            labelBlobCrop = imcrop(label==i,bound);
            labelBlobCropFilled = imcrop(imfill(label==i,'holes'),bound);
            
            imgCropBlobG = rgb2gray(imgCropBlob);
            %imgCropBlobG(~labelBlobCrop) = 200;
            %figure(99);imshow(imgCropBlobG)
            
            
            %%%% Compare the labeled area to the background. A very small
            % deltaE means that the colors are similar. I test the labeled
            % region and the unlabeled region as validation. If both values
            % are small, then the leaf-labeled region is at least the same
            % color as leaves. 
            [deltaE_Leaf,M1,M2] = deltaE_blobsGrayscale_Compare(imgCropBlobG(labelBlobCrop),meanColorLeaf); % Compare labeled region to avg leaf color
            [deltaE_Bg,M3,M4] = deltaE_blobsGrayscale_Compare(imgCropBlobG(~labelBlobCrop),meanColorBg); % Compare UN-labeled region to avg bg color
            [deltaE_Bg_VS_Leaf,M5,M6] = deltaE_blobsGrayscale_Compare(imgCropBlobG(~labelBlobCrop),meanColorLeaf); % Compare UN-labeled region to avg bg color
            if deltaE_Leaf < 10
                COLORMATCH = 1;
            elseif (deltaE_Leaf < 20) && (deltaE_Bg < 20)%18
                COLORMATCH = 1;
            elseif (deltaE_Leaf < 20) && (deltaE_Bg_VS_Leaf > 100)%18
                COLORMATCH = 1;
            elseif (M3 > 200) && (deltaE_Bg_VS_Leaf > 100)%18
                COLORMATCH = 1;
            else
                COLORMATCH = 0;
            end
            
            
            %LEAF
            if imfillMasks == "True"
                labelBlobCropLeaf = labelBlobCropFilled;
            else
                labelBlobCropLeaf = labelBlobCrop;
            end
            %PARTIAL
            if imfillMasksPartial == "True"
                labelBlobCropPartial = labelBlobCropFilled;
            else
                labelBlobCropPartial = labelBlobCrop;
            end
            %CLUMP
            if imfillMasksClump == "True"
                labelBlobCropClump = labelBlobCropFilled;
            else
                labelBlobCropClump = labelBlobCrop;
            end
            
            

            % Put label into SVM
            % ***Run binary blob through SVM***
            %sprintf("initial")

            UNKNOWN = buildSVMdataset_oneImage(logical(labelBlobCrop),family,megapixels);
            if ~isempty(UNKNOWN)
                
                %%%% Split based on COLORMATCH 
                if COLORMATCH == 1
                    
                    %%%%%%%%%%%
                    %%% SVM %%%
                    %%%%%%%%%%%
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
                        % Save binary --optional, used for SVM training
                        saveBinaryMasks(filename,fullfile(destinationDirectory,'Leaf_Partial'),labelBlobCropPartial,['LeafPartial__SVM__BINARY__',int2str(i)]);
                        saveBinaryMasks(filename,fullfile(destinationDirectory,'Leaf_Partial'),imgCropBlob,['LeafPartial__SVM__RGB__',int2str(i)]);

                        % Get color
                        blobTable.color{INDblob} = [0, 0.4470, 0.7410];%pickColor(i,COLOR);
                        blobTable.colorReport{INDblob} = strjoin(['[',strjoin(string([0, 0.4470, 0.7410]),' '),']'],''); 

                        % Get measurements
                        blobTable.measurements{INDblob} = measureLeafFeatures(labelBlobCropPartial,bound);

                        %%% Save measurements upon "leaf" success
                        % Export final leaf binary
                        blobTable.id{INDblob} = i;
                        blobTable.SVMprediction{INDblob} = 'Leaf_Partial';
                        blobTable.time{INDblob} = datestr(now,'mm-dd-yyyy HH-MM-SS.FFF');
                        blobTable.bbox{INDblob} = blobBox_temp;
                        blobTable.bboxReport{INDblob} = strjoin(['[',strjoin(string(blobBox_temp.BoundingBox),' '),']'],'');
                        blobTable.area{INDblob} = bwarea(labelBlobCropPartial);
                        blobTable.perimeter{INDblob} = struct2array(regionprops(labelBlobCropPartial,'Perimeter'));

                        blobFails{INDblob_fail} = labelBlobCropPartial;
                        INDblob_fail = INDblob_fail + 1;

                        INDblob = INDblob + 1;

                    elseif yfit == "clump"
                        % Save binary --optional, used for SVM training
                        saveBinaryMasks(filename,fullfile(destinationDirectory,'Leaf_Clump'),labelBlobCropClump,['LeafClump__SVM__BINARY__',int2str(i)]);
                        saveBinaryMasks(filename,fullfile(destinationDirectory,'Leaf_Clump'),imgCropBlob,['LeafClump__SVM__RGB__',int2str(i)]);

                        % Get color
                        blobTable.color{INDblob} = [0.8500, 0.3250, 0.0980];%pickColor(i,COLOR);
                        blobTable.colorReport{INDblob} = strjoin(['[',strjoin(string([0.8500, 0.3250, 0.0980]),' '),']'],''); 

                        % Get measurements
                        blobTable.measurements{INDblob} = measureLeafFeatures(labelBlobCropClump,bound);

                        %%% Save measurements upon "leaf" success
                        % Export final leaf binary
                        blobTable.id{INDblob} = i;
                        blobTable.SVMprediction{INDblob} = 'Leaf_Clump';
                        blobTable.time{INDblob} = datestr(now,'mm-dd-yyyy HH-MM-SS.FFF');
                        blobTable.bbox{INDblob} = blobBox_temp;
                        blobTable.bboxReport{INDblob} = strjoin(['[',strjoin(string(blobBox_temp.BoundingBox),' '),']'],'');
                        blobTable.area{INDblob} = bwarea(labelBlobCropClump);
                        blobTable.perimeter{INDblob} = struct2array(regionprops(labelBlobCropClump,'Perimeter'));

                        blobFails{INDblob_fail} = labelBlobCropClump;
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
                elseif COLORMATCH == 0
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