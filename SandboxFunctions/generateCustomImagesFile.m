%%%     Generate custom "images.csv" file by matching records in
%%%     occurrences file with the coreid in the images file. This is
%%%     necessary when runnong only part of a give Darwin Core file.
%%%     LeafMachine iterates through the images file and cross references
%%%     the coreid against the occurrences file.
%%%
%%%     Developed for LeafMachine.org
%%%
%%%     William Weaver
%%%     University of Colorado, Boulder
%%%     Department of Ecology and Evolutionary Biology



function generateCustomImagesFile(imagesIn,occIn,outDir)
    headers = imagesIn.Properties.VariableNames;
    imagesCustom = cell2table(cell(0,length(headers)));
    imagesCustom.Properties.VariableNames = headers;
    
    headers2 = occIn.Properties.VariableNames;
    occSkip = cell2table(cell(0,length(headers2)));
    occSkip.Properties.VariableNames = headers2;
    
    headers1 = occIn.Properties.VariableNames;
    occKeep = cell2table(cell(0,length(headers1)));
    occKeep.Properties.VariableNames = headers1;

    for i = 1:height(occIn)
       occID = occIn{i,1};
       formatSpec = "Searching coreID %s";
       fprintf(formatSpec,string(occID));
       try
           C = find(imagesIn.coreid==occID);
           imagesCustom = [imagesCustom; imagesIn(C,:)];
           
           occKeep = [occKeep; occIn(i,:)];
           
           formatSpec = " --- Image found for %s \n";
           fprintf(formatSpec,string(occIn.catalogNumber(i)));
       catch
           formatSpec = " --- Image not available for %s \n";
           fprintf(formatSpec,string(occIn.catalogNumber(i)));
           
           occSkip = [occSkip; occIn(i,:)];
       end
    end
    
    writetable(imagesCustom,fullfile(outDir,'images_Custom.csv'));
    writetable(occSkip,fullfile(outDir,'occurrences_NoImages.csv'));
    writetable(occKeep,fullfile(outDir,'occurrences_WithImages.csv'));
    
end

