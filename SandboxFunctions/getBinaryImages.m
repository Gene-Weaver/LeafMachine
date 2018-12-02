%%%     Get binary images from 'C' variable from segmentation
%%%
%%%     Developed for LeafMachine.org
%%%
%%%     William Weaver
%%%     University of Colorado, Boulder
%%%     Department of Ecology and Evolutionary Biology

function binaryImages = getBinaryImages(C)
    % Retrieve binary masks
    Stem = C == 'Stem';
    Stem = 255 * repmat(uint8(Stem), 1, 1, 3);
    Leaf = C == 'Leaf';
    Leaf = 255 * repmat(uint8(Leaf), 1, 1, 3);
    Text_Black = C == 'Text_Black';
    Text_Black = 255 * repmat(uint8(Text_Black), 1, 1, 3);
    Fruit_Flower = C == 'Fruit_Flower';
    Fruit_Flower = 255 * repmat(uint8(Fruit_Flower), 1, 1, 3);
    Background = C == 'Background';
    Background = 255 * repmat(uint8(Background), 1, 1, 3);
    binaryImages = {Leaf,Background,Stem,Text_Black,Fruit_Flower};
end