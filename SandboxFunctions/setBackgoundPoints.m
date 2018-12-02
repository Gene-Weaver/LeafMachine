%%%     setBackgoundPoints for lazysnapping in binarystrel method
%%%
%%%     Developed for LeafMachine.org
%%%
%%%     William Weaver
%%%     University of Colorado, Boulder
%%%     Department of Ecology and Evolutionary Biology

function [dimX,dimY,SPS] = setBackgoundPoints(cX,cY)
    dimX = [15;15            ;15   ;round(cY-15/2);cY-15;cY-15         ;cY-15;round(cY-15/2);20];
    dimY = [15;round(cX-15/2);cX-15;cX-15         ;cX-15;round(cX-15/2);15   ;round(cX-15/2);15];
    
    sps = cX*cY;
    if sps < 160000
        SPS = 200;
    else
        SPS = 500;
    end
end