%%%     Run lazy snapping routine, many moving pieces
%%%
%%%     Developed for LeafMachine.org
%%%
%%%     William Weaver
%%%     University of Colorado, Boulder
%%%     Department of Ecology and Evolutionary Biology

function [globData,lineData] = runLazySnappingForBlobs(labelGlob,labelLine,nGlob,nLine,imgOrig,imgOrigSize,COLOR)
    % Isolate skels for each blob
    
    %%% Glob version 
    globID = cell(1,nGlob);
    globColor = cell(1,nGlob);
    globSkel = cell(1,nGlob);
    globNode = cell(1,nGlob);
    globBox = cell(1,nGlob);
    globSP = cell(1,nGlob);
    globLS = cell(1,nGlob);
    globCropLS = cell(1,nGlob);
    globMeasurements = cell(1,nGlob);
    for i = 1:nGlob
        globID{i} = i;
        globBox{i} = regionprops(labelGlob==i,'Area', 'BoundingBox');
        % Crop to quicken lazy snap
        bound = round(globBox{i}.BoundingBox);
        A = bound(1)-70;
        B = bound(2)-70;
        C = bound(3)+140;
        D = bound(4)+140;
        bound2 = [A B C D];
        imgCropGlob = imcrop(imgOrig,bound2);
        labelGlobCrop = imcrop(labelGlob,bound2);
        
        % Skeletonize and get nodes
        globSkel{i} = bwmorph(labelGlobCrop==i,'skel',Inf);
        globNode{i} = bwmorph(globSkel{i},'branchpoints');

        % Get Background Indices
        [cX,cY,cZ] = size(imgCropGlob);
        [dimX,dimY,SPS,EWS] = setBackgoundPoints(cX,cY);
        backgroundInd = sub2ind([cX,cY,cZ],dimY,dimX);
        % Get leaf indices
        [y, x] = find(globNode{i});
        foregroundInd = sub2ind([cX,cY,cZ],y,x);
        
        % Superixels and lazysnapping
        globSP{i} = superpixels(imgCropGlob,SPS);% 200, 500, 1000, 1200, 1500, hyper 2000
        try
            gLS = lazysnapping(imgCropGlob,globSP{i},foregroundInd,backgroundInd,'EdgeWeightScaleFactor',EWS);
        catch
            [y, x] = find(globSkel{i});
            foregroundInd = sub2ind([cX,cY,cZ],y,x);
            gLS = lazysnapping(imgCropGlob,globSP{i},foregroundInd,backgroundInd,'EdgeWeightScaleFactor',EWS);
        end
        globLS{i} = gLS;
        
        % Apply LS to imgCrop
        imgCropGlob(repmat(~gLS,[1 1 3])) = 0;
        
        % Run watershed cleanup
        cleanLeaf = watershedCleanup(imgCropGlob,9);
        %figure,imshow(cleanLeaf)
        
        % Export final leaf binary
        globCropLS{i} = cleanLeaf;
        
        % Get color
        globColor{i} = pickColor(i,COLOR);
        
        % Get measurements
        globMeasurements{i} = measureLeafFeatures(cleanLeaf,bound2);
        
        
    end
    globData = {nGlob,globID,globColor,globSkel,globNode,globBox,globSP,globLS,globCropLS,globMeasurements};
    
    %%% Line version 
    lineID = cell(1,nLine);
    lineColor = cell(1,nLine);
    lineSkel = cell(1,nLine);
    lineNode = cell(1,nLine);
    lineBox = cell(1,nLine);
    lineSP = cell(1,nLine);
    lineLS = cell(1,nLine);
    lineCropLS = cell(1,nLine);
    lineMeasurements = cell(1,nLine);
    for i = 1:nLine
        lineID{i} = i;
        lineBox{i} = regionprops(labelLine==i,'Area', 'BoundingBox');
        % Crop to quicken lazy snap
        bound = round(lineBox{i}.BoundingBox);
        bound2 = [bound(1)-70 bound(2)-70 bound(3)+140 bound(4)+140];
        imgCropLine = imcrop(imgOrig,bound2);
        labelLineCrop = imcrop(labelLine,bound2);

        % Skeletonize and get nodes
        lineSkel{i} = bwmorph(labelLineCrop==i,'skel',Inf);
        lineNode{i} = bwmorph(lineSkel{i},'branchpoints');

        % Get Background Indices
        [cX,cY,cZ] = size(imgCropLine);
        [dimX,dimY,SPS] = setBackgoundPoints(cX,cY);
        backgroundInd = sub2ind([cX,cY,cZ],dimY,dimX);
        
        % Get leaf indices
        [y, x] = find(lineNode{i});
        foregroundInd = sub2ind([cX,cY,cZ],y,x);

        % Superixels and lazysnapping
        lineSP{i} = superpixels(imgCropLine,SPS);% 200, 500, 1000, 1200, 1500, hyper 2000
        try
            lLS = lazysnapping(imgCropLine,lineSP{i},foregroundInd,backgroundInd,'EdgeWeightScaleFactor',750);
        catch
            [y, x] = find(lineSkel{i});
            foregroundInd = sub2ind([cX,cY,cZ],y,x);
            lLS = lazysnapping(imgCropLine,lineSP{i},foregroundInd,backgroundInd,'EdgeWeightScaleFactor',750);
        end
        lineLS{i} = lLS;
        
        % Apply LS to imgCrop
        imgCropLine(repmat(~lLS,[1 1 3])) = 0;
        
        % Run watershed cleanup
        cleanLeaf = watershedCleanup(imgCropLine,9);
        %figure,imshow(cleanLeaf)
        
        % Export final leaf binary
        lineCropLS{i} = cleanLeaf;
        
        % Get color
        lineColor{i} = pickColor(i,COLOR);
        
        % Get measurements
        lineMeasurements{i} = measureLeafFeatures(cleanLeaf,bound2);
        
    end
    lineData = {nLine,lineID,lineColor,lineSkel,lineNode,lineBox,lineSP,lineLS,lineCropLS,lineMeasurements};
end