%%%     Save binary masks 
%%%
%%%     Developed for LeafMachine.org
%%%
%%%     William Weaver
%%%     University of Colorado, Boulder
%%%     Department of Ecology and Evolutionary Biology

function saveBinaryMasks(filename,destinationDirectory,binaryMasks,id)
    if isunix
        imwrite(binaryMasks,strcat(destinationDirectory,'/',filename,'__',id,'.png',''));
    elseif ispc
        imwrite(binaryMasks,strcat(destinationDirectory,'\',filename,'__',id,'.png',''));
    elseif ismac
        imwrite(binaryMasks,strcat(destinationDirectory,'\',filename,'__',id,'.png',''));
    end
end