%%%     Developed for LeafMachine.org
%%%
%%%     William Weaver
%%%     University of Colorado, Boulder
%%%     Department of Ecology and Evolutionary Biology

function QC_IMDS_PXDS(img,imds,pxds,classID)
    I = readimage(imds,img);
    C = readimage(pxds,img);
    B = labeloverlay(I,C);
    MASK = C == classID;
    MASK2 = 255 * repmat(uint8(MASK), 1, 1, 3);
    PLOT = [I,B,MASK2];
    imshow(PLOT)
end