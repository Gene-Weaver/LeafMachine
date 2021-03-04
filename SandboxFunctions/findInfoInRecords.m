%%% Find out general info from DwC files
%%%

% Wanted Families
%wantedFam = {'Ulmaceae', 'Betulaceae', 'Fagaceae', 'Magnoliaceae',...
%    'Lauraceae', 'Ericaceae', 'Sapindaceae', 'Aceraceae', 'Oleaceae',...
%    'Myrtaceae', 'Malvaceae', 'Rhamnaceae', 'Salicaceae', 'Caprifoliaceae',...
%    'Vitaceae', 'Adoxaceae', 'Solanaceae'};

wantedFam = {'Fagaceae'};

%ismember('Ulmaceae',wantedFam)

% Dig into DwC files
%baseFolder = fullfile('D:\Will Files\Dropbox\ML_Project\Image_Database', '\DwC_TwoRulerTypes');
baseFolder = fullfile('D:\Dropbox\ML_Project\Image_Database', '\DwC_TwoRulerTypes');
%baseFolder = fullfile('D:\Dropbox\ML_Project\Image_Database', '\DwC');
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
numberOfFolders = length(listOfFolderNames)-1

headersSummary = {'Herbarium','nSpecimens_wImages','nFamilyNames','nGenusNames','nSpeciesNames','nScinameNames','nUniqueFamilies','nUniqueGenus','nUniqueSpecies','nUniqueSciname',...
    'nState_Province','nCounty','nHabitat','nReproductiveCondition','nDecimalLatitude','nDecimalLongitude','nGeoreferenceSource','nVerbatimElevation','nEventDate','nYear','nMonth','nDay',...
    'minYear','maxYear'};
dataSummary = cell(numberOfFolders-1,length(headersSummary));
herbariumSummary = cell2table(dataSummary);
herbariumSummary.Properties.VariableNames = headersSummary;


WBf = waitbar(0,"Folders");
% Get info from DwC files
for k = 2 : numberOfFolders
    WBf = waitbar(k/numberOfFolders,WBf,"Folders");
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
    outDir = fullfile('D:\Dropbox\ML_Project\Image_Database\DwC_Investigate_Fagaceae_TwoRulerTypes', saveName);
    if ~exist(outDir,'dir')
        % Make outdir
        mkdir(outDir);
        
        % ***Begin everything
        fprintf('Processing folder %s\n', saveName);
	
        % Open images and occurrences csv file within that dir
        images = readtable(fullfile(thisFolder,'images.csv'));
        nImg = length(images.coreid);
        occ = readtable(fullfile(thisFolder,'occurrences.csv'));
        nSpecimens = length(occ.id);

        headers = {'Herbarium','ID','occID','ImagesIndex','OccIndex','urlHigh','urlLow','Owner','Family','Genus','Species','Sciname','State_Province',...
            'County','Habitat','ReproductiveCondition','DecimalLatitude','DecimalLongitude','GeoreferenceSource','VerbatimElevation','EventDate','Year','Month','Day'};
        data = cell(nImg,length(headers));
        herbInfo = cell2table(data);
        herbInfo.Properties.VariableNames = headers;
        
        % Failed list
        headersF = {'Herbarium','ID','urlHigh','urlLow'};
        dataF = cell(1000,4);
        herbInfoF = cell2table(dataF);
        herbInfoF.Properties.VariableNames = headersF;
        
        F = 0;
        f = 0;
        WB = waitbar(0,"Item Records");
        
        for j = 1:nImg
            WB = waitbar(j/nImg,WB,"Item Records");
            % Get info from images.csv
            tempIndex = j/nImg*100;
            %fprintf('Completed: %s\n', tempIndex);
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
            try
                C = find(occ.id==ID2);
            catch
                C = find(occ.id==string(ID2));
            end
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
                herbInfo.State_Province{F} = occ.stateProvince(C);
                herbInfo.County{F} = occ.county(C);
                herbInfo.DecimalLatitude{F} = occ.decimalLatitude(C);
                herbInfo.DecimalLongitude{F} = occ.decimalLongitude(C);
                herbInfo.Habitat{F} = occ.habitat(C);
                herbInfo.ReproductiveCondition{F} = occ.reproductiveCondition(C);
                herbInfo.GeoreferenceSource{F} = occ.georeferenceSources(C);
                herbInfo.VerbatimElevation{F} = occ.verbatimElevation(C);
                herbInfo.EventDate{F} = occ.eventDate(C);
                herbInfo.Year{F} = occ.year(C);
                herbInfo.Month{F} = occ.month(C);
                herbInfo.Day{F} = occ.day(C);

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
        
        % Count info from this herbarium
        herbariumSummary.Herbarium{k-1} = saveName;
        herbariumSummary.nSpecimens_wImages{k-1} = nImg;
        herbariumSummary.nFamilyNames{k-1} = countItemsInTable(herbInfo.Family,'',nImg);
        herbariumSummary.nGenusNames{k-1} = countItemsInTable(herbInfo.Genus,'',nImg);
        herbariumSummary.nSpeciesNames{k-1} = countItemsInTable(herbInfo.Species,'',nImg);
        herbariumSummary.nScinameNames{k-1} = countItemsInTable(herbInfo.Sciname,'',nImg);
        
        %herbariumSummary.nUniqueFamilies{k-1} = countUniqItemsInTable(herbInfo.Family);
        %herbariumSummary.nUniqueGenus{k-1} = countUniqItemsInTable(herbInfo.Genus);
        %herbariumSummary.nUniqueSpecies{k-1} = countUniqItemsInTable(herbInfo.Species);
        %herbariumSummary.nUniqueSciname{k-1} = countUniqItemsInTable(herbInfo.Sciname);
        
        herbariumSummary.nState_Province{k-1} = countItemsInTable(herbInfo.State_Province,'',nImg);
        herbariumSummary.nCounty{k-1} = countItemsInTable(herbInfo.County,'',nImg);
        herbariumSummary.nHabitat{k-1} = countItemsInTable(herbInfo.Habitat,'',nImg);
        herbariumSummary.nReproductiveCondition{k-1} = countItemsInTable(herbInfo.ReproductiveCondition,'',nImg);
        herbariumSummary.nDecimalLatitude{k-1} = countItemsInTable(herbInfo.DecimalLatitude,'number',nImg);
        herbariumSummary.nDecimalLongitude{k-1} = countItemsInTable(herbInfo.DecimalLongitude,'number',nImg);
        herbariumSummary.nGeoreferenceSource{k-1} = countItemsInTable(herbInfo.GeoreferenceSource,'',nImg);
        herbariumSummary.nVerbatimElevation{k-1} = countItemsInTable(herbInfo.VerbatimElevation,'',nImg);
        herbariumSummary.nEventDate{k-1} = countItemsInTable(herbInfo.EventDate,'',nImg);
        herbariumSummary.nYear{k-1} = countItemsInTable(herbInfo.Year,"year",nImg);
        herbariumSummary.nMonth{k-1} = countItemsInTable(herbInfo.Month,'',nImg);
        herbariumSummary.nDay{k-1} = countItemsInTable(herbInfo.Day,'',nImg);
        herbariumSummary.minYear{k-1} = find_Min_Max(herbInfo.Year,"min");
        herbariumSummary.maxYear{k-1} = find_Min_Max(herbInfo.Year,"max");
        
        iter = k - 1;
        SummarySaveName = ['Herbaria_Summary_',string(iter),'.xlsx'];
        SummarySaveName = strjoin(SummarySaveName,'');
        writetable(herbariumSummary,fullfile(outDir,SummarySaveName));
        
    else 
        fprintf('SKIPPED due to dir already exsisting %s\n', saveName);
    end%end dir check conditional
    
    SummarySaveName = ['Herbaria_Summary_Fagaceae_TwoRulerTypes','_FINAL4','.xlsx'];
    outDir = fullfile('D:\Dropbox\ML_Project\Image_Database\DwC_Investigate_Fagaceae_TwoRulerTypes');
    writetable(herbariumSummary,fullfile(outDir,SummarySaveName));
end
