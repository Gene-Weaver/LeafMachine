%%%     Basic Segmentation
%%%     Developed for LeafMachine.org
%%%
%%%     William Weaver
%%%     University of Colorado, Boulder
%%%     Department of Ecology and Evolutionary Biology


%         leaf = 1 --> green
%         stem = 2 --> blue
% fruit/flower = 3 --> magenta
%           bg = 4 --> white
%         text = 5 --> red


function [B,C,score,allScores] = basicSegmentation(net,filename,destinationDirectory,image,cpu_gpu,quality)

    % Segmentation
    [C,score,allScores] = semanticseg(image,net,'ExecutionEnvironment',cpu_gpu);

    map = [0 1 0; 0 0 1; 1 0 1; 1 1 1; 1 0 0];
        
    B = labeloverlay(image,C,'Colormap',map);
    
    if quality == "High"
        filename2 = char(strcat(filename,'.png'));
        imwrite(B,fullfile(destinationDirectory,filename2),'BitDepth',16);
    else
        filename2 = char(strcat(filename,'.jpg'));
        imwrite(B,fullfile(destinationDirectory,filename2));
    end
end