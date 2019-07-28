%%%     Test to see if binary image touches side and surpasses orig image
%%%     bounds
%%%     "runLazySnappingforBlobs.m"
%%%
%%%     Developed for LeafMachine.org
%%%
%%%     William Weaver
%%%     University of Colorado, Boulder
%%%     Department of Ecology and Evolutionary Biology

function validate = boundsOverflowTest(bound,origSize)
    %if (bound(1) <= 0) || (bound(2) <= 0) || (bound(1)+bound(3) > origSize(2)) || (bound(2)+bound(4) > origSize(1))
    if (bound(1)+bound(3) > origSize(2)) || (bound(2)+bound(4) > origSize(1))
        validate = 0;
    else
        validate = 1;
    end
end