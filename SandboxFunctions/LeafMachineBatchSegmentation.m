%%%     LeafMachine Batch Segmentation
%%%             Version 2.0.0
%%%             Uses CNN: vgg16_LM180725_v4_longer2.mat
%%%             Training/validation set: gTruth_LM180707_Train_HRLR_Done.mat
%%%
%%%     Developed for LeafMachine.org
%%%
%%%     William Weaver
%%%     University of Colorado, Boulder
%%%     Department of Ecology and Evolutionary Biology


function [fLen,T] = LeafMachineBatchSegmentation(Directory,Segment_Montage_Both,net,nClasses,gpu_cpu,show,filenameSuffix,destinationDirectory,handles)
    % Read Directory 
    %addpath('SandboxFunctions');
    imgFilesPOC = dir(char(Directory));
    imgFilesPOC = imgFilesPOC(~ismember({imgFilesPOC.name},{'.','..'}));
    fLen = length(imgFilesPOC);
    fLen = string(fLen);
    % Create directory or add to existing dir
    destinationDirectory = fullfile(destinationDirectory);
    if exist(destinationDirectory, 'dir')
    else
        mkdir(destinationDirectory)
    end
    
    % Loop through dir
    tic()
    for file = imgFilesPOC'
        img = char(file.name)
        switch Segment_Montage_Both
            case 'Segment'
                try
                    "Segment LR"
                    filename1 = strsplit(string(img),".");
                    filename1 = char(filename1{1});
                    filenameSuffix2 = strcat('Segment',filenameSuffix);
                    filename = char(strcat(filename1,'_',char(filenameSuffix2),'.jpg'));
                    imgOut = basicSegmentation(net,filename,destinationDirectory,img,gpu_cpu);
                catch
                    "Segment HR"
                    filename2 = strsplit(string(img),".");
                    filename2 = char(filename2{1});
                    filenameSuffix3 = strcat('SegmentHR',filenameSuffix);
                    filename = char(strcat(filename2,'_',char(filenameSuffix3),'.jpg'));
                    imgOut = highResSegmentation(net,filename,destinationDirectory,img,gpu_cpu);
                end
            case 'Montage'
                try
                    "Montage LR"
                    filename3 = strsplit(string(img),".");
                    filename3 = char(filename3{1});
                    filenameSuffix4 = strcat('Montage',filenameSuffix);
                    filename = char(strcat(filename3,'_',char(filenameSuffix4),'.jpg'));
                    imgOut = montageSegmentation(net,filename,destinationDirectory,img,gpu_cpu,nClasses);
                catch
%                     "Montage HR"
%                     filename8 = strsplit(string(imgIn),".");
%                     filename8 = char(filename8{1});
%                     filenameSuffix5 = strcat('MontageHR',filenameSuffix);
%                     filename = char(strcat(filename8,'_',char(filenameSuffix5),'.jpg'));
%                     highResMontageSegmentation(net,filename,destinationDirectory,imgIn,gpu_cpu,show)
                end
            otherwise % Both
                try
                    % Segment 
                    "Segment LR"
                    filename4 = strsplit(string(img),".");
                    filename4 = char(filename4{1});
                    filenameSuffix6 = strcat('Segment',filenameSuffix);
                    filename = char(strcat(filename4,'_',char(filenameSuffix6),'.jpg'));
                    imgOut = basicSegmentation(net,filename,destinationDirectory,img,gpu_cpu);
                    % Montage
                    "Montage LR"
                    filename5 = strsplit(string(img),".");
                    filename5 = char(filename5{1});
                    filenameSuffix7 = strcat('Montage',filenameSuffix);
                    filename = char(strcat(filename5,'_',char(filenameSuffix7),'.jpg'));
                    imgOut = montageSegmentation(net,filename,destinationDirectory,img,gpu_cpu,nClasses);
                catch
                    % Segment HR
                    "Segment HR"
                    filename6 = strsplit(string(img),".");
                    filename6 = char(filename6{1});
                    filenameSuffix8 = strcat('SegmentHR',filenameSuffix);
                    filename = char(strcat(filename6,'_',char(filenameSuffix8),'.jpg'));
                    imgOut = highResSegmentation(net,filename,destinationDirectory,img,gpu_cpu);
                    % Montage HR
%                     "Montage HR"
%                     filename7 = strsplit(string(imgIn),".");
%                     filename7 = char(filename7{1});
%                     filenameSuffix9 = strcat('MontageHR',filenameSuffix);
%                     filename = char(strcat(filename7,'_',char(filenameSuffix9),'.jpg'));
%                     highResMontageSegmentation(net,filename,destinationDirectory,imgIn,gpu_cpu,show)
                end   
        end
        if show == "show"
            axes(handles.axes1)
            imshow(imgOut)
        end
    end
    T = toc();
    T = string(round(T,2));
end




