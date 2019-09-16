%%%     Build File Structure
%%%
%%%     Developed for LeafMachine.org
%%%
%%%     William Weaver
%%%     University of Colorado, Boulder
%%%     Department of Ecology and Evolutionary Biology


function buildFileStructure(destinationDirectory,saveLeafCandidateMasks,processLazySnapping,local_url)
    formatSpec = "Time --- Generate File Structure: %.3f seconds \n";
    timeFile = tic();
    
    if ~exist(destinationDirectory, 'dir');mkdir(destinationDirectory);end
    
    
    if ~exist(fullfile(destinationDirectory,'Overlay'), 'dir');mkdir(fullfile(destinationDirectory,'Overlay'));end
    if ~exist(fullfile(destinationDirectory,'Segmentation'), 'dir');mkdir(fullfile(destinationDirectory,'Segmentation'));end
    if ~exist(fullfile(destinationDirectory,'Data'), 'dir');mkdir(fullfile(destinationDirectory,'Data'));end
    if ~exist(fullfile(destinationDirectory,'Data_Temp'), 'dir');mkdir(fullfile(destinationDirectory,'Data_Temp'));end
    if ~exist(fullfile(destinationDirectory,'Skipped_Files'), 'dir');mkdir(fullfile(destinationDirectory,'Skipped_Files'));end  

    if ~exist(fullfile(destinationDirectory,'Leaf'), 'dir');mkdir(fullfile(destinationDirectory,'Leaf'));end
    if ~exist(fullfile(destinationDirectory,'Leaf_Partial'), 'dir');mkdir(fullfile(destinationDirectory,'Leaf_Partial'));end
    if ~exist(fullfile(destinationDirectory,'Leaf_Clump'), 'dir');mkdir(fullfile(destinationDirectory,'Leaf_Clump'));end

    if ~exist(fullfile(destinationDirectory,'Class_Text'), 'dir');mkdir(fullfile(destinationDirectory,'Class_Text'));end
    if ~exist(fullfile(destinationDirectory,'Class_Leaf'), 'dir');mkdir(fullfile(destinationDirectory,'Class_Leaf'));end
    if ~exist(fullfile(destinationDirectory,'Class_Background'), 'dir');mkdir(fullfile(destinationDirectory,'Class_Background'));end
    if ~exist(fullfile(destinationDirectory,'Class_Stem'), 'dir');mkdir(fullfile(destinationDirectory,'Class_Stem'));end
    if ~exist(fullfile(destinationDirectory,'Class_FruitFlower'), 'dir');mkdir(fullfile(destinationDirectory,'Class_FruitFlower'));end

    if saveLeafCandidateMasks
        if ~exist(fullfile(destinationDirectory,'Leaf_Fail'), 'dir');mkdir(fullfile(destinationDirectory,'Leaf_Fail'));end
    end

    if processLazySnapping
        if ~exist(fullfile(destinationDirectory,'Leaf_LazySnapping'), 'dir');mkdir(fullfile(destinationDirectory,'Leaf_LazySnapping'));end
    end

    if local_url == "url"
        if ~exist(fullfile(destinationDirectory,'Original'), 'dir');mkdir(fullfile(destinationDirectory,'Original'));end
    end
    timeFile = toc(timeFile);
    fprintf(formatSpec,timeFile);
end