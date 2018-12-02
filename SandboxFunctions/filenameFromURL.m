



function filename = filenameFromURL(imageInfo,filenameSuffix,ID,IDr)
        % Find record in other csv
        rowInInfo = find(ismember(imageInfo{:,1}, ID));

        % Extract info
        family = imageInfo.family{rowInInfo};
        genus = imageInfo.genus{rowInInfo};
        species = imageInfo.specificEpithet{rowInInfo};
        sciname = imageInfo.scientificName{rowInInfo};

        if isempty(family)
            if isempty(sciname)
                fname = {IDr,filenameSuffix};
                filename = strjoin(fname,'');
            else
                name = strrep(imageInfo.scientificName{rowInInfo},' ','_');
                fname = {IDr,name,filenameSuffix};
                filename = strjoin(fname,'_');
            end
        else
            % Filename when most variables are present
            fname = {IDr,family,genus,species,filenameSuffix};
            filename = strjoin(fname,'_');
        end
end
