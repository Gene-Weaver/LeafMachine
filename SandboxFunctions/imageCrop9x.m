%%%     Take an image, crop it into smaller images, export smaller images
%%%     inside a cell to be segmented
%%%
%%%     Developed for LeafMachine.org
%%%
%%%     William Weaver
%%%     University of Colorado, Boulder
%%%     Department of Ecology and Evolutionary Biology

function imgOut = imageCrop9x(imgIn)
    nSplit = 3;
    [H, W, ~] = size(imgIn);
    H_Cr = int32(H/nSplit);
    W_Cr = int32(W/nSplit);  
    image1 = imgIn(1:H_Cr, 1:W_Cr,:);
    image2 = imgIn(1:H_Cr, W_Cr+1:2*W_Cr,:);
    image3 = imgIn(1:H_Cr, 2*W_Cr+1:W,:);
    image4 = imgIn(H_Cr+1:2*H_Cr, 1:W_Cr,:);
    image5 = imgIn(H_Cr+1:2*H_Cr, W_Cr+1:2*W_Cr,:);
    image6 = imgIn(H_Cr+1:2*H_Cr, 2*W_Cr+1:W,:);
    image7 = imgIn(2*H_Cr+1:H, 1:W_Cr,:);
    image8 = imgIn(2*H_Cr+1:H, W_Cr+1:2*W_Cr,:);
    image9 = imgIn(2*H_Cr+1:H, 2*W_Cr+1:W,:);

    imgOut = {image1,image2,image3,...
        image4,image5,image6,...
        image7,image8,image9};
end