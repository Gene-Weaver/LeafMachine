function GUIdownloadDwCimages(imagesFILE,occFILE,outDir,res)
    saveName = ['LeafMachine_Batch_Download_',datestr(now,'mm-dd-yyyy_HH-MM')];
    
    if ~exist(fullfile(outDir,'Download_Report'), 'dir');mkdir(fullfile(outDir,'Download_Report'));end
    if res == "HIGH"
        if ~exist(fullfile(outDir,'Full_Resolution'), 'dir');mkdir(fullfile(outDir,'Full_Resolution'));end
    elseif res == "LOW"
        if ~exist(fullfile(outDir,'Low_Resolution'), 'dir');mkdir(fullfile(outDir,'Low_Resolution'));end
    elseif res == "BOTH"
        if ~exist(fullfile(outDir,'Full_Resolution'), 'dir');mkdir(fullfile(outDir,'Full_Resolution'));end
        if ~exist(fullfile(outDir,'Low_Resolution'), 'dir');mkdir(fullfile(outDir,'Low_Resolution'));end
    end

    % Open images and occurrences csv file within dir
    opts1 = detectImportOptions(imagesFILE);
    opts1 = setvartype(opts1,{'coreid'},{'double'});
    images = readtable(imagesFILE,opts1);
    nImg = length(images.coreid);
    
    opts2 = detectImportOptions(occFILE);
    opts2 = setvartype(opts2,{'id','catalogNumber'},{'double','char'});
    occ = readtable(occFILE,opts2);
    nSpecimens = length(occ.id);
    
    if res == "BOTH"
        formatSpecDown = "Starting Download of %.0f Images \n";
        fprintf(formatSpecDown,2*nImg);
    else
        formatSpecDown = "Starting Download of %.0f Images \n";
        fprintf(formatSpecDown,nImg);
    end

    headers = {'Herbarium','ID','occID','catalogID','ImagesIndex','OccIndex','urlHigh','urlLow','Owner','Family','Genus','Species','Sciname'};
    data = cell(nImg,length(headers));
    herbInfo = cell2table(data);
    herbInfo.Properties.VariableNames = headers;

    headersF = {'Herbarium','ID','urlHigh','urlLow'};
    dataF = cell(1000,length(headersF));
    herbInfoF = cell2table(dataF);
    herbInfoF.Properties.VariableNames = headersF;
    F = 0;
    f = 0;

    for j = 1:nImg
        % Get info from images.csv
        ID = '';
        urlHigh = '';
        urlLow = '';
        ID = int2str(images{j,1});
        ID2 = images{j,1};
        urlHigh = images(j,3);
        urlHigh = char(urlHigh{1,1});
        urlLow = images(j,5);
        urlLow = char(urlLow{1,1});
        owner = images(j,7);
        owner = char(owner{1,1});
        catalogID = string(urlHigh);
        splitID = strsplit(catalogID,"/");
        splitID = strsplit(splitID(length(splitID)),".");
        catalogID = char(splitID(1));

        % Find index of ID in occ.id
        C = 0;
        C = find(occ.id==ID2);
        % Get info from occurrences.csv
        family = '';
        genus = '';
        species = '';
        sciname = '';
        family = occ.family{C};
        genus = occ.genus{C};
        species = occ.specificEpithet{C};
        sciname = occ.scientificName{C};
        herbCode = occ.institutionCode{C}; 
        occID = occ.id(C); 
        
        if length(catalogID) > 14
            try
                catalogID = char(occ.catalogNumber{C});
            catch
                catalogID = '';
            end
        end

    %             if ismember(occ.family{C},string(wantedFam))
    %                 occ.family{C}
    %             end

        % ***Take only desired families
        %if ismember(occ.family{C},string(wantedFam))
            filename = '';
            filenameH = '';
            F = F+1;
            if isempty(family)
                if isempty(sciname)
                    %Highres
                    fnameH = {fullfile(outDir,'Full_Resolution'),'\',herbCode,'_',catalogID,'_H','.jpg'};
                    filenameH = strjoin(fnameH,'');
                    %Lowres
                    fname = {fullfile(outDir,'Low_Resolution'),'\',herbCode,'_',catalogID,'.jpg'};
                    filename = strjoin(fname,'');
                else
                    %Highres
                    nameH = strrep(occ.scientificName{C},' ','_');
                    fnameH = {herbCode,catalogID,nameH};
                    fnameH = strjoin(fnameH,'_');
                    fnameH = {fullfile(outDir,'Full_Resolution'),'\',fnameH,'_H','.jpg'};
                    filenameH = strjoin(fnameH,'');
                    %Lowres
                    name = strrep(occ.scientificName{C},' ','_');
                    fname = {herbCode,catalogID,name};
                    fname = strjoin(fname,'_');
                    fname = {fullfile(outDir,'Low_Resolution'),'\',fname,'.jpg'};
                    filename = strjoin(fname,'');
                end
            else
                % Filename when most variables are present
                %Highres
                fnameH = {herbCode,catalogID,family,genus,species};
                fnameH = strjoin(fnameH,'_');
                fnameH = {fullfile(outDir,'Full_Resolution'),'\',fnameH,'_H','.jpg'};
                filenameH = strjoin(fnameH,'');
                %Lowres
                fname = {herbCode,catalogID,family,genus,species};
                fname = strjoin(fname,'_');
                fname = {fullfile(outDir,'Low_Resolution'),'\',fname,'.jpg'};
                filename = strjoin(fname,'');
            end
            filename;
            filenameH;

            % Open image from url
            if res == "HIGH"
                try
                    imageHigh = imread(urlHigh);
                    imwrite(imageHigh,filenameH);
                    formatSpec = "     Downloaded %s \n";
                    fprintf(formatSpec,filenameH);
                catch
                    try
                        imageHigh = imread(urlHigh);
                        imwrite(imageHigh,filenameH);
                        formatSpec = "     Downloaded %s \n";
                        fprintf(formatSpec,filenameH);
                    catch
                        f = f + 1;
                        herbInfoF.Herbarium{f} = herbCode;
                        herbInfoF.ID{f} = ID;
                        herbInfoF.urlHigh{f} = urlHigh;
                        herbInfoF.urlLow{f} = "NA";
                        formatSpec = "     Failed to Download %s \n";
                        fprintf(formatSpec,filenameH);
                    end
                end
            elseif res == "LOW"
                try
                    imageLow = imread(urlLow);
                    imwrite(imageLow,filename);
                    formatSpec = "     Downloaded %s \n";
                    fprintf(formatSpec,filename);
                catch
                    try
                        imageLow = imread(urlLow);
                        imwrite(imageLow,filename);
                        formatSpec = "     Downloaded %s \n";
                        fprintf(formatSpec,filename);
                    catch
                        f = f + 1;
                        herbInfoF.Herbarium{f} = herbCode;
                        herbInfoF.ID{f} = ID;
                        herbInfoF.urlHigh{f} = "NA";
                        herbInfoF.urlLow{f} = urlLow;
                        formatSpec = "     Failed to Download %s \n";
                        fprintf(formatSpec,filename);
                    end
                end
            elseif res == "BOTH"
                %LR
                try
                    imageLow = imread(urlLow);
                    imwrite(imageLow,filename);
                    formatSpec = "     Downloaded %s \n";
                    fprintf(formatSpec,filename);
                catch
                    try
                        imageLow = imread(urlLow);
                        imwrite(imageLow,filename);
                        formatSpec = "     Downloaded %s \n";
                        fprintf(formatSpec,filename);
                    catch
                        f = f + 1;
                        herbInfoF.Herbarium{f} = herbCode;
                        herbInfoF.ID{f} = ID;
                        herbInfoF.urlHigh{f} = "NA";
                        herbInfoF.urlLow{f} = urlLow;
                        formatSpec = "     Failed to Download %s \n";
                        fprintf(formatSpec,filename);
                    end
                end
                %HR
                try
                    imageHigh = imread(urlHigh);
                    imwrite(imageHigh,filenameH);
                    formatSpec = "     Downloaded %s \n";
                    fprintf(formatSpec,filenameH);
                catch
                    try
                        imageHigh = imread(urlHigh);
                        imwrite(imageHigh,filenameH);
                        formatSpec = "     Downloaded %s \n";
                        fprintf(formatSpec,filenameH);
                    catch
                        f = f + 1;
                        herbInfoF.Herbarium{f} = herbCode;
                        herbInfoF.ID{f} = ID;
                        herbInfoF.urlHigh{f} = urlHigh;
                        herbInfoF.urlLow{f} = "NA";
                        formatSpec = "     Failed to Download %s \n";
                        fprintf(formatSpec,filenameH);
                    end
                end
            end

            % Save info
            herbInfo.Herbarium{F} = herbCode;
            herbInfo.ID{F} = ID;
            herbInfo.occID{F} = occID;
            herbInfo.catalogID{F} = catalogID;
            herbInfo.ImagesIndex{F} = j;
            herbInfo.OccIndex{F} = C;
            herbInfo.urlHigh{F} = urlHigh;
            herbInfo.urlLow{F} = urlLow;
            herbInfo.Owner{F} = owner;
            herbInfo.Family{F} = family;
            herbInfo.Genus{F} = genus;
            herbInfo.Species{F} = species;
            herbInfo.Sciname{F} = sciname;
            
            if rem(F,1000)==0 
                infoSaveName = {saveName,'_',int2str(F),'.xlsx'};
                infoSaveName = strjoin(infoSaveName,'');
                writetable(herbInfo,fullfile(outDir,infoSaveName));
                failedSaveName = {saveName,'_Failed_',int2str(F),'.xlsx'};
                failedSaveName = strjoin(failedSaveName,'');
                writetable(herbInfoF,fullfile(outDir,failedSaveName));
            end
        %end%End of wanted family conditional
    end
    infoSaveName = {saveName,'.xlsx'};
    infoSaveName = strjoin(infoSaveName,'');
    writetable(herbInfo,fullfile(fullfile(outDir,'Download_Report'),infoSaveName));

    failedSaveName = {saveName,'_Failed','.xlsx'};
    failedSaveName = strjoin(failedSaveName,'');
    writetable(herbInfoF,fullfile(fullfile(outDir,'Download_Report'),failedSaveName));
end