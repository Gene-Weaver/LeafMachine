%%%     Find leaves using the binary-strel-lazysnapping method
%%%
%%%     Developed for LeafMachine.org
%%%
%%%     William Weaver
%%%     University of Colorado, Boulder
%%%     Department of Ecology and Evolutionary Biology

%%% This is the structural element method for finding individual leaves in
%%% an image. It is not designed to find one leaf in a group of overlapping
%%% leaves. The algorithm gets the masks from the ML segmentation and creates
%%% 7 structural elements (strel) - 4 line elements for finding long blades
%%% of grass etc. and 3 globular strels for rounder leaves. I take the 
%%% union of the line strels and the intersection of the globular. 

function [compositeGlobular,compositeLine,globData,lineData] = findLeavesBinaryStrel(img,imgSize,C,feature,radius,cirAprox,COLOR)
    % Build strel size
    % Default: radius = 30, cirAprox = 4
    SE = setStrelSize(radius,cirAprox);
    % Get binaryMasks from C, which is from segmentation
    % binaryMasks{1:5} = {Leaf,Background,Stem,Text_Black,Fruit_Flower};
    binaryMasks = getBinaryMasks(C);
    
    % Get UNION of "line strel" imerode masks
    compositeLine = fuseLineBinary(binaryMasks,SE,feature);
    %figure,imshow(compositeLine)
    
    % Get INTERSECTION of globular imerode masks
    compositeGlobular = fuseGlobularBinary(binaryMasks,SE,feature);
    %figure,imshow(compositeGlobular)
    
    % Ignore areas smaller than 25 pixels
    compositeLine = bwareaopen(compositeLine,25);
    compositeGlobular = bwareaopen(compositeGlobular,25);
 
    % Count number of potential solitary leaves
    [labelGlob, nGlob] = bwlabel(compositeGlobular);
    [labelLine, nLine] = bwlabel(compositeLine);
    
    [globData,lineData] = runLazySnappingForBlobs(labelGlob,labelLine,nGlob,nLine,img,imgSize,COLOR);
%     imshow(lineData{6}{1})
%     imshow(globData{6}{1})
end