%%%     LeafMachine Batch Segmentation GUI
%%%
%%%     Developed for LeafMachine.org
%%%
%%%     William Weaver
%%%     University of Colorado, Boulder
%%%     Department of Ecology and Evolutionary Biology


function [fLen,T] = LeafMachineBatchSegmentation_GUI(Directory,Directory2,Segment_Montage_Both,net,nClasses,feature,gpu_cpu,local_url,url_col,show,filenameSuffix,destinationDirectory,handles,hObject)
    % Initiate colormap
    COLOR = colorcube(30);
    g = gpuDevice(1);
    % Read Directory 
    % addpath('SandboxFunctions');
    if local_url == "local"
        imgFiles = dir(char(Directory));
        imgFiles = imgFiles(~ismember({imgFiles.name},{'.','..'}));
        fLen = length(imgFiles);
        fLen = string(fLen);
    else
        imageLocation = readtable(Directory);
        imageInfo = readtable(Directory2);
        imgFiles = table2struct(imageLocation);
        fLen = num2str(length(imgFiles));
        %imgFilesPOC = table(imageLocation.identifier);
        %%% HIGH = accessURI	VERY LOW = thumbnailAccessURI	MEDIUM = goodQualityAccessURI
    end
    % Create directory or add to existing dir
    destinationDirectory = fullfile(destinationDirectory);
    if exist(destinationDirectory, 'dir')
    else
        mkdir(destinationDirectory);
    end
    
    % Loop through dir
    tic()
    for file = imgFiles'
        % Define output img filename
        if local_url == "url" % url
            ID = file.coreid;
            IDr = int2str(ID);
            img0 = char(file.(url_col));
            % Find record in other csv
            filename = filenameFromURL(imageInfo,filenameSuffix,ID,IDr)
            url = img0;
        else % local
            img0 = char(file.name);
            filename = strsplit(string(img0),".");
            filename = char(filename{1});
            filename = strcat(filename,filenameSuffix)
            url = 'NA';
        end
        set(handles.progress,'String',strcat("Working on: ",filename),'ForegroundColor',[0 .45 .74]);
        guidata(hObject,handles);
        
        img = imread(img0);
        
        [DimN,DimM,DimZ] = size(img);
        Dim = min(DimN,DimM);
        % Start item record
        %==================
        record.filename = filename;
        record.url = url; 
        record.dim = [DimN,DimM,DimZ];
        %===========================
%         item.Filename = 'filename';
%         item.Species = 'Ginko_biloba';
% 
%         T = {item.Filename,item.Species}
%         T2 = cell2table(T)
%         T2.Properties.VariableNames = {'Filename','Species'}
%         writetable(T2,'test.xlsx')

        switch Segment_Montage_Both
            case 'Segment'
                if Dim < 2016
                    %"Segment LR"
                    %try
                        %%% Regular Route
                        filenameSeg = char(strcat(filename,'_Segment.png'));

                        [imgOut,C,score,allScores] = basicSegmentation(net,filenameSeg,destinationDirectory,img,gpu_cpu);%%%Original basic version
                        %figure,imshow(imgOut)

                        [compositeGlobular,compositeLine,globData,lineData] = findLeavesBinaryStrel(img,[DimN,DimM,DimZ],C,feature,30,4,COLOR);%USE THIS FOR DEPLOYMENT
                        %[compositeGlobular,compositeLine,globData,lineData] = findLeavesBinaryStrel(img,C1,1,30,4,COLOR);

                        % Unpack data for export and plotting festures overlay
                        filenameOverlayLine = char(strcat(filename,'_OverlayLine.png'));
                        imgOutOverlayLine = buildImageOverlay(img,lineData{1},lineData{10},lineData{3},destinationDirectory,filenameOverlayLine);

                        filenameOverlayGlob = char(strcat(filename,'_OverlayGlob.png'));
                        imgOutOverlayGlob = buildImageOverlay(img,globData{1},globData{10},globData{3},destinationDirectory,filenameOverlayGlob);

                        showImgAxes1(show,handles,hObject,imgOut)
                        if gpu_cpu == "gpu"
                            reset(g);
                        end
%                     catch 
%                         %%% If GPU fails out Route
%                         reset(g);
%                         filenameSeg = char(strcat(filename,'_Segment.png'));
% 
%                         [imgOut,C,score,allScores] = basicSegmentation(net,filenameSeg,destinationDirectory,img,'cpu');%%%Original basic version
%                         %figure,imshow(imgOut)
% 
%                         [compositeGlobular,compositeLine,globData,lineData] = findLeavesBinaryStrel(img,[DimN,DimM,DimZ],C,feature,30,4,COLOR);%USE THIS FOR DEPLOYMENT
%                         %[compositeGlobular,compositeLine,globData,lineData] = findLeavesBinaryStrel(img,C1,1,30,4,COLOR);
% 
%                         % Unpack data for export and plotting festures overlay
%                         filenameOverlayLine = char(strcat(filename,'_OverlayLine.png'));
%                         imgOutOverlayLine = buildImageOverlay(img,lineData{1},lineData{10},lineData{3},destinationDirectory,filenameOverlayLine);
% 
%                         filenameOverlayGlob = char(strcat(filename,'_OverlayGlob.png'));
%                         imgOutOverlayGlob = buildImageOverlay(img,globData{1},globData{10},globData{3},destinationDirectory,filenameOverlayGlob);
% 
%                         showImgAxes1(show,handles,hObject,imgOut)
%                         reset(g);
%                     end
                    
                else
%                     "Segment HR"
%                     filename2 = char(strcat(filename,'_SegmentHR.jpg'));
%                     imgOut = highResSegmentation(net,filename2,destinationDirectory,img,gpu_cpu);
%                     showImgAxes1(show,handles,hObject,imgOut)
                end
                set(handles.progress2,'String',strcat("Finished: ",filename),'ForegroundColor',[0 .45 .74]);
            case 'Both'
                if Dim < 2016
%                     % Segment 
%                     "Segment LR"
%                     filename4 = char(strcat(filename,'_Segment.jpg'));
%                     [imgOut,C,score,allScores] = basicSegmentation(net,filename4,destinationDirectory,img,gpu_cpu);
%                     showImgAxes1(show,handles,hObject,imgOut)
%                     % Montage
%                     "Montage LR"
%                     filename5 = char(strcat(filename,'_Montage.jpg'));
%                     imgOut = montageSegmentation(net,filename5,destinationDirectory,img,gpu_cpu,show,nClasses);
%                     showImgAxes1(show,handles,hObject,imgOut)
%                     set(handles.progress2,'String',strcat("Finished: ",filename),'ForegroundColor',[0 .45 .74]);
                else
                    % Segment HR
%                     "Segment HR"
%                     filename6 = char(strcat(filename,'_SegmentHR.jpg'));
%                     imgOut = highResSegmentation(net,filename6,destinationDirectory,img,gpu_cpu);
%                     showImgAxes1(show,handles,hObject,imgOut)
                    % Montage HR
%                     "Montage HR"
%                     filename7 = strsplit(string(imgIn),".");
%                     filename7 = char(filename7{1});
%                     filenameSuffix9 = strcat('MontageHR',filenameSuffix);
%                     filename = char(strcat(filename7,'_',char(filenameSuffix9),'.jpg'));
%                     highResMontageSegmentation(net,filename,destinationDirectory,imgIn,gpu_cpu,show)
                end   
%                 set(handles.progress2,'String',strcat("Finished: ",filename),'ForegroundColor',[0 .45 .74]);
        end
        
    end
    T = toc();
    T = string(round(T,2));
end




