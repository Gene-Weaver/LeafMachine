%%%     Get binary masks from 'C' variable from segmentation
%%%
%%%     Developed for LeafMachine.org
%%%
%%%     William Weaver
%%%     University of Colorado, Boulder
%%%     Department of Ecology and Evolutionary Biology

function binaryMasks = getBinaryMasks(C)
    % Retrieve binary masks
    Stem = C == 'Stem';
    Leaf = C == 'Leaf';
    Text_Black = C == 'Text_Black';
    Fruit_Flower = C == 'Fruit_Flower';
    Background = C == 'Background';
    binaryMasks = {Leaf,Background,Stem,Text_Black,Fruit_Flower};
end