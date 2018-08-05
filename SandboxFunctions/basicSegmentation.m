%%%     Basic Segmentation
%%%     Developed for LeafMachine.org
%%%
%%%     William Weaver
%%%     University of Colorado, Boulder
%%%     Department of Ecology and Evolutionary Biology


function B = basicSegmentation(net,filename,destinationDirectory,image,cpu_gpu)
    addpath('SandboxFunctions');
    
    % Read image
    image = imread(image);
    
    % Segmentation
    [C,~,~] = semanticseg(image,net,'ExecutionEnvironment',cpu_gpu);

    B = labeloverlay(image,C);
    
    % Output
    destDir = fullfile(destinationDirectory,filename);
    imwrite(B,destDir);
end