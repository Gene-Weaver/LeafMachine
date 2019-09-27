



%function gatherDWCfiles()

%Open Base Dir
baseDir = uigetdir();
outDir = uigetdir();
addpath(genpath(baseDir));
% List all subfolders (each subfolder should be a seperate herbarium)
allHerbariaNames = dir2(baseDir);

headers = {'Herbarium','nImages','nSpecimens'};
data = cell(length(allHerbariaNames),3);
herbSummary = cell2table(data);
herbSummary.Properties.VariableNames = headers;

headers2 = {'Herbarium','ID','occID','ImagesIndex','OccIndex','urlHigh','urlLow','Owner','Family','Genus','Species','Sciname'};
data2 = cell(10*length(allHerbariaNames),12);
herbInfo = cell2table(data2);
herbInfo.Properties.VariableNames = headers2;

headersF = {'Herbarium','ID','urlHigh','urlLow'};
dataF = cell(1000,4);
herbInfoF = cell2table(dataF);
herbInfoF.Properties.VariableNames = headersF;
f = 0;
a = 0;

for i = 1:length(allHerbariaNames)
    try
        % Set name for current Dir/Herb
        currentHerbRaw = allHerbariaNames(i).name;
        currentHerb = strsplit(currentHerbRaw,"_");
        currentHerb = char(currentHerb{1})

        % Specific Herb dir
        filename = fullfile(allHerbariaNames(i).folder, allHerbariaNames(i).name);

        % Open images and occurrences csv file within that dir
        images = readtable(fullfile(filename,'images.csv'));
        nImg = length(images.coreid);
        occ = readtable(fullfile(filename,'occurrences.csv'));
        nSpecimens = length(occ.id);
        % Write summary info
        herbSummary.Herbarium{i} = currentHerb;
        herbSummary.nImages{i} = nImg;
        herbSummary.nSpecimens{i} = nSpecimens;

        randImgInd = randi(nImg,10,1);
        randID = images.coreid(randImgInd);
        % Find record in other csv
        randOccInd = [0,0,0,0,0,0,0,0,0,0];
        for k = 1:10
            randOccInd(k) = find(ismember(occ{:,1}, randID(k)));
        end
        randOccInd = transpose(randOccInd);
        for j = 1:10
            % Get info from images.csv
            a = a + 1;
            ID = '';
            urlHigh = '';
            urlLow = '';
            ID = int2str(images{randImgInd(j,1),1});
            urlHigh = images(randImgInd(j,1),3);
            urlHigh = char(urlHigh{1,1});
            urlLow = images(randImgInd(j,1),5);
            urlLow = char(urlLow{1,1});
            owner = images(randImgInd(j,1),7);
            owner = char(owner{1,1});

            % Get info from occurrences.csv
            family = '';
            genus = '';
            species = '';
            sciname = '';
            family = occ.family{randOccInd(j,1)};
            genus = occ.genus{randOccInd(j,1)};
            species = occ.specificEpithet{randOccInd(j,1)};
            sciname = occ.scientificName{randOccInd(j,1)};
            herbCode = occ.institutionCode{randOccInd(j,1)}; 
            occID = occ.id(randOccInd(j,1)); 

            filename = '';
            filenameH = '';
            if isempty(family)
                if isempty(sciname)
                    %Highres
                    fnameH = {outDir,'\',herbCode,'_',ID,'_H','.jpg'};
                    filenameH = strjoin(fnameH,'');
                    %Lowres
                    fname = {outDir,'\',herbCode,'_',ID,'.jpg'};
                    filename = strjoin(fname,'');
                else
                    %Highres
                    nameH = strrep(occ.scientificName{randOccInd(j,1)},' ','_');
                    fnameH = {herbCode,ID,nameH};
                    fnameH = strjoin(fnameH,'_');
                    fnameH = {outDir,'\',fnameH,'_H','.jpg'};
                    filenameH = strjoin(fnameH,'');
                    %Lowres
                    name = strrep(occ.scientificName{randOccInd(j,1)},' ','_');
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
            herbInfo.Herbarium{a} = currentHerb;
            herbInfo.ID{a} = ID;
            herbInfo.occID{a} = occID;
            herbInfo.ImagesIndex{a} = randImgInd(j,1);
            herbInfo.OccIndex{a} = randOccInd(j,1);
            herbInfo.urlHigh{a} = urlHigh;
            herbInfo.urlLow{a} = urlLow;
            herbInfo.Owner{a} = owner;
            herbInfo.Family{a} = family;
            herbInfo.Genus{a} = genus;
            herbInfo.Species{a} = species;
            herbInfo.Sciname{a} = sciname;

        end
    catch
        [currentHerb,'!!!!!!!!!']
    end

% Combine into superfile

end
writetable(herbInfo,fullfile(outDir,'Herbarium10xSample2.xlsx'))
writetable(herbSummary,fullfile(outDir,'HerbariumSummary2.xlsx'))
writetable(herbInfoF,fullfile(outDir,'Herbarium10xSampleFailed2.xlsx'))
%end
