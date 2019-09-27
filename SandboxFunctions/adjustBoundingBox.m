


function bound2 = adjustBoundingBox(bound,size)
    H = size(1);
    W = size(2);
    
    A = bound(1)-70;
    B = bound(2)-70;
    C = bound(3)+140;
    D = bound(4)+140;
    
    if A < 0
        A = 0;
    end
    if C > W
        C = W;
    end
    if B < 0 
        B = 0;
    end
    bound2 = [A B C D];
end