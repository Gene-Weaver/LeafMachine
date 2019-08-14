%%%     LeafMachine Batch Segmentation GUI
%%%
%%%     Developed for LeafMachine.org
%%%
%%%     William Weaver
%%%     University of Colorado, Boulder
%%%     Department of Ecology and Evolutionary Biology

function [fLen,T] = LeafMachineBatchSegmentation_GUI(Directory,Directory2,net,netSVM,netSVMruler,saveLeafCandidateMasks,processLazySnapping,saveIND,saveFreq,...
    feature,gpu_cpu,local_url,url_col,quality,filenameSuffix,destinationDirectory,handles,hObject)
    % Initiate colormap
    COLOR = colorcube(30);
    try 
        g = gpuDevice(1);
    catch
        sprintf("GPU Not Available: using cpu instead")
        gpu_cpu = 'cpu';
    end
        
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
        mkdir(fullfile(destinationDirectory,'Overlay'));
        mkdir(fullfile(destinationDirectory,'Segmentation'));
        mkdir(fullfile(destinationDirectory,'Data'));
        mkdir(fullfile(destinationDirectory,'Data_Temp'));
        
        mkdir(fullfile(destinationDirectory,'Leaf'));
        mkdir(fullfile(destinationDirectory,'Leaf_Partial'));
        mkdir(fullfile(destinationDirectory,'Leaf_Clump'));
        
        mkdir(fullfile(destinationDirectory,'Class_Text'));
        mkdir(fullfile(destinationDirectory,'Class_Leaf'));
        mkdir(fullfile(destinationDirectory,'Class_Background'));
        mkdir(fullfile(destinationDirectory,'Class_Stem'));
        mkdir(fullfile(destinationDirectory,'Class_FruitFlower'));
        
        if saveLeafCandidateMasks
            mkdir(fullfile(destinationDirectory,'Leaf_Fail'));
        end
        if processLazySnapping
            mkdir(fullfile(destinationDirectory,'Leaf_LazySnapping'))
        end
    else
        mkdir(destinationDirectory);
        mkdir(fullfile(destinationDirectory,'Overlay'));
        mkdir(fullfile(destinationDirectory,'Segmentation'));
        mkdir(fullfile(destinationDirectory,'Data'));
        mkdir(fullfile(destinationDirectory,'Data_Temp'));
        
        mkdir(fullfile(destinationDirectory,'Leaf'));
        mkdir(fullfile(destinationDirectory,'Leaf_Partial'));
        mkdir(fullfile(destinationDirectory,'Leaf_Clump'));
        
        mkdir(fullfile(destinationDirectory,'Class_Text'));
        mkdir(fullfile(destinationDirectory,'Class_Leaf'));
        mkdir(fullfile(destinationDirectory,'Class_Background'));
        mkdir(fullfile(destinationDirectory,'Class_Stem'));
        mkdir(fullfile(destinationDirectory,'Class_FruitFlower'));
        
        if saveLeafCandidateMasks
            mkdir(fullfile(destinationDirectory,'Leaf_Fail'));
        end
        if processLazySnapping
            mkdir(fullfile(destinationDirectory,'Leaf_LazySnapping'))
        end
    end
    
    leafData = [];
    
    INDleaf = 1;
    % For resuming a failed or stopped run
    try
        fOutB = 'LeafMachine_BatchTemp.xlsx';
        prevDataTempFile = readtable(fullfile(fullfile(destinationDirectory,'Data_Temp'),fOutB));
        INDleaf = 1 + length(unique(prevDataTempFile.filename))
        continueRun = true;
    catch
        continueRun = false;
    end
    
    % Loop through dir
    timeA = tic();
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
        familyStrings = strsplit(filename,{'.','_'});
        family = validateFamilyForSVM(familyStrings,handles.allPlantFamilies)
        
        [DimN,DimM,DimZ] = size(img);
        Dim = min(DimN,DimM);
        megapixels = DimN*DimM/1000000;
       
           
        % New File
        if ~ismember(filename,prevDataTempFile.filename)% || (continueRun == false)
            try
                sprintf("GPU/CPU Image Loop")
                filenameSeg = char(strcat(filename,'_Segment'));

                [imgCNN,C,score,allScores] = basicSegmentation(net,filenameSeg,fullfile(destinationDirectory,'Segmentation'),img,gpu_cpu,quality);%%%Original basic version
                if gpu_cpu == "gpu"
                    reset(g);
                end

            catch 
                sprintf("Forced CPU Image Loop")
                filenameSeg = char(strcat(filename,'_Segment'));
                if gpu_cpu == "gpu"
                    reset(g);
                end

                [imgCNN,C,score,allScores] = basicSegmentation(net,filenameSeg,fullfile(destinationDirectory,'Segmentation'),img,'cpu',quality);%%%Original basic version
            end

    %         [conversionFactor] = calculateRulerConversionFactor(img,[DimN,DimM,DimZ],C,5,netSVMruler,filename,destinationDirectory);

            [compositeGlobular,compositeLine,blobTable,globTable,lineTable,binaryMasks] = findLeavesBinaryStrel(img,[DimN,DimM,DimZ],family,megapixels,C,feature,30,4,COLOR,netSVM,saveLeafCandidateMasks,processLazySnapping,filename,destinationDirectory);

            saveBinaryMasks(filename,fullfile(destinationDirectory,'Class_Leaf'),binaryMasks{1},'leaf');
            saveBinaryMasks(filename,fullfile(destinationDirectory,'Class_Stem'),binaryMasks{2},'stem');
            saveBinaryMasks(filename,fullfile(destinationDirectory,'Class_FruitFlower'),binaryMasks{3},'fruitFlower');
            saveBinaryMasks(filename,fullfile(destinationDirectory,'Class_Background'),binaryMasks{4},'background');
            saveBinaryMasks(filename,fullfile(destinationDirectory,'Class_Text'),binaryMasks{5},'text');

            % Merge tables for Overlay img
            filenameOverlay = char(strcat(filename,'_Overlay'));
            if ~isempty(blobTable)
                overlayTable.measurements = blobTable.measurements;
                overlayTable.color = blobTable.color;
            else
                overlayTable.measurements = [];
                overlayTable.color = [];
            end
            if ~isempty(globTable)
                overlayTable.measurements = [overlayTable.measurements; globTable.measurements];
                overlayTable.color = [overlayTable.color; globTable.color];
            end
            if ~isempty(lineTable)
                overlayTable.measurements = [overlayTable.measurements; lineTable.measurements];
                overlayTable.color = [overlayTable.color; lineTable.color];
            end

            % Save Overlay
            if ~isempty(overlayTable.measurements)
                buildImageOverlayDilate(img,megapixels,length(overlayTable.measurements),overlayTable.measurements,overlayTable.color,fullfile(destinationDirectory,'Overlay'),filenameOverlay,quality);
            else
                sprintf("No Overlay, Table is empty")
            end

            % Format megapixels for export
            % Blob
            try
                mp1 = cell(1, height(blobTable));
                mp1(:) = {megapixels};
            catch
                mp1 = "NA";
            end
            % Glob
            try
                mp2 = cell(1, height(globTable));
                mp2(:) = {megapixels};
            catch
                mp2 = "NA";
            end
            % Line
            try
                mp3 = cell(1, height(lineTable));
                mp3(:) = {megapixels};
            catch
                mp3 = "NA";
            end


            % Unpack data for export and plotting festures overlay
            %%% Initial SVM
            dataHeaders = {'filename','predictionType','SVMprediction','time','megapixels','id','color','bbox','area','perimeter'};

            if ~isempty(blobTable) % If leaves are found
                blob_OUT = cell(height(blobTable),length(dataHeaders));
                blob_OUT = cell2table(blob_OUT);
                blob_OUT.Properties.VariableNames = dataHeaders;

                blob_OUT.filename(1:height(blobTable)) = {string(filename)};
                blob_OUT.predictionType(1:height(blobTable)) = {"SVM"};
                blob_OUT.id(1:height(blobTable)) = blobTable.id;
                blob_OUT.SVMprediction(1:height(blobTable)) = blobTable.SVMprediction;
                blob_OUT.time(1:height(blobTable)) = blobTable.time;
                blob_OUT.megapixels(1:height(blobTable)) = mp1;
                blob_OUT.color(1:height(blobTable)) = blobTable.colorReport;
                blob_OUT.bbox = blobTable.bboxReport;
                blob_OUT.area = blobTable.area;
                blob_OUT.perimeter = blobTable.perimeter;
            else %if no leaves were found
                blob_OUT = cell(1,length(dataHeaders));
                blob_OUT = cell2table(blob_OUT);
                blob_OUT.Properties.VariableNames = dataHeaders;

                blob_OUT.filename = string(filename);
                blob_OUT.predictionType = "SVM";
                blob_OUT.id = "NA";
                blob_OUT.SVMprediction = "NA";
                blob_OUT.time = "NA";
                blob_OUT.megapixels = mp1;
                blob_OUT.color = "[NA NA NA]";
                blob_OUT.bbox = "[NA,NA,NA,NA]";
                blob_OUT.area = "NA";
                blob_OUT.perimeter = "NA";
            end


            %%% Glob
            if ~isempty(globTable) % If leaves are found
                glob_OUT = cell(height(globTable),length(dataHeaders));
                glob_OUT = cell2table(glob_OUT);
                glob_OUT.Properties.VariableNames = dataHeaders;

                glob_OUT.filename(1:height(globTable)) = {string(filename)};
                glob_OUT.predictionType(1:height(globTable)) = {"LSglob"};
                glob_OUT.id = globTable.id;
                glob_OUT.SVMprediction = globTable.SVMprediction;
                glob_OUT.time(1:height(globTable)) = globTable.time;
                glob_OUT.megapixels(1:height(globTable)) = mp2;
                glob_OUT.color = globTable.colorReport;
                glob_OUT.bbox = globTable.bboxReport;
                glob_OUT.area = globTable.area;
                glob_OUT.perimeter = globTable.perimeter;
            else %if no leaves were found
                glob_OUT = cell(1,length(dataHeaders));
                glob_OUT = cell2table(glob_OUT);
                glob_OUT.Properties.VariableNames = dataHeaders;

                glob_OUT.filename = string(filename);
                glob_OUT.predictionType = "glob";
                glob_OUT.id = "NA";
                glob_OUT.SVMprediction = "NA";
                glob_OUT.time = "NA";
                glob_OUT.megapixels = mp2;
                glob_OUT.color = "[NA NA NA]";
                glob_OUT.bbox = "[NA,NA,NA,NA]";
                glob_OUT.area = "NA";
                glob_OUT.perimeter = "NA";
            end


            %%% Line
            if ~isempty(lineTable) % If leaves are found
                line_OUT = cell(height(lineTable),length(dataHeaders));
                line_OUT = cell2table(line_OUT);
                line_OUT.Properties.VariableNames = dataHeaders;

                line_OUT.filename(1:height(lineTable)) = {string(filename)};
                line_OUT.predictionType(1:height(lineTable)) = {"LSline"};
                line_OUT.id = lineTable.id;
                line_OUT.SVMprediction = lineTable.SVMprediction;
                line_OUT.time(1:height(lineTable)) = lineTable.time;
                line_OUT.megapixels(1:height(lineTable)) = mp3;
                line_OUT.color = lineTable.colorReport;
                line_OUT.bbox = lineTable.bboxReport;
                line_OUT.area = lineTable.area;
                line_OUT.perimeter = lineTable.perimeter;
            else %if no leaves were found
                line_OUT = cell(1,length(dataHeaders));
                line_OUT = cell2table(line_OUT);
                line_OUT.Properties.VariableNames = dataHeaders;

                line_OUT.filename = {string(filename)};
                line_OUT.predictionType = "line";
                line_OUT.id = "NA";
                line_OUT.SVMprediction = "NA";
                line_OUT.time = "NA";
                line_OUT.megapixels = mp3;
                line_OUT.color = "[NA NA NA]";
                line_OUT.bbox = "[NA,NA,NA,NA]";
                line_OUT.area = "NA";
                line_OUT.perimeter = "NA";
            end


            set(handles.progress2,'String',strcat("Finished: ",filename),'ForegroundColor',[0 .45 .74]);  


            % Stack Leaf Data from each algorithm
            singleLeafData = blob_OUT;
            if ~isempty(globTable)
                singleLeafData = [blob_OUT; glob_OUT];
            end
            if ~isempty(lineTable)
                singleLeafData = [blob_OUT; glob_OUT; line_OUT];
            end

            % Stack Leaf Data
            if isempty(leafData)
                leafData = singleLeafData;
            else
                leafData = [leafData; singleLeafData];
            end 

            % Save individual image data
            if saveIND 
                fOutInd = strjoin(['LeafMachine_IndividualTemp__',filename,'__',datestr(now,'mm-dd-yyyy_HH-MM'),'__',string(INDleaf),'.csv'],'');
                writetable(singleLeafData,fullfile(fullfile(destinationDirectory,'Data_Temp'),fOutInd));
            end

            % Rolling recovery file to minimize data loss if error
            if (INDleaf == 1)
                if continueRun
                    leafData = [prevDataTempFile; leafData];
                    writetable(leafData,fullfile(fullfile(destinationDirectory,'Data_Temp'),fOutB));
                    continueRun = false;
                elseif (continueRun == false)
                    fOutB = 'LeafMachine_BatchTemp.xlsx';
                    writetable(leafData,fullfile(fullfile(destinationDirectory,'Data_Temp'),fOutB));
                end
            else
                if continueRun
                    leafData = [prevDataTempFile; leafData];
                    writetable(leafData,fullfile(fullfile(destinationDirectory,'Data_Temp'),fOutB));
                    continueRun = false;
                end
            end
            if (rem(INDleaf,saveFreq) == 0)
                fOutB = 'LeafMachine_BatchTemp.xlsx';
    %             tempTable = readtable(fullfile(fullfile(destinationDirectory,'Data_Temp'),fOutB));
    %             tempTable = [tempTable;leafData];
                writetable(leafData,fullfile(fullfile(destinationDirectory,'Data_Temp'),fOutB));
            end
            INDleaf = INDleaf + 1;
        else % For image that has already been run
            sprintf(strjoin({filename,'--Image already run'},''))
        end
    end% End of single image processing
    
    fOut = ['LeafMachine_Batch__',datestr(now,'mm-dd-yyyy_HH-MM'),'__FINAL.xlsx'];
    writetable(leafData,fullfile(fullfile(destinationDirectory,'Data'),fOut));
    T = toc(timeA);
    T = string(round(T,2));
end




