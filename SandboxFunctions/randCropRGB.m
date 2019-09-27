%%%     Crop RGB Taining Images
%%%     Developed for LeafMachine.org
%%%
%%%     William Weaver
%%%     University of Colorado, Boulder
%%%     Department of Ecology and Evolutionary Biology

% cropDim assumes the cropped image will be square, i.e. 256x256
function img_Cropped = randCropRGB(img,cropDim,ShowCroppedImage)
    %img_Yellow = imread('yellowish.jpg');
    %img_White = imread('whiteish.jpg');
    %img = imread('Demo2.jpg');
    %img = imread('Demo.JPG');
    h = cropDim - 1;
    w = cropDim - 1;
    
    [img_dimH,img_dimW,~] = size(img);
    % Determine boundary of area suitable for random cropping
    range_dimH = img_dimH - h - 1;
    range_dimW = img_dimW - w - 1;

    % S = 0;
    % M = 200 
    % while( S < 51 || M > 80) just in case it needs to be done...
    
    % Generate random top left pixel 
    ymin = randi(range_dimH);
    xmin = randi(range_dimW);

    rect = [xmin ymin w h];
    img_Cropped = imcrop(img,rect);
    
    switch ShowCroppedImage
        case 'True'
            imshow(img_Cropped)
        case 'TRUE'
            imshow(img_Cropped)
        otherwise
    end
    % S = std2(img_Cropped);
    % M = mean2(img_Cropped);
    % CCy = corr2(img_Cropped(:,:,1),img_Yellow(:,:,1))
    % CCw = corr2(img_Cropped(:,:,1),img_White(:,:,1))
    % size(img_Cropped)
    % end
end