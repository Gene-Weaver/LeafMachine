%%%     Test to see if binary image touches side 
%%%     "runLazySnappingforBlobs.m"
%%%
%%%     Developed for LeafMachine.org
%%%
%%%     William Weaver
%%%     University of Colorado, Boulder
%%%     Department of Ecology and Evolutionary Biology

function [touch,bound] = borderTouchTest(cleanLeaf,bound)
    img = imclearborder(cleanLeaf);
    [~, n] = bwlabel(img);
    if n > 0
        touch = 0;
    elseif (bound(1) && bound(2)) == 0 
        touch = 0;
    elseif n == 0
        touch = 1;
        if bound(1) > 50, bound(1) = bound(1)-50; else, bound(1) = 0; end
        if bound(2) > 50, bound(2) = bound(2)-50; else, bound(2) = 0; end
        bound(3) = bound(3)+100;
        bound(4) = bound(4)+100;
    end
end
