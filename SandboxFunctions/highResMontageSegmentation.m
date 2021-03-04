%%%     High Resolution Segmentation
%%%     Developed for LeafMachine.org
%%%
%%%     William Weaver
%%%     University of Colorado, Boulder
%%%     Department of Ecology and Evolutionary Biology

%%% For filename of output, if imgIn is an image, filenameSuffix should be
%%% 'Betulaceae_Betula_lenta'
%%% Otherwise, if the function calls imread, then the name is auto
%%% generated and filenameSuffix is just whatever is appended to original
%%% filename


function highResMontageSegmentation(net,filename,destinationDirectory,imgIn,gpu_cpu,show)
    addpath('SandboxFunctions');
    if length(size(imgIn)) ~= 3
        imgIn = imread(imgIn);
    end   
    
    % Crop the image into 9 pieces
    imgOrigCrop9x = imageCrop9x(imgIn);
    imgOrigCrop81x = {0,0,0,0,0,0,0,0,0};
    for i = 1:9
        imgOrigCrop81x{i} = imageCrop9x(imgOrigCrop9x{i});
    end
   
    % Segment each piece
    imgData = {0, 0, 0, 0, 0, 0, 0, 0, 0};
    imgSeg81x = {0, 0, 0, 0, 0, 0, 0, 0, 0};
    for i = 1:9
        imgSeg9x = imgOrigCrop81x{i};
        imgData81x = {0, 0, 0, 0, 0, 0, 0, 0, 0};
        imgC9x = {0, 0, 0, 0, 0, 0, 0, 0, 0};
        for j = 1:9
            [C, scores, allScores] = semanticseg(imgSeg9x{j},net,'ExecutionEnvironment',gpu_cpu);
            imgC9x{j} = C;
            imgData81x{j} = {scores, allScores};
            %reset(gpuDevice)
        end
        imgSeg81x{i} = imgC9x;
        imgData{i} = imgData81x;
    end
    
    % Put the peices back together
    segImage9x = {0,0,0,0,0,0,0,0,0};
    %segImage9xData = {0,0,0,0,0,0,0,0,0};
    for i = 1:9
        from81x = imgSeg81x{i};
        %from81xData = imgData{1, 1}{1, 1}{1, 2};
        segImage9x{i} = imageStitch9x(from81x,imgOrigCrop81x{i});
        %segImage9xData{i} = imageStitch9xC(from81xData);
        
%         C = from81x;
%         Stem = C == 'Stem';
%         Stem = 255 * repmat(uint8(Stem), 1, 1, 3);
%         Leaf = C == 'Leaf';
%         Leaf = 255 * repmat(uint8(Leaf), 1, 1, 3);
%         Text_Black = C == 'Text_Black';
%         Text_Black = 255 * repmat(uint8(Text_Black), 1, 1, 3);
%         Text_White = C == 'Text_White';
%         Text_White = 255 * repmat(uint8(Text_White), 1, 1, 3);
%         Fruit_Flower = C == 'Fruit_Flower';
%         Fruit_Flower = 255 * repmat(uint8(Fruit_Flower), 1, 1, 3);
%         Background = C == 'Background';
%         Background = 255 * repmat(uint8(Background), 1, 1, 3);
%         Colorblock = C == 'Colorblock';
%         Colorblock = 255 * repmat(uint8(Colorblock), 1, 1, 3);
%         imshow(Background)
    end
    
    segImage = [segImage9x{1},segImage9x{2},segImage9x{3};...
        segImage9x{4},segImage9x{5},segImage9x{6};...
        segImage9x{7},segImage9x{8},segImage9x{9}];
    
    % Retrieve binary masks
    Stem = segImage == 'Stem';
    Stem = 255 * repmat(uint8(Stem), 1, 1, 3);
    Leaf = segImage == 'Leaf';
    Leaf = 255 * repmat(uint8(Leaf), 1, 1, 3);
    Text_Black = segImage == 'Text_Black';
    Text_Black = 255 * repmat(uint8(Text_Black), 1, 1, 3);
    Text_White = segImage == 'Text_White';
    Text_White = 255 * repmat(uint8(Text_White), 1, 1, 3);
    Fruit_Flower = segImage == 'Fruit_Flower';
    Fruit_Flower = 255 * repmat(uint8(Fruit_Flower), 1, 1, 3);
    Background = segImage == 'Background';
    Background = 255 * repmat(uint8(Background), 1, 1, 3);
    Colorblock = segImage == 'Colorblock';
    Colorblock = 255 * repmat(uint8(Colorblock), 1, 1, 3);
    
    % Plot options
    if nClasses == 7
        PLOT = [image,Leaf,Stem,Text_Black,image;
            B,Text_White,Fruit_Flower,Background,Colorblock];
    elseif nClasses == 6
        PLOT = [image,Leaf,Stem,Text_Black;
            B,Text_White,Fruit_Flower,Colorblock];
    else
        PLOT = [image,Leaf,Stem,Text_Black,image;
            B,Text_White,Fruit_Flower,Background,Colorblock];
    end
    
    % Output
    destDir = fullfile(destinationDirectory,filename);
    imwrite(PLOT,destDir);
    if show == "show"
        imshow(PLOT)
    end
end