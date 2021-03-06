%%%     LeafMachine Batch Segmentation GUI
%%%
%%%     Developed for LeafMachine.org
%%%
%%%     William Weaver
%%%     University of Colorado, Boulder
%%%     Department of Ecology and Evolutionary Biology

function [fLen,timeRun] = LeafMachineBatchSegmentation_GUI(Directory,Directory2,net,netSVM,netSVMruler,dirFGFile,FGfilter,saveOverlayImages,saveLeafCandidateMasks,processLazySnapping,saveIND,saveFreq,...
    feature,gpu_cpu,local_url,url_col,imfillMasks,imfillMasksPartial,imfillMasksClump,quality,filenameSuffix0,destinationDirectory,handles,hObject)
        
    % Triage if user presses CTRL+C
    forceQuit = onCleanup(@forceQuitFunc);

    % Initiate colormap
    %COLOR = colorcube(30);
    try 
        g = gpuDevice(1);
    catch
        fprintf("GPU not available: using cpu instead \n")
        gpu_cpu = 'cpu';
    end
        
    % Read Directory 
    % addpath('SandboxFunctions');
    if FGfilter ~= "noFilter"
        filterLength = string(length(lower(table2cell(dirFGFile(:,1)))));
        filterDisp = strjoin(lower(table2cell(dirFGFile(:,1))),", ");
        formatSpecFilterContent = "FILTER ACTIVE: %s \n     Filter contains the following %s entries: \n     %s \n";
        fprintf(formatSpecFilterContent,FGfilter,filterLength,filterDisp)
    end
    
    formatSpecCSV = "Time --- Import Dataset: %.3f seconds \n";
    timeCSV = tic();
    if local_url == "local"
        imgFiles = dir(char(Directory));
        imgFiles = imgFiles(~ismember({imgFiles.name},{'.','..'}));
        fLen = length(imgFiles);
        fLen = string(fLen);
    else
        opts1 = detectImportOptions(Directory);
        opts1 = setvartype(opts1,{'coreid'},{'double'});
        imageLocation = readtable(Directory,opts1);
        opts2 = detectImportOptions(Directory2);
        opts2 = setvartype(opts2,{'id','catalogNumber'},{'double','char'});
        imageInfo = readtable(Directory2,opts2);
        imgFiles = table2struct(imageLocation);
        fLen = num2str(length(imgFiles));
        %%% HIGH = accessURI	VERY LOW = thumbnailAccessURI	MEDIUM = goodQualityAccessURI
    end
    timeCSV = toc(timeCSV);
    fprintf(formatSpecCSV,timeCSV);
    
    % Create directory or add to existing dir
    destinationDirectory = fullfile(destinationDirectory);
    buildFileStructure(destinationDirectory,saveLeafCandidateMasks,processLazySnapping,local_url);
    
    leafData = [];
    
    skippedDataHeaders = {'filename','reason','location','time'};
    skippedData = cell(length(imgFiles),length(skippedDataHeaders));
    skippedData = cell2table(skippedData);
    skippedData.Properties.VariableNames = skippedDataHeaders;
    
    INDleaf = 1;
    INDskip = 1;
    % For resuming a failed or stopped run
    occMatch = "PASS";
    try
        fOutB = 'LeafMachine_BatchTemp.xlsx';
        prevDataTempFile = readtable(fullfile(fullfile(destinationDirectory,'Data_Temp'),fOutB));
        INDleaf = 1 + length(unique(prevDataTempFile.filename));
        formatSpecContRun = "Skipping to file %d \n";
        fprintf(formatSpecContRun,INDleaf);
        continueRun = true;
    catch
        prevDataTempFile.filename = ["NA","NA"];
        continueRun = false;
    end
    
    % Loop through dir
    timeRun = tic();
    for file = imgFiles'
        timeImage = tic();
        % Define output img filename
        if local_url == "url" % url
            ID = file.coreid;
            IDr = int2str(ID);
            img0 = char(file.(url_col));
            % Find record in other csv
            if filenameSuffix0 ~= ""
                filenameSuffix = strcat('_',filenameSuffix0);
            else
                filenameSuffix = filenameSuffix0;
            end
            [filename,returnFamily,returnGenus,returnSpecies,occMatch] = filenameFromURL(imageInfo,imageLocation,filenameSuffix,ID,url_col);
            familyStrings = strsplit(filename,{'.','_'});
            url = img0;
        else % local
            img0 = char(file.name);
            filename = strsplit(string(img0),".");
            filename = char(filename{1});
            if filenameSuffix0 ~= ""
                filenameSuffix = strcat('_',filenameSuffix0);
            else
                filenameSuffix = filenameSuffix0;
            end
            filename = strcat(filename,filenameSuffix);
            % Try to get family genus species
            familyStrings = strsplit(filename,{'.','_'});
            [family,famPos] = validateFamilyForSVM(familyStrings,handles.allPlantFamilies);
            if family ~= "NaN"
                try
                    returnFamily = familyStrings{famPos};
                    if isempty(returnFamily)
                        returnFamily = "NA";
                    end
                catch
                    returnFamily = "NA";
                end
                try 
                    returnGenus = familyStrings{famPos+1};
                    if isempty(returnGenus)
                        returnGenus = "NA";
                    end
                catch
                    returnGenus = "NA";
                end
                try 
                    returnSpecies = familyStrings{famPos+2};
                    if isempty(returnSpecies)
                        returnSpecies = "NA";
                    end
                catch
                    returnSpecies = "NA";
                end
            else %Family = NaN
                returnFamily = "NA";
                returnGenus = "NA";
                returnSpecies = "NA";
            end
            url = 'NA';
        end
        
        if occMatch ~= "FAIL"
            formatSpecFilename = "Specimen Filename: %s \n";
            fprintf(formatSpecFilename,filename);
            set(handles.progress,'String',strcat("Working on: ",filename),'ForegroundColor',[0 .45 .74]);
            guidata(hObject,handles);

            % Will wait 20 seconds max / 2 tries to read url, then it gets
            % skipped
            if local_url == "url"
                timeURL = tic();
                try
                    img = imread(img0);
                    imgSkip = "RUN";
                catch
                    try
                        img = imread(img0);
                        imgSkip = "RUN";
                    catch
                        formatSpecSkip = "*** Notice *** Specimen %s was skipped, the URL: %s  is broken or the connection timed out \n";
                        fprintf(formatSpecSkip,filename,img0)
                        imgSkip = "SKIP";
                        imgSkipReason = "Broken_URL";
                    end
                end
                timeURL = toc(timeURL);
            else
                timeURL = tic();
                try
                    img = imread(img0);
                    imgSkip = "RUN";
                catch
                    formatSpecSkip = "*** Notice *** Specimen %s was skipped, the file may be corrupt \n";
                    fprintf(formatSpecSkip,filename)
                    imgSkip = "SKIP";
                    imgSkipReason = "File_May_Be_Corrupt";
                end
                timeURL = toc(timeURL);
            end

            % Assess filter for skipping
            if isa(dirFGFile,'string')
            else
                if FGfilter == "noFilter"
                elseif FGfilter == "family"
                    if ~ismember(lower(returnFamily),lower(table2cell(dirFGFile(:,1))))
                        imgSkip = "SKIP";
                        imgSkipReason = "Filter";
                        formatSpecSkip2 = "* Notice * Specimen skipped, family filter applied \n";
                        fprintf(formatSpecSkip2)
                    end
                elseif FGfilter == "genus"
                    if ~ismember(lower(returnGenus),lower(table2cell(dirFGFile(:,1))))
                        imgSkip = "SKIP";
                        imgSkipReason = "Filter";
                        formatSpecSkip2 = "* Notice * Specimen skipped, genus filter applied \n";
                        fprintf(formatSpecSkip2)
                    end
                elseif FGfilter == "species"
                    if ~ismember(lower(returnSpecies),lower(table2cell(dirFGFile(:,1))))
                        imgSkip = "SKIP";
                        imgSkipReason = "Filter";
                        formatSpecSkip2 = "* Notice * Specimen skipped, species filter applied \n";
                        fprintf(formatSpecSkip2)
                    end
                end
            end

            if imgSkip == "RUN"
                if local_url == "url"
                    imwrite(img,strcat(fullfile(destinationDirectory,fullfile('Original',filename)),'.jpg'));
                end
                familyStrings = strsplit(filename,{'.','_'});
                family = validateFamilyForSVM(familyStrings,handles.allPlantFamilies);
                formatSpecFamily = "Specimen Family: %s \n";
                fprintf(formatSpecFamily,family)

                [DimN,DimM,DimZ] = size(img);
                Dim = min(DimN,DimM);
                megapixels = DimN*DimM/1000000;

                formatSpecMP = "Specimen Megapixels: %.1f \n";
                fprintf(formatSpecMP,megapixels)


                % New File
                if ~ismember(filename,prevDataTempFile.filename)
                    formatSpecS = "     Time --- Segmentation: %.3f seconds \n";
                    timeS = tic();
                    
                    passSeg = "TRUE";
                    try
                        if gpu_cpu == "gpu"
                            fprintf("     Segmentation running on GPU \n")
                        else
                            fprintf("     Segmentation running on CPU \n")
                        end
                        filenameSeg = char(strcat(filename,'_Segment'));

                        [imgCNN,C,score,allScores] = basicSegmentation(net,filenameSeg,fullfile(destinationDirectory,'Segmentation'),img,gpu_cpu,quality);%%%Original basic version
                        if gpu_cpu == "gpu"
                            reset(g);
                        end
                    catch 
                        fprintf("     ***VRAM exceeded, running on CPU instead \n")
                        filenameSeg = char(strcat(filename,'_Segment'));
                        if gpu_cpu == "gpu"
                            reset(g);
                        end
                        try
                            [imgCNN,C,score,allScores] = basicSegmentation(net,filenameSeg,fullfile(destinationDirectory,'Segmentation'),img,'cpu',quality);%%%Original basic version
                        catch % Catch if CPU fails and RAM is exceeded
                            formatSpecPassSeg = "*** NOTICE *** Segmentation on CPU failed. Image skipped. Your computer may have run out of RAM \n";
                            fprintf(formatSpecPassSeg);
                            passSeg = "FALSE";
                            imgSkipReason = "CPU_Segmentation_Failed_RAM_Full";
                        end
                    end
                    timeS = toc(timeS); 
                    fprintf(formatSpecS,timeS)

                    if passSeg == "TRUE"
                    
                    if local_url == "url"
                        formatSpecURL = "     Time --- Download image from URL: %.3f \n";
                    else
                        formatSpecURL = "     Time --- Open image: %.3f \n";
                    end
                    fprintf(formatSpecURL,timeURL);

    %                 [conversionFactor] = calculateRulerConversionFactor(img,[DimN,DimM,DimZ],C,5,netSVMruler,filename,destinationDirectory);

                    [compositeGlobular,compositeLine,blobTable,globTable,lineTable,binaryMasks] = findLeavesBinaryStrel(img,[DimN,DimM,DimZ],family,megapixels,C,feature,30,4,...
                                                                                                  imfillMasks,imfillMasksPartial,imfillMasksClump,netSVM,saveLeafCandidateMasks,...
                                                                                                  processLazySnapping,filename,destinationDirectory);

                    formatSpecA = "     Time --- Save binary images: %.3f seconds \n";
                    timeA = tic();
                    saveBinaryMasks(filename,fullfile(destinationDirectory,'Class_Leaf'),binaryMasks{1},'leaf');
                    saveBinaryMasks(filename,fullfile(destinationDirectory,'Class_Stem'),binaryMasks{2},'stem');
                    saveBinaryMasks(filename,fullfile(destinationDirectory,'Class_FruitFlower'),binaryMasks{3},'fruitFlower');
                    saveBinaryMasks(filename,fullfile(destinationDirectory,'Class_Background'),binaryMasks{4},'background');
                    saveBinaryMasks(filename,fullfile(destinationDirectory,'Class_Text'),binaryMasks{5},'text');
                    timeA = toc(timeA); 
                    fprintf(formatSpecA,timeA)

                    % Merge tables for Overlay img
                    timeB = tic();

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
                    if saveOverlayImages == "True"
                        formatSpecB = "     Time --- Export data and overlay: %.3f seconds \n";
                        if ~isempty(overlayTable.measurements)
                            % Temp for sending to Stephen 
                            save('variablesFor_buildImageOverlayDilate.mat',...
                                'megapixels','overlayTable','destinationDirectory','filenameOverlay','quality');
                            load('variablesFor_buildImageOverlayDilate.mat')
                            % img = imread('D:\D_Desktop\Socorros\Q_cf_conzattii_Acevedo_217_CIIDIR.jpg');
                            buildImageOverlayDilate(img,megapixels,length(overlayTable.measurements),overlayTable.measurements,overlayTable.color,fullfile(destinationDirectory,'Overlay'),filenameOverlay,quality);
                        else
                            fprintf("     * Notice * No leaf candidates were located \n")
                        end
                    elseif saveOverlayImages == "False"
                        formatSpecB = "     Time --- Export data: %.3f seconds \n";
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


                    % Unpack data for export and plotting features overlay
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

                    % Add family, genus, species to output file
                    addL = height(singleLeafData);
                    if local_url == "url"
                        addFamily = table(string(repmat(returnFamily,addL,1)));
                        addGenus = table(string(repmat(returnGenus,addL,1)));
                        addSpecies = table(string(repmat(returnSpecies,addL,1)));
                    else
                        addFamily = table(string(repmat(returnFamily,addL,1)));
                        addGenus = table(string(repmat(returnGenus,addL,1)));
                        addSpecies = table(string(repmat(returnSpecies,addL,1)));
                    end
                    addFamily.Properties.VariableNames = {'family'};
                    addGenus.Properties.VariableNames = {'genus'};
                    addSpecies.Properties.VariableNames = {'species'};
                    addTaxa = [addFamily,addGenus,addSpecies];  


                    % Add family, genus, species to output table
                    singleLeafData = [singleLeafData,addTaxa];

                    % Stack Leaf Data
                    if isempty(leafData)
                        leafData = singleLeafData;
                    else
                        %leafData = [leafData; singleLeafData];
                        leafData = cell2table([table2cell(leafData); table2cell(singleLeafData)]);
                        leafData.Properties.VariableNames = singleLeafData.Properties.VariableNames;
                    end 

                    % Save individual image data
                    if saveIND 
                        fOutInd = strjoin(['LeafMachine_IndividualTemp__',filename,'__',datestr(now,'mm-dd-yyyy_HH-MM'),'__',string(INDleaf),'.csv'],'');
                        writetable(singleLeafData,fullfile(fullfile(destinationDirectory,'Data_Temp'),fOutInd));
                    end

                    % Rolling recovery file to minimize data loss if error
                    if (INDleaf == 1)
                        if continueRun
                            leafData = cell2table([table2cell(prevDataTempFile); table2cell(leafData)]);
                            leafData.Properties.VariableNames = prevDataTempFile.Properties.VariableNames;
                            writetable(leafData,fullfile(fullfile(destinationDirectory,'Data_Temp'),fOutB));
                            continueRun = false;
                        elseif (continueRun == false)
                            fOutB = 'LeafMachine_BatchTemp.xlsx';
                            writetable(leafData,fullfile(fullfile(destinationDirectory,'Data_Temp'),fOutB));
                        end
                    else
                        if continueRun
                            leafData = cell2table([table2cell(prevDataTempFile); table2cell(leafData)]);
                            leafData.Properties.VariableNames = prevDataTempFile.Properties.VariableNames;
                            writetable(leafData,fullfile(fullfile(destinationDirectory,'Data_Temp'),fOutB));
                            continueRun = false;
                        end
                    end
                    if (rem(INDskip,saveFreq) == 0)
                        fOutB = 'LeafMachine_BatchTemp.xlsx';
                        writetable(leafData,fullfile(fullfile(destinationDirectory,'Data_Temp'),fOutB));
                        if height(skippedData)>2
                            fOutS = 'LeafMachine_Batch_Skipped_Files_Temp.xlsx';
                            writetable(skippedData,fullfile(fullfile(destinationDirectory,'Skipped_Files'),fOutS));
                        end
                    end
                    timeB = toc(timeB); 
                    fprintf(formatSpecB,timeB);
                    INDleaf = INDleaf + 1;
                    
                    elseif passSeg == "FALSE"
                        try
                            if (rem(INDskip,saveFreq) == 0)
                                if height(skippedData)>2
                                    fOutS = 'LeafMachine_Batch_Skipped_Files_Temp.xlsx';
                                    writetable(skippedData,fullfile(fullfile(destinationDirectory,'Skipped_Files'),fOutS));
                                end
                            end
                        catch
                        end
                        skippedData.filename{INDskip} = filename;
                        skippedData.reason{INDskip} = imgSkipReason;
                        skippedData.location{INDskip} = img0;
                        skippedData.time{INDskip} = datestr(now,'mm-dd-yyyy_HH-MM');
                        INDskip = INDskip + 1;
                        INDleaf = INDleaf + 1;
                    end
                else % For image that has already been run
                    fprintf('*** Notice *** Image already run \n');
                end
            else
                % *** Add to Skipped_Files
                skippedData.filename{INDskip} = filename;
                skippedData.reason{INDskip} = imgSkipReason;
                skippedData.location{INDskip} = img0;
                skippedData.time{INDskip} = datestr(now,'mm-dd-yyyy_HH-MM');
                INDskip = INDskip + 1;
            end            
        else
            imgSkipReason = strjoin(["No_Occurrence_Record_for_Image_CoreID_",IDr],"");
            % *** Add to Skipped_Files
            skippedData.filename{INDskip} = filename;
            skippedData.reason{INDskip} = imgSkipReason;
            skippedData.location{INDskip} = img0;
            skippedData.time{INDskip} = datestr(now,'mm-dd-yyyy_HH-MM');
            INDskip = INDskip + 1;
        end
        
        timeImage = toc(timeImage);
        formatSpecImage = "     Specimen Processing Time --- %.3f seconds \n \n";
        fprintf(formatSpecImage,timeImage)
    end% End of single image processing
    
    try 
        fOut = ['LeafMachine_Batch_',filenameSuffix0,'__',datestr(now,'mm-dd-yyyy_HH-MM'),'__FINAL.xlsx'];
        writetable(leafData,fullfile(fullfile(destinationDirectory,'Data'),fOut));
    catch 
        fprintf("Data output file is empty \n")
    end
    
    try
        fOut2 = ['LeafMachine_Batch_',filenameSuffix0,'__',datestr(now,'mm-dd-yyyy_HH-MM'),'__Skipped_Files.xlsx'];
        writetable(skippedData,fullfile(fullfile(destinationDirectory,'Skipped_Files'),fOut2));
    catch 
        fprintf("Skipped_Files output is empty \n")
    end
    
    timeRun = toc(timeRun);
    formatSpecRun = "*** Batch Complete *** %s images processed in %.3f seconds \n";
    fprintf(formatSpecRun,fLen,timeRun)
    timeRun = string(round(timeRun,3));
    
    function forceQuitFunc()
        fprintf("*** Processing has Stopped *** \n \n \n")
    end
end






