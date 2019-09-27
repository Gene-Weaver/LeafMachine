%%%     setBackgoundPoints for lazysnapping in binarystrel method
%%%
%%%     Developed for LeafMachine.org
%%%
%%%     William Weaver
%%%     University of Colorado, Boulder
%%%     Department of Ecology and Evolutionary Biology

function [dimX,dimY,SPS,EWS] = setBackgoundPoints(cX,cY)
    dimX = [15;15            ;15   ;round(cY-15/2);cY-15;cY-15         ;cY-15;round(cY-15/2);20];
    dimY = [15;round(cX-15/2);cX-15;cX-15         ;cX-15;round(cX-15/2);15   ;round(cX-15/2);15];
    %EWS = 1000;
    sps = cX*cY;
    if sps <= 250000
        SPS = 350;
        EWS = 500;
    elseif sps > 250000
        SPS = 500;
        EWS = 500;
    elseif sps > 360000
        SPS = 700;
        EWS = 500;
    elseif sps > 490000
        SPS = 900;
        EWS = 600;
    elseif sps > 640000
        SPS = 1200;
        EWS = 600;
    elseif sps > 722500
        SPS = 1400;
        EWS = 750;
    elseif sps > 810000
        SPS = 1500;
        EWS = 750;
    end
end