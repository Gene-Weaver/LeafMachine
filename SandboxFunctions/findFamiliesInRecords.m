% Find families in records
% https://www.mathworks.com/matlabcentral/answers/uploaded_files/6962/recurse_subfolders.m
% https://www.mathworks.com/matlabcentral/answers/112746-opening-a-directory-of-folders-and-accessing-data-within-each-folder



% Wanted Families
% wantedFam = {'Ulmaceae', 'Betulaceae', 'Fagaceae', 'Magnoliaceae',...
%     'Lauraceae', 'Ericaceae', 'Sapindaceae', 'Aceraceae', 'Oleaceae',...
%     'Myrtaceae', 'Malvaceae', 'Rhamnaceae', 'Salicaceae', 'Caprifoliaceae',...
%     'Vitaceae', 'Adoxaceae', 'Solanaceae'};

wantedFam = {'Fagaceae'};

%ismember('Ulmaceae',wantedFam)

% Dig into DwC files
baseFolder = fullfile('D:\Dropbox\ML_Project\Image_Database', '\DwC_TwoRulerTypes');
%baseFolder = fullfile('D:\Will Files\Dropbox\ML_Project\Image_Database', '\DwC_TwoRulerTypes');
subFolders = genpath(baseFolder);
subFolders_0 = subFolders;

listOfFolderNames = {};
while true
	[singleSubFolder, subFolders_0] = strtok(subFolders_0, ';');
	if isempty(singleSubFolder)
		break;
	end
	listOfFolderNames = [listOfFolderNames singleSubFolder];
end
numberOfFolders = length(listOfFolderNames)



% Get info from DwC files
for k = 2 : numberOfFolders
	% Get this folder and print it out.
	thisFolder = listOfFolderNames{k};
    parsing = strsplit(thisFolder,'\');
    lp = length(parsing);
    saveName = parsing{lp};
    
    % *** If the dir exists, it skips EVERYTHING, otherwise it downloads
    % like normal

%     if ~exist(fullfile('D:\Dropbox\ML_Project\Image_Database\FamTest3', saveName),'dir')
%         % Make outdir
%         mkdir(fullfile('D:\Dropbox\ML_Project\Image_Database\FamTest3', saveName));
%         outDir = fullfile('D:\Dropbox\ML_Project\Image_Database\FamTest3', saveName);
%     if ~exist(fullfile('G:\DwC_Family', saveName),'dir')
%         % Make outdir
%         mkdir(fullfile('G:\DwC_Family', saveName));
%         outDir = fullfile('G:\DwC_Family', saveName);
    if ~exist(fullfile('G:\DwC_Fagaceae', saveName),'dir')
        % Make outdir
        mkdir(fullfile('G:\DwC_Fagaceae', saveName));
        outDir = fullfile('G:\DwC_Fagaceae', saveName);
        
        
        % ***Begin everything
        fprintf('Processing folder %s\n', saveName);
	
        % Open images and occurrences csv file within that dir
        images = readtable(fullfile(thisFolder,'images.csv'));
        nImg = length(images.coreid);
        occ = readtable(fullfile(thisFolder,'occurrences.csv'));
        nSpecimens = length(occ.id);

        headers = {'Herbarium','ID','occID','ImagesIndex','OccIndex','urlHigh','urlLow','Owner','Family','Genus','Species','Sciname'};
        data = cell(nImg,12);
        herbInfo = cell2table(data);
        herbInfo.Properties.VariableNames = headers;

        headersF = {'Herbarium','ID','urlHigh','urlLow'};
        dataF = cell(1000,4);
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
%             if ismember(occ.family{C},string(wantedFam))
%                 occ.family{C}
%             end

            % ***Take only desired families
            if ismember(occ.family{C},string(wantedFam))
                filename = '';
                filenameH = '';
                F = F+1;
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
                        nameH = strrep(occ.scientificName{C},' ','_');
                        fnameH = {herbCode,ID,nameH};
                        fnameH = strjoin(fnameH,'_');
                        fnameH = {outDir,'\',fnameH,'_H','.jpg'};
                        filenameH = strjoin(fnameH,'');
                        %Lowres
                        name = strrep(occ.scientificName{C},' ','_');
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
                herbInfo.Herbarium{F} = herbCode;
                herbInfo.ID{F} = ID;
                herbInfo.occID{F} = occID;
                herbInfo.ImagesIndex{F} = j;
                herbInfo.OccIndex{F} = C;
                herbInfo.urlHigh{F} = urlHigh;
                herbInfo.urlLow{F} = urlLow;
                herbInfo.Owner{F} = owner;
                herbInfo.Family{F} = family;
                herbInfo.Genus{F} = genus;
                herbInfo.Species{F} = species;
                herbInfo.Sciname{F} = sciname;
                sciname

                if rem(F,1000)==0 
                    infoSaveName = {saveName,'_',int2str(F),'.xlsx'};
                    infoSaveName = strjoin(infoSaveName,'');
                    writetable(herbInfo,fullfile(outDir,infoSaveName));
                    failedSaveName = {saveName,'_Failed_',int2str(F),'.xlsx'};
                    failedSaveName = strjoin(failedSaveName,'');
                    writetable(herbInfoF,fullfile(outDir,failedSaveName));
                end
            end%End of wanted family conditional
        end
        infoSaveName = {saveName,'.xlsx'};
        infoSaveName = strjoin(infoSaveName,'');
        writetable(herbInfo,fullfile(outDir,infoSaveName));

        failedSaveName = {saveName,'_Failed','.xlsx'};
        failedSaveName = strjoin(failedSaveName,'');
        writetable(herbInfoF,fullfile(outDir,failedSaveName));
    else 
        fprintf('SKIPPED due to dir already exsisting %s\n', saveName);
    end%end dir check conditional
end

















