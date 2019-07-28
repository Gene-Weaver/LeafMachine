%%%     Save binary masks 
%%%
%%%     Developed for LeafMachine.org
%%%
%%%     William Weaver
%%%     University of Colorado, Boulder
%%%     Department of Ecology and Evolutionary Biology

function saveBinaryMasks(filename,destinationDirectory,binaryMasks,id)
    imwrite(binaryMasks,strcat(destinationDirectory,'\',filename,'__',id,'.png',''));
end