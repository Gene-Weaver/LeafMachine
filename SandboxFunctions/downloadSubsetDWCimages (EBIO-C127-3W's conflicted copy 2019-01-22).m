function downloadSubsetDWCimages(saveName)
    %saveName = 'COLO-V_Info';
    %downloadSubsetDWCimages('COLO-V_Info')

    %Open Base Dir
    baseDir = uigetdir();
    outDir = uigetdir();
    addpath(genpath(baseDir));

    % Open images and occurrences csv file within that dir
    images = readtable(fullfile(baseDir,'images.csv'));
    nImg = length(images.coreid);
    occ = readtable(fullfile(baseDir,'occurrences.csv'));
    nSpecimens = length(occ.id);

    headers = {'Herbarium','ID','occID','ImagesIndex','OccIndex','urlHigh','urlLow','Owner','Family','Genus','Species','Sciname'};
    data = cell(nImg,12);
    herbInfo = cell2table(data);
    herbInfo.Properties.VariableNames = headers;

    headersF = {'Herbarium','ID','urlHigh','urlLow'};
    dataF = cell(1000,4);
    herbInfoF = cell2table(dataF);
    herbInfoF.Properties.VariableNames = headersF;
    f = 0;

    for j = 1:nImg
        % Get info from images.csv
        ID = '';
        urlHigh = '';
        urlLow = '';
        ID = int2str(images{j,1});
        urlHigh = images(j,3);
        urlHigh = char(urlHigh{1,1});
        urlLow = images(j,5);
        urlLow = char(urlLow{1,1});
        owner = images(j,7);
        owner = char(owner{1,1});

        % Get info from occurrences.csv
        family = '';
        genus = '';
        species = '';
        sciname = '';
        family = occ.family{j};
        genus = occ.genus{j};
        species = occ.specificEpithet{j};
        sciname = occ.scientificName{j};
        herbCode = occ.institutionCode{j}; 
        occID = occ.id(j); 

        filename = '';
        filenameH = '';
        if isempty(family)
            if isempty(sciname)
                %Highres
                fnameH = {outDir,'\',ID,'_H','.jpg'};
                filenameH = strjoin(fnameH,'');
                %Lowres
                fname = {outDir,'\',ID,'.jpg'};
                filename = strjoin(fname,'');
            else
                %Highres
                nameH = strrep(occ.scientificName{j},' ','_');
                fnameH = {herbCode,ID,nameH};
                fnameH = strjoin(fnameH,'_');
                fnameH = {outDir,'\',fnameH,'_H','.jpg'};
                filenameH = strjoin(fnameH,'');
                %Lowres
                name = strrep(occ.scientificName{j},' ','_');
                fname = {herbCode,ID,name};
                fname = strjoin(fname,'_');
                fname = {outDir,'\',fname,'.jpg'};
                filename = strjoin(fname,'');
            end
        else
            % Filename when most variables are present
            %Highres
            fnameH = {herbCode,ID,family,genus,species};
            fnameH = strjoin(fnameH,'_');
            fnameH = {outDir,'\',fnameH,'_H','.jpg'};
            filenameH = strjoin(fnameH,'');
            %Lowres
            fname = {herbCode,ID,family,genus,species};
            fname = strjoin(fname,'_');
            fname = {outDir,'\',fname,'.jpg'};
            filename = strjoin(fname,'');
        end
        filename;
        filenameH;

        % Open image from url
        try
            imageHigh = imread(urlHigh);
            imwrite(imageHigh,filenameH);
            imageLow = imread(urlLow);
            imwrite(imageLow,filename);
        catch
            try
                % Duplicate call to help with server timeout issues
                imageHigh = imread(urlHigh);
                imwrite(imageHigh,filenameH);
                imageLow = imread(urlLow);
                imwrite(imageLow,filename);
            catch
                f = f + 1;
                herbInfoF.Herbarium{f} = herbCode;
                herbInfoF.ID{f} = ID;
                herbInfoF.urlHigh{f} = urlHigh;
                herbInfoF.urlLow{f} = urlLow;
            end
        end

        % Save info
        herbInfo.Herbarium{j} = herbCode;
        herbInfo.ID{j} = ID;
        herbInfo.occID{j} = occID;
        herbInfo.ImagesIndex{j} = j;
        herbInfo.OccIndex{j} = j;
        herbInfo.urlHigh{j} = urlHigh;
        herbInfo.urlLow{j} = urlLow;
        herbInfo.Owner{j} = owner;
        herbInfo.Family{j} = family;
        herbInfo.Genus{j} = genus;
        herbInfo.Species{j} = species;
        herbInfo.Sciname{j} = sciname;

        if rem(j,1000)==0 
            infoSaveName = {saveName,'_',int2str(j),'.xlsx'};
            infoSaveName = strjoin(infoSaveName,'');
            writetable(herbInfo,fullfile(outDir,infoSaveName));
            failedSaveName = {saveName,'_Failed_',int2str(j),'.xlsx'};
            failedSaveName = strjoin(failedSaveName,'');
            writetable(herbInfoF,fullfile(outDir,failedSaveName));
        end

    end
    infoSaveName = {saveName,'.xlsx'};
    infoSaveName = strjoin(infoSaveName,'');
    writetable(herbInfo,fullfile(outDir,infoSaveName));

    failedSaveName = {saveName,'_Failed','.xlsx'};
    failedSaveName = strjoin(failedSaveName,'');
    writetable(herbInfoF,fullfile(outDir,failedSaveName));
end



