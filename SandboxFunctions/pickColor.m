%%%     Pick color
%%%
%%%     Developed for LeafMachine.org
%%%
%%%     William Weaver
%%%     University of Colorado, Boulder
%%%     Department of Ecology and Evolutionary Biology

function color = pickColor(c,COLOR)
    % c < 30
    if c <= 0
        c = 1;
    end
     % c >= 30
    while c > length(COLOR)
        c = c-length(COLOR);
    end
    color = COLOR(c,:);
end