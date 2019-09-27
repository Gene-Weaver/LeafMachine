%%%     Montage Segmentation
%%%     Developed for LeafMachine.org
%%%
%%%     William Weaver
%%%     University of Colorado, Boulder
%%%     Department of Ecology and Evolutionary Biology


function PLOT = montageSegmentation(net,filename,destinationDirectory,image,cpu_gpu,show,nClasses)
    addpath('SandboxFunctions');
    
    % Read image
    image = imread(image);
    
    % Segmentation
    [C,~,~] = semanticseg(image,net,'ExecutionEnvironment',cpu_gpu);
    
    % Label overlay
    B = labeloverlay(image,C);
    
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
    
    % Plot options
    if nClasses == 7
        PLOT = [image,Leaf,Stem,Text_Black;
            B,Fruit_Flower,Background,image];
    elseif nClasses == 6
        PLOT = [image,Leaf,Stem,Text_Black;
            B,Fruit_Flower,Background,image];
    else
        PLOT = [image,Leaf,Stem,Text_Black;
            B,Fruit_Flower,Background,image];
    end
    
    % Output
    destDir = fullfile(destinationDirectory,filename);
    imwrite(PLOT,destDir);
    if show == "show"
        imshow(PLOT)
    end
end




