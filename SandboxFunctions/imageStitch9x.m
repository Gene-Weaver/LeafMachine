%%%     Call function to stitch
%%%     smaller images back into the original
%%%
%%%     Developed for LeafMachine.org
%%%
%%%     William Weaver
%%%     University of Colorado, Boulder
%%%     Department of Ecology and Evolutionary Biology



function imgOut= imageStitch9x(imgC9x,imgOrigCrop9x)
    
    B1 = labeloverlay(imgOrigCrop9x{1},imgC9x{1});
    B2 = labeloverlay(imgOrigCrop9x{2},imgC9x{2});
    B3 = labeloverlay(imgOrigCrop9x{3},imgC9x{3});
    B4 = labeloverlay(imgOrigCrop9x{4},imgC9x{4});
    B5 = labeloverlay(imgOrigCrop9x{5},imgC9x{5});
    B6 = labeloverlay(imgOrigCrop9x{6},imgC9x{6});
    B7 = labeloverlay(imgOrigCrop9x{7},imgC9x{7});
    B8 = labeloverlay(imgOrigCrop9x{8},imgC9x{8});
    B9 = labeloverlay(imgOrigCrop9x{9},imgC9x{9});
    
    imgOut = [B1,B2,B3;...
        B4,B5,B6;...
        B7,B8,B9];
    
end