%%%     Call function to stitch C from semanticseg() output
%%%     smaller images back into the original
%%%
%%%     Developed for LeafMachine.org
%%%
%%%     William Weaver
%%%     University of Colorado, Boulder
%%%     Department of Ecology and Evolutionary Biology



function imgOut= imageStitch9xC(imgC9x)
    
    B1 = imgC9x{1};
    B2 = imgC9x{2};
    B3 = imgC9x{3};
    B4 = imgC9x{4};
    B5 = imgC9x{5};
    B6 = imgC9x{6};
    B7 = imgC9x{7};
    B8 = imgC9x{8};
    B9 = imgC9x{9};
    
    imgOut = [B1,B2,B3;...
        B4,B5,B6;...
        B7,B8,B9];
    
end