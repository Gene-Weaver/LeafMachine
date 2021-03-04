%%%     Watershed segmentation to clean binary object 
%%%
%%%     Developed for LeafMachine.org
%%%
%%%     William Weaver
%%%     University of Colorado, Boulder
%%%     Department of Ecology and Evolutionary Biology

function cleanLeaf = watershedCleanup(imgCrop,strelSize)
    % Binarize output from lazysnapping
    imgCropBinary = imbinarize(rgb2gray(imgCrop));
    
    % Take only largest blog if there are multiple
    imgCropBinaryMessy = bwareafilt(imgCropBinary,1);
    %imshow(imgCropBinaryMessy)

    % Shrink leaf to find outliers, used for mask in imimposemin()
    mask = imerode(imgCropBinaryMessy,strel('octagon',strelSize));
    
    % Watershed segmentation prep
    W = -bwdist(~imgCropBinaryMessy,'quasi-euclidean');
    W(~imgCropBinaryMessy) = -inf;  
    
    % Correct oversegmentation 
    mask2 = imimposemin(W,mask);
    W2 = watershed(mask2);
    cleanLeaf = imgCropBinaryMessy;
    cleanLeaf(W2 == 0) = 0;

    % Keep only larest object
    cleanLeaf = bwareafilt(cleanLeaf,1);
    
    % Fill small holes
    cleanLeaf = imfill(cleanLeaf,'holes');
    %imshow(cleanLeaf)

end