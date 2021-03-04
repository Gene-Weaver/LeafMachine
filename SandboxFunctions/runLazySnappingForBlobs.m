%%%     Run lazy snapping routine, many moving pieces
%%%
%%%     Developed for LeafMachine.org
%%%
%%%     William Weaver
%%%     University of Colorado, Boulder
%%%     Department of Ecology and Evolutionary Biology

function [globTable,lineTable] = runLazySnappingForBlobs(labelGlob,labelLine,nGlob,nLine,imgOrig,imgOrigSize,family,megapixels,COLOR,netSVM,saveLeafCandidateMasks,filename,destinationDirectory)
    globHeaders = {'id','SVMprediction','time','color','colorReport','skel','node','bbox','bboxReport','superpixels','lazysnap','cropLazysnap','measurements','area','perimeter'};
    globData = cell(nGlob,length(globHeaders));
    globTable = cell2table(globData);
    globTable.Properties.VariableNames = globHeaders;
    
%     %%% Glob version 
%     globID = cell(1,nGlob);
%     globColor = cell(1,nGlob);
%     globSkel = cell(1,nGlob);
%     globNode = cell(1,nGlob);
%     globBox = cell(1,nGlob);
%     globSP = cell(1,nGlob);
%     globLS = cell(1,nGlob);
%     globCropLS = cell(1,nGlob);
%     globMeasurements = cell(1,nGlob);
    INDglob = 1;
    expandFactorM = 0.1*imgOrigSize(2);
    expandFactorN = 0.1*imgOrigSize(1);

    for i = 1:nGlob
        validateBounds = 1;
        touchBorder = 1;
        globID_temp = i;
        globBox_temp = regionprops(labelGlob==i, 'BoundingBox');
        % Crop to quicken lazy snap
        bound = round(globBox_temp.BoundingBox);
        A = bound(1)-expandFactorM;
        B = bound(2)-expandFactorN;
        C = bound(3)+2*expandFactorM;
        D = bound(4)+2*expandFactorN;
        if A < 0, A = 0; end
        if B < 0, B = 0; end
        if A+C > imgOrigSize(2), C = imgOrigSize(2)-A; end
        if B+D > imgOrigSize(1), D = imgOrigSize(1)-B; end
        bound2 = [A B C D];
        
        nExpandBbox = 0;

        while touchBorder
            nExpandBbox = nExpandBbox +1 ;
            imgCropGlob = imcrop(imgOrig,bound2);
            imgCropGlobRGB = imgCropGlob;
            labelGlobCrop = imcrop(labelGlob,bound2);

            % Skeletonize and get nodes
            globSkel_temp = bwmorph(labelGlobCrop==i,'skel',Inf);
            globNode_temp = bwmorph(globSkel_temp,'branchpoints');

            % Get Background Indices
            [cX,cY,cZ] = size(imgCropGlob);
            [dimX,dimY,SPS,EWS] = setBackgoundPoints(cX,cY);
            backgroundInd = sub2ind([cX,cY,cZ],dimY,dimX);
            % Get leaf indices
            [y, x] = find(globNode_temp);
            foregroundInd = sub2ind([cX,cY,cZ],y,x);

            % Superixels and lazysnapping
            globSP_temp = superpixels(imgCropGlob,SPS);% 200, 500, 1000, 1200, 1500, hyper 2000
            try
                gLS = lazysnapping(imgCropGlob,globSP_temp,foregroundInd,backgroundInd,'EdgeWeightScaleFactor',EWS);
            catch
                [y, x] = find(globSkel_temp);
                foregroundInd = sub2ind([cX,cY,cZ],y,x);
                gLS = lazysnapping(imgCropGlob,globSP_temp,foregroundInd,backgroundInd,'EdgeWeightScaleFactor',EWS);
            end

            % Apply LS to imgCrop
            imgCropGlob(repmat(~gLS,[1 1 3])) = 0;

            % Run watershed cleanup
            cleanLeaf = watershedCleanup(imgCropGlob,9);
            
            % Test to see if it touches the border
            [touchBorder,bound2] = borderTouchTest(cleanLeaf,bound2);
            validateBounds = boundsOverflowTest(bound2,imgOrigSize);
            if (validateBounds == 0 || nExpandBbox >= 4)
                touchBorder = 0;
            end
        end % while loop
        
        % If validateBounds is still == 1, then the blob was isolated, if
        % validateBounds == 0 then the edge of imgOrig would have been
        % touched
        if validateBounds
            % ***Run binary blob through SVM***
            %sprintf("glob")
            UNKNOWN = buildSVMdataset_oneImage(cleanLeaf,family,megapixels);
            if ~isempty(UNKNOWN)
                [prediction,score] = netSVM.predictFcn(UNKNOWN);
                if class(prediction) == "categorical"
                    yfit = string(prediction);
                elseif class(prediction) == "cell"
                    yfit = string(cell2mat(prediction));
                else
                    sprintf("prediction fail - blob")
                end
                %yfit = string(cell2mat(netSVM.predictFcn(UNKNOWN)));original
                if yfit == "leaf"
                    % Save binary --optional, used for SVM training
                    saveBinaryMasks(filename,destinationDirectory,cleanLeaf,['Leaf__LSglob__BINARY__',int2str(i)]);
                    saveBinaryMasks(filename,destinationDirectory,imgCropGlobRGB,['Leaf__LSglob__RGB__',int2str(i)]);

                    % Get color
                    globTable.color{INDglob} = [0.4940, 0.1840, 0.5560];%pickColor(i,COLOR);
                    globTable.colorReport{INDglob} = strjoin(['[',strjoin(string([0.4940, 0.1840, 0.5560]),' '),']'],''); 
    %                 globTable.colorReport{INDglob} = strjoin(['[',strjoin(string(pickColor(i,COLOR)),' '),']'],''); 
    %                 globColor{INDglob} = pickColor(i,COLOR);

                    % Get measurements
                    globTable.measurements{INDglob} = measureLeafFeatures(cleanLeaf,bound2);
                    globTable.area{INDglob} = bwarea(cleanLeaf);
                    globTable.perimeter{INDglob} = struct2array(regionprops(cleanLeaf,'Perimeter'));
    %                 globMeasurements{INDglob} = measureLeafFeatures(cleanLeaf,bound2);

                    %%% Save measurements upon "leaf" success
                    % Export final leaf binary
                    globTable.cropLazysnap{INDglob} = cleanLeaf;
                    globTable.id{INDglob} = globID_temp;
                    globTable.SVMprediction{INDglob} = 'Leaf';
                    globTable.time{INDglob} = datestr(now,'mm-dd-yyyy HH-MM-SS.FFF');
                    globTable.bbox{INDglob} = globBox_temp;
                    globTable.bboxReport{INDglob} = strjoin(['[',strjoin(string(globBox_temp.BoundingBox),' '),']'],'');
                    %globTable.bbox{INDglob} = globBox_temp;
                    globTable.skel{INDglob} = globSkel_temp;
                    globTable.node{INDglob} = globNode_temp;
                    globTable.superpixels{INDglob} = globSP_temp;
                    globTable.lazysnap{INDglob} = gLS;

    %                 {'id','color','skel','node','bbox','superpixels','lazysnap','cropLazysnap','measurements'};
    %                 globCropLS{INDglob} = cleanLeaf;
    %                 globID{INDglob} = globID_temp;
    %                 globBox{INDglob} = globBox_temp;
    %                 globSkel{INDglob} = globSkel_temp;
    %                 globNode{INDglob} = globNode_temp;
    %                 globSP{INDglob} = globSP_temp;
    %                 globLS{INDglob} = gLS;  
                    INDglob = INDglob + 1;
                    
                elseif yfit == "partialLeaf"
                    saveBinaryMasks(filename,destinationDirectory,cleanLeaf,['LeafPartial__LSglob__BINARY__',int2str(i)]);
                    saveBinaryMasks(filename,destinationDirectory,imgCropGlobRGB,['LeafPartial__LSglob__RGB__',int2str(i)]);
                    
                    % Get color
                    globTable.color{INDglob} = [0.75, 0, 0.75];%pickColor(i,COLOR);
                    globTable.colorReport{INDglob} = strjoin(['[',strjoin(string([0.75, 0, 0.75]),' '),']'],''); 
                    
                    % Get measurements
                    globTable.measurements{INDglob} = measureLeafFeatures(cleanLeaf,bound2);
                    globTable.area{INDglob} = bwarea(cleanLeaf);
                    globTable.perimeter{INDglob} = struct2array(regionprops(cleanLeaf,'Perimeter'));
                    
                    %%% Save measurements upon "leaf" success
                    % Export final leaf binary
                    globTable.cropLazysnap{INDglob} = cleanLeaf;
                    globTable.id{INDglob} = globID_temp;
                    globTable.SVMprediction{INDglob} = 'Leaf_Partial';
                    globTable.time{INDglob} = datestr(now,'mm-dd-yyyy HH-MM-SS.FFF');
                    %globTable.bbox{INDglob} = strjoin(['[',strjoin(string(globBox_temp),' '),']'],'');
                    globTable.bbox{INDglob} = globBox_temp;
                    globTable.bboxReport{INDglob} = strjoin(['[',strjoin(string(globBox_temp.BoundingBox),' '),']'],'');
                    globTable.skel{INDglob} = globSkel_temp;
                    globTable.node{INDglob} = globNode_temp;
                    globTable.superpixels{INDglob} = globSP_temp;
                    globTable.lazysnap{INDglob} = gLS;

                    INDglob = INDglob + 1;
                else
                    if saveLeafCandidateMasks
                        saveBinaryMasks(filename,destinationDirectory,cleanLeaf,['LeafFail__LSglob__BINARY__',int2str(i)]);
                        saveBinaryMasks(filename,destinationDirectory,imgCropGlobRGB,['LeafFail__LSglob__RGB__',int2str(i)]);
                    end
                end
            else
                sprintf("SVM lacked blob to measure")
            end
        else
            saveBinaryMasks(filename,destinationDirectory,cleanLeaf,['glob__TOUCHEDBORDER__',int2str(i)]);
        end

    end
%     globData = {nGlob,globID,globColor,globSkel,globNode,globBox,globSP,globLS,globCropLS,globMeasurements};
    if INDglob == 1,globTable = [];end
    if ~isempty(globTable)
        idx = all(cellfun(@isempty,globTable{:,:}),2);
        globTable(idx,:) = [];
    end
    
    
    
    
    %%% Line version 
    lineHeaders = {'id','SVMprediction','time','color','colorReport','skel','node','bbox','bboxReport','superpixels','lazysnap','cropLazysnap','measurements','area','perimeter'};
    lineData = cell(nLine,length(lineHeaders));
    lineTable = cell2table(lineData);
    lineTable.Properties.VariableNames = lineHeaders;
    INDline = 1;
    
%     lineID = cell(1,nLine);
%     lineColor = cell(1,nLine);
%     lineSkel = cell(1,nLine);
%     lineNode = cell(1,nLine);
%     lineBox = cell(1,nLine);
%     lineSP = cell(1,nLine);
%     lineLS = cell(1,nLine);
%     lineCropLS = cell(1,nLine);
%     lineMeasurements = cell(1,nLine);

    for i = 1:nLine
        validateBounds = 1;
        touchBorder = 1;
        lineID_temp = i;
        lineBox_temp = regionprops(labelLine==i, 'BoundingBox');
        % Crop to quicken lazy snap
        bound = round(lineBox_temp.BoundingBox);
        A = bound(1)-expandFactorM;
        B = bound(2)-expandFactorN;
        C = bound(3)+2*expandFactorM;
        D = bound(4)+2*expandFactorN;
        if A < 0, A = 0; end
        if B < 0, B = 0; end
        if A+C > imgOrigSize(2), C = imgOrigSize(2)-A; end
        if B+D > imgOrigSize(1), D = imgOrigSize(1)-B; end
        bound2 = [A B C D];
        
        nExpandBbox = 0;
        
        while touchBorder
            nExpandBbox = nExpandBbox + 1;
            imgCropLine = imcrop(imgOrig,bound2);
            imgCropLineRGB = imgCropLine;
            labelLineCrop = imcrop(labelLine,bound2);

            % Skeletonize and get nodes
            lineSkel_temp = bwmorph(labelLineCrop==i,'skel',Inf);
            lineNode_temp = bwmorph(lineSkel_temp,'branchpoints');

            % Get Background Indices
            [cX,cY,cZ] = size(imgCropLine);
            [dimX,dimY,SPS,EWS] = setBackgoundPoints(cX,cY);
            backgroundInd = sub2ind([cX,cY,cZ],dimY,dimX);
            % Get leaf indices
            [y, x] = find(lineNode_temp);
            foregroundInd = sub2ind([cX,cY,cZ],y,x);

            % Superixels and lazysnapping
            lineSP_temp = superpixels(imgCropLine,SPS);% 200, 500, 1000, 1200, 1500, hyper 2000
            try
                lLS = lazysnapping(imgCropLine,lineSP_temp,foregroundInd,backgroundInd,'EdgeWeightScaleFactor',EWS);
            catch
                [y, x] = find(lineSkel_temp);
                foregroundInd = sub2ind([cX,cY,cZ],y,x);
                lLS = lazysnapping(imgCropLine,lineSP_temp,foregroundInd,backgroundInd,'EdgeWeightScaleFactor',EWS);
            end

            % Apply LS to imgCrop
            imgCropLine(repmat(~lLS,[1 1 3])) = 0;

            % Run watershed cleanup
            cleanLeaf = watershedCleanup(imgCropLine,9);
            
            % Test to see if it touches the border
            [touchBorder,bound2] = borderTouchTest(cleanLeaf,bound2);
            validateBounds = boundsOverflowTest(bound2,imgOrigSize);
            if (validateBounds == 0 || nExpandBbox >= 4)
                touchBorder = 0;
            end
        end % while loop
        
        % If validateBounds is still == 1, then the blob was isolated, if
        % validateBounds == 0 then the edge of imgOrig would have been
        % touched
        if validateBounds
            % ***Run binary blob through SVM***
            %sprintf("line")
            UNKNOWN = buildSVMdataset_oneImage(cleanLeaf);
            if ~isempty(UNKNOWN)
                prediction = netSVM.predictFcn(UNKNOWN);
                if class(prediction) == "categorical"
                    yfit = string(prediction);
                elseif class(prediction) == "cell"
                    yfit = string(cell2mat(prediction));
                else
                    sprintf("prediction fail - line")
                end
                %yfit = string(cell2mat(netSVM.predictFcn(UNKNOWN)));
                if yfit == "leaf"
                    % Save binary --optional, used for SVM training
                    saveBinaryMasks(filename,destinationDirectory,cleanLeaf,['Leaf__LSline__BINARY__',int2str(i)]);
                    saveBinaryMasks(filename,destinationDirectory,imgCropLineRGB,['Leaf__LSline__RGB__',int2str(i)]);

                    % Get color
                    lineTable.color{INDline} = [0.4940, 0.1840, 0.5560];%pickColor(i,COLOR);
                    lineTable.colorReport{INDline} = strjoin(['[',strjoin(string([0.4940, 0.1840, 0.5560]),' '),']'],''); 
                    %lineTable.colorReport{INDline} = strjoin(['[',strjoin(string(pickColor(i,COLOR)),' '),']'],''); 

                    % Get measurements
                    lineTable.measurements{INDline} = measureLeafFeatures(cleanLeaf,bound2);
                    lineTable.area{INDline} = bwarea(cleanLeaf);
                    lineTable.perimeter{INDline} = struct2array(regionprops(cleanLeaf,'Perimeter'));
                    
                    %%% Save measurements upon "leaf" success
                    % Export final leaf binary
                    lineTable.cropLazysnap{INDline} = cleanLeaf;
                    lineTable.id{INDline} = lineID_temp;
                    lineTable.SVMprediction{INDline} = 'Leaf_Partial';
                    lineTable.time{INDline} = datestr(now,'mm-dd-yyyy HH-MM-SS.FFF');
                    %globTable.bbox{INDglob} = strjoin(['[',strjoin(string(globBox_temp),' '),']'],'');
                    lineTable.bbox{INDline} = lineBox_temp;
                    lineTable.bboxReport{INDline} = strjoin(['[',strjoin(string(lineBox_temp.BoundingBox),' '),']'],'');
                    lineTable.skel{INDline} = lineSkel_temp;
                    lineTable.node{INDline} = lineNode_temp;
                    lineTable.superpixels{INDline} = lineSP_temp;
                    lineTable.lazysnap{INDline} = lLS;

                    INDline = INDline + 1;
                elseif yfit == "partialLeaf"
                    saveBinaryMasks(filename,destinationDirectory,cleanLeaf,['LeafPartial__LSline__BINARY__',int2str(i)]);
                    saveBinaryMasks(filename,destinationDirectory,imgCropLineRGB,['LeafPartial__LSline__RGB__',int2str(i)]);

                    % Get color
                    lineTable.color{INDline} = [0.75, 0, 0.75];%pickColor(i,COLOR);
                    lineTable.colorReport{INDline} = strjoin(['[',strjoin(string([0.75, 0, 0.75]),' '),']'],''); 
                    %lineTable.colorReport{INDline} = strjoin(['[',strjoin(string(pickColor(i,COLOR)),' '),']'],''); 

                    % Get measurements
                    lineTable.measurements{INDline} = measureLeafFeatures(cleanLeaf,bound2);
                    lineTable.area{INDline} = bwarea(cleanLeaf);
                    lineTable.perimeter{INDline} = struct2array(regionprops(cleanLeaf,'Perimeter'));
                    
                    %%% Save measurements upon "leaf" success
                    % Export final leaf binary
                    lineTable.cropLazysnap{INDline} = cleanLeaf;
                    lineTable.id{INDline} = lineID_temp;
                    lineTable.SVMprediction{INDline} = 'Leaf_Partial';
                    lineTable.time{INDline} = datestr(now,'mm-dd-yyyy HH-MM-SS.FFF');
                    %globTable.bbox{INDglob} = strjoin(['[',strjoin(string(globBox_temp),' '),']'],'');
                    lineTable.bbox{INDline} = lineBox_temp;
                    lineTable.bboxReport{INDline} = strjoin(['[',strjoin(string(lineBox_temp.BoundingBox),' '),']'],'');
                    lineTable.skel{INDline} = lineSkel_temp;
                    lineTable.node{INDline} = lineNode_temp;
                    lineTable.superpixels{INDline} = lineSP_temp;
                    lineTable.lazysnap{INDline} = lLS;

                    INDline = INDline + 1;
                else
                    saveBinaryMasks(filename,destinationDirectory,cleanLeaf,['LeafFail__LSline__BINARY__',int2str(i)]);
                    saveBinaryMasks(filename,destinationDirectory,imgCropLineRGB,['LeafFail__LSline__RGB__',int2str(i)]);
                end
            else
                sprintf("SVM lacked blob to measure")
            end
        else
            saveBinaryMasks(filename,destinationDirectory,cleanLeaf,['line__TOUCHEDBORDER__',int2str(i)]);
        end

    end
    if INDline == 1,lineTable = [];end   
    if ~isempty(lineTable)
        idx = all(cellfun(@isempty,lineTable{:,:}),2);
        lineTable(idx,:) = [];
    end
end