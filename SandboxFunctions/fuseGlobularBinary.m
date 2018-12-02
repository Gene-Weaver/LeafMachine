%%%     Function to get intersection between imerode binary globular masks
%%%
%%%     Developed for LeafMachine.org
%%%
%%%     William Weaver
%%%     University of Colorado, Boulder
%%%     Department of Ecology and Evolutionary Biology

function compositeGlobular = fuseGlobularBinary(binaryMasks,SE,feature)
    diamond = imerode(binaryMasks{feature},SE{1});
    disk = imerode(binaryMasks{feature},SE{2});
    octagon = imerode(binaryMasks{feature},SE{3});

    compositeGlobularDouble = diamond+disk+octagon;
    maxVal = max(max(compositeGlobularDouble));
    compositeGlobularDoubleMax = compositeGlobularDouble == maxVal;
    compositeGlobular = logical(compositeGlobularDoubleMax);
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