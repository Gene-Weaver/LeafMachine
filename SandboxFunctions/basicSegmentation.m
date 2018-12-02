%%%     Basic Segmentation
%%%     Developed for LeafMachine.org
%%%
%%%     William Weaver
%%%     University of Colorado, Boulder
%%%     Department of Ecology and Evolutionary Biology


function [B,C,score,allScores] = basicSegmentation(net,filename,destinationDirectory,image,cpu_gpu)

    % Segmentation
    [C,score,allScores] = semanticseg(image,net,'ExecutionEnvironment',cpu_gpu);

    B = labeloverlay(image,C);
    
    % Output
    destDir = fullfile(destinationDirectory,filename);
    imwrite(B,destDir);
end