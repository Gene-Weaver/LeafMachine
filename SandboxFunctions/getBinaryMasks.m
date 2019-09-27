%%%     Get binary masks from 'C' variable from segmentation
%%%
%%%     Developed for LeafMachine.org
%%%
%%%     William Weaver
%%%     University of Colorado, Boulder
%%%     Department of Ecology and Evolutionary Biology

function binaryMasks = getBinaryMasks(C)
    % Retrieve binary masks
    stem = C == 'stem';
    leaf = C == 'leaf';
    text = C == 'text';
    fruitFlower = C == 'fruitFlower';
    background = C == 'background';
    binaryMasks = {leaf,stem,fruitFlower,background,text};
end