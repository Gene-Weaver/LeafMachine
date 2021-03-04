



function [filenameReturn,family,genus,species,occMatch] = filenameFromURL(occ,images,filenameSuffix,ID,high_low)
    INVAL = ['\','/',':','*','?','"','<','>','|','@','.',',','+','=','!','#','$','%','^','&','~','`'];
    DIGITS = ['0','1','2','3','4','5','6','7','8','9'];
% filename = filenameFromURL(imageInfo,filenameSuffix,ID,IDr)

%     % Find record in other csv
%     rowInInfo = find(ismember(imageInfo{:,1}, ID));
% 
%     % Extract info
%     family = imageInfo.family{rowInInfo};
%     genus = imageInfo.genus{rowInInfo};
%     species = imageInfo.specificEpithet{rowInInfo};
%     sciname = imageInfo.scientificName{rowInInfo};
% 
%     if isempty(family)
%         if isempty(sciname)
%             fname = {IDr,filenameSuffix};
%             filename = strjoin(fname,'');
%         else
%             name = strrep(imageInfo.scientificName{rowInInfo},' ','_');
%             fname = {IDr,name,filenameSuffix};
%             filename = strjoin(fname,'_');
%         end
%     else
%         % Filename when most variables are present
%         fname = {IDr,family,genus,species,filenameSuffix};
%         filename = strjoin(fname,'_');
%     end
        
    j = find(images.coreid==ID);
    % Get info from images.csv
    urlHigh = '';
    urlLow = '';
    urlHigh = images(j,3);
    urlHigh = char(urlHigh{1,1});
    urlLow = images(j,5);
    urlLow = char(urlLow{1,1});
    catalogID_0 = string(urlHigh);
    splitID = strsplit(catalogID_0,"/");
    splitID = strsplit(splitID(length(splitID)),".");
    catalogID_0 = char(splitID(1));
    catalogIDfromURL = catalogID_0;
    
    family = "";
    genus = "";
    species = "";
    sciname = "";
    filename = '';
    filenameH = '';
    filenameReturn = "";
    
    try
        % Find index of ID in occ.id
        C = 0;
        C = find(occ.id==ID);
        % Get info from occurrences.csv
        family = occ.family{C};
        genus = occ.genus{C};
        species = occ.specificEpithet{C};
        sciname = occ.scientificName{C};
        herbCode = occ.institutionCode{C}; 
        
        %%% This is important. Some herbaria, like COLO have catalog
        %%% numbers that begin with zeros. These are typically lost in the
        %%% csv file, meaning that an eight digit catalog number  like 00000553 may be
        %%% truncated to 553. Since the length of catalog numbers may
        %%% differ between herbaria, I decided to first try to read the end
        %%% of the URL for the catalog number. If that returns a
        %%% non-catalog ID, that will be ruled out by either of the two
        %%% following if satements. If the URL image file happens to be
        %%% named less that 14 characters AND does not contain invalid
        %%% characters, then the catalog number MAY be incorrect in the
        %%% LeafMachine-given filename.
        
        idFromOCC = occ.catalogNumber{C};
        if ismember('+',idFromOCC), idFromOCC = num2str(str2double(idFromOCC)); end % check for scientific notation
        idFromOCC = char(idFromOCC);
        
        if sum(ismember(INVAL,catalogIDfromURL))>0 %%%catches things like 00-duPr5kf7VNyTay2iRXeTek?resize=4000&format=jpeg
            try
                catalogID = idFromOCC;
                if catalogID == ""
                    catalogID = replace(catalogIDfromURL, INVAL, "_");
                end
            catch
                catalogID = replace(catalogIDfromURL, INVAL, "_");
            end
        elseif length(catalogIDfromURL) > 14
            try
                catalogID = idFromOCC;
                if catalogID == ""
                    catalogID = replace(catalogIDfromURL, INVAL, "_");
                end
            catch
                catalogID = replace(catalogIDfromURL, INVAL, "_");
            end
        elseif sum(ismember(DIGITS,catalogIDfromURL)) == 0  %%%avoids names like "format_jpeg" by ensuring index number of some kind
            catalogID = idFromOCC;
            if catalogID == ""
                catalogID = replace(catalogIDfromURL, INVAL, "_");
            end
        else 
            catalogID = replace(catalogIDfromURL, INVAL, "_");
        end
        
        formatSpecCatalog = "CatalogID from URL: %s --- CatalogID from occurrences file: %s --- CHOSEN: %s \n";
        fprintf(formatSpecCatalog,catalogIDfromURL,char(occ.catalogNumber{C}),catalogID);
        
        if isempty(family)
            if isempty(sciname)
                %Highres
                fnameH = {herbCode,'_',catalogID,'_H',filenameSuffix};
                filenameH = strjoin(fnameH,'');
                %Lowres
                fname = {herbCode,'_',catalogID,filenameSuffix};
                filename = strjoin(fname,'');
            else
                %Highres
                nameH = strrep(occ.scientificName{C},' ','_');
                fnameH = {herbCode,catalogID,nameH};
                fnameH = strjoin(fnameH,'_');
                fnameH = {fnameH,'_H',filenameSuffix};
                filenameH = strjoin(fnameH,'');
                %Lowres
                name = strrep(occ.scientificName{C},' ','_');
                fname = {herbCode,catalogID,name};
                fname = strjoin(fname,'_');
                fname = {fname,filenameSuffix};
                filename = strjoin(fname,'');
            end
        else
            % Filename when most variables are present
            %Highres
            fnameH = {herbCode,catalogID,family,genus,species};
            fnameH = strjoin(fnameH,'_');
            fnameH = {fnameH,'_H',filenameSuffix};
            filenameH = strjoin(fnameH,'');
            %Lowres
            fname = {herbCode,catalogID,family,genus,species};
            fname = strjoin(fname,'_');
            fname = {fname,filenameSuffix};
            filename = strjoin(fname,'');
        end

        if high_low == "goodQualityAccessURI"
            filenameReturn = filename;
        elseif high_low == "accessURI"
            filenameReturn = filenameH;
        end

        filenameReturn = replace(filenameReturn,INVAL,'_');
        occMatch = "PASS";
    catch 
        occMatch = "FAIL";
        if filenameReturn == ""; filenameReturn = "No_Occurrence_Record";end
        formatSpec = "* Notice * coreID %s from the images.csv file not found in the occurrences.csv file \n";
        fprintf(formatSpec,ID);
    end
    
    if family == ""; family = "NA";end
    if genus == ""; genus = "NA";end
    if species == ""; species = "NA";end
end
