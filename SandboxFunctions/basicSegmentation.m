%%%     Basic Segmentation
%%%     Developed for LeafMachine.org
%%%
%%%     William Weaver
%%%     University of Colorado, Boulder
%%%     Department of Ecology and Evolutionary Biology


function [B,C,score,allScores] = basicSegmentation(net,filename,destinationDirectory,image,cpu_gpu,quality)

    % Segmentation
    [C,score,allScores] = semanticseg(image,net,'ExecutionEnvironment',cpu_gpu);

    B = labeloverlay(image,C);
    
    if quality == "High"
        filename2 = char(strcat(filename,'.png'));
        imwrite(B,fullfile(destinationDirectory,filename2),'BitDepth',16);
    else
        filename2 = char(strcat(filename,'.jpg'));
        imwrite(B,fullfile(destinationDirectory,filename2));
    end
end