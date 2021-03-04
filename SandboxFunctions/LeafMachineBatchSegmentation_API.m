%%%     LeafMachine Batch Segmentation GUI
%%%
%%%     Developed for LeafMachine.org
%%%
%%%     William Weaver
%%%     University of Colorado, Boulder
%%%     Department of Ecology and Evolutionary Biology


function [fLen,T] = LeafMachineBatchSegmentation_API(Directory,Directory2,net,netSVM,...
    feature,gpu_cpu,local_url,url_col,quality,filenameSuffix,destinationDirectory)

    % Initiate colormap
    COLOR = colorcube(30);
        
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
    
    leafData = [];
    
    INDleaf = 1;
    
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
        
        img = imread(img0);
        
        [DimN,DimM,DimZ] = size(img);
        Dim = min(DimN,DimM);
                        
        %%%%% Images larger than 2016 pixels %%%%%
        sprintf("Large Image Loop")
        filenameSeg = char(strcat(filename,'_Segment'));

        [imgCNN,C,score,allScores] = basicSegmentation(net,filenameSeg,destinationDirectory,img,gpu_cpu,quality);%%%Original basic version

        [compositeGlobular,compositeLine,blobTable,globTable,lineTable,binaryMasks] = findLeavesBinaryStrel(img,[DimN,DimM,DimZ],C,feature,30,4,COLOR,netSVM,filename,destinationDirectory);%USE THIS FOR DEPLOYMENT

        saveBinaryMasks(filename,destinationDirectory,binaryMasks{1},'leaf');
        saveBinaryMasks(filename,destinationDirectory,binaryMasks{2},'stem');
        saveBinaryMasks(filename,destinationDirectory,binaryMasks{3},'fruitFlower');
        saveBinaryMasks(filename,destinationDirectory,binaryMasks{4},'background');
        saveBinaryMasks(filename,destinationDirectory,binaryMasks{5},'text');

        % Unpack data for export and plotting festures overlay
        %%% Initial Blob
        if ~isempty(blobTable) % If leaves are found
            filenameOverlayBlob = char(strcat(filename,'_OverlayBlob'));
            buildImageOverlayDirect(img,height(blobTable),blobTable.measurements,blobTable.color,destinationDirectory,filenameOverlayBlob,quality);

            % Construct data for export   
            dataHeaders = {'filename','predictionType','id','color','bbox','area','perimeter'};
            blob_OUT = cell(height(blobTable),7);
            blob_OUT = cell2table(blob_OUT);
            blob_OUT.Properties.VariableNames = dataHeaders;

            blob_OUT.filename(1:height(blobTable)) = {string(filename)};
            blob_OUT.predictionType(1:height(blobTable)) = {"blob_initial"};
            blob_OUT.id(1:height(blobTable)) = blobTable.id;
            blob_OUT.color(1:height(blobTable)) = blobTable.colorReport;
            %blob_OUT.color(1:height(blobTable)) = cellfun(@string,blobTable.color);

            blob_OUT.bbox = blobTable.bboxReport;
            blob_OUT.area = blobTable.area;
            blob_OUT.perimeter = blobTable.perimeter;
        else %if no leaves were found
            dataHeaders = {'filename','predictionType','id','color','bbox','area','perimeter'};
            blob_OUT = cell(1,7);
            blob_OUT = cell2table(blob_OUT);
            blob_OUT.Properties.VariableNames = dataHeaders;

            blob_OUT.filename = string(filename);
            blob_OUT.predictionType = "blob_initial";
            blob_OUT.id = "NA";
            blob_OUT.color = "[NA NA NA]";
            blob_OUT.bbox = "[NA,NA,NA,NA]";
            blob_OUT.area = "NA";
            blob_OUT.perimeter = "NA";
        end


        %%% Glob
        if ~isempty(globTable) % If leaves are found
            filenameOverlayGlob = char(strcat(filename,'_OverlayGlob'));
            buildImageOverlayDirect(img,height(globTable),globTable.measurements,globTable.color,destinationDirectory,filenameOverlayGlob,quality);

            % Construct data for export   
            dataHeaders = {'filename','predictionType','id','color','bbox','area','perimeter'};
            glob_OUT = cell(height(globTable),7);
            glob_OUT = cell2table(glob_OUT);
            glob_OUT.Properties.VariableNames = dataHeaders;

            glob_OUT.filename(1:height(globTable)) = {string(filename)};
            glob_OUT.predictionType(1:height(globTable)) = {"glob_initial"};
            glob_OUT.id = globTable.id;
            glob_OUT.color = globTable.colorReport;
            glob_OUT.bbox = globTable.bboxReport;
            glob_OUT.area = globTable.area;
            glob_OUT.perimeter = globTable.perimeter;

%                         glob_OUT.area = globTable.measurements{:}.cleanLeaf_Area;
%                         glob_OUT.perimeter = globTable.measurements{:}.cleanLeaf_Perimeter;
        else %if no leaves were found
            dataHeaders = {'filename','predictionType','id','color','bbox','area','perimeter'};
            glob_OUT = cell(1,7);
            glob_OUT = cell2table(glob_OUT);
            glob_OUT.Properties.VariableNames = dataHeaders;

            glob_OUT.filename = string(filename);
            glob_OUT.predictionType = "glob";
            glob_OUT.id = "NA";
            glob_OUT.color = "[NA NA NA]";
            glob_OUT.bbox = "[NA,NA,NA,NA]";
            glob_OUT.area = "NA";
            glob_OUT.perimeter = "NA";
        end


        %%% Line
        if ~isempty(lineTable) % If leaves are found
            filenameOverlayLine = char(strcat(filename,'_OverlayLine'));
            buildImageOverlayDirect(img,height(lineTable),lineTable.measurements,lineTable.color,destinationDirectory,filenameOverlayLine,quality);

            % Construct data for export   
            dataHeaders = {'filename','predictionType','id','color','bbox','area','perimeter'};
            line_OUT = cell(height(lineTable),7);
            line_OUT = cell2table(line_OUT);
            line_OUT.Properties.VariableNames = dataHeaders;

            line_OUT.filename(1:height(lineTable)) = {string(filename)};
            line_OUT.predictionType(1:height(lineTable)) = {"line"};
            line_OUT.id = lineTable.id;
            line_OUT.color = lineTable.colorReport;
            line_OUT.bbox = lineTable.bboxReport;
            line_OUT.area = lineTable.area;
            line_OUT.perimeter = lineTable.perimeter;
%                         line_OUT.area = lineTable.measurements{:}.cleanLeaf_Area;
%                         line_OUT.perimeter = lineTable.measurements{:}.cleanLeaf_Perimeter;
        else %if no leaves were found
            dataHeaders = {'filename','predictionType','id','color','bbox','area','perimeter'};
            line_OUT = cell(1,7);
            line_OUT = cell2table(line_OUT);
            line_OUT.Properties.VariableNames = dataHeaders;

            line_OUT.filename = {string(filename)};
            line_OUT.predictionType = "line";
            line_OUT.id = "NA";
            line_OUT.color = "[NA NA NA]";
            line_OUT.bbox = "[NA,NA,NA,NA]";
            line_OUT.area = "NA";
            line_OUT.perimeter = "NA";
        end


        singleLeafData = [blob_OUT; glob_OUT; line_OUT];
        if isempty(leafData)
            leafData = singleLeafData;
        else
            leafData = [leafData; singleLeafData];
        end 
        fOut = strjoin(['LeafMachine_Batch__',string(INDleaf),'.csv'],'');
        writetable(leafData,fullfile(destinationDirectory,fOut));
        INDleaf = INDleaf + 1;
    end 
    fOut = 'LeafMachine_Batch__FINAL.csv';
    writetable(leafData,fullfile(destinationDirectory,fOut));
    T = toc();
    T = string(round(T,2));
end




