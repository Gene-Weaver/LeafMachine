%%%     Function to merge "line" imerode binary masks
%%%
%%%     Developed for LeafMachine.org
%%%
%%%     William Weaver
%%%     University of Colorado, Boulder
%%%     Department of Ecology and Evolutionary Biology

function compositeLine = fuseLineBinary(binaryMasks,SE,feature)
    erode0 = imerode(binaryMasks{feature},SE{4});
    erode45 = imerode(binaryMasks{feature},SE{5});
    erode90 = imerode(binaryMasks{feature},SE{6});
    erode135 = imerode(binaryMasks{feature},SE{7});

    compositeLineDouble = erode0+erode45+erode90+erode135;
    compositeLine = logical(compositeLineDouble);
end

% r = 30;
% n = 4;
% SE1 = strel('diamond',r);
% SE2 = strel('disk',r,n);
% SE3 = strel('octagon',r);
% SE4 = strel('line',r,0);%Long leaves
% SE5 = strel('line',r,45);%Long leaves
% SE6 = strel('line',r,90);%Long leaves
% SE7 = strel('line',r,135);%Long leaves
% SE = {SE1,SE2,SE3,SE4,SE5,SE6,SE7};