%%%     Subset Overlay Output Images for QC
%%%
%%%     Developed for LeafMachine.org
%%%
%%%     William Weaver
%%%     University of Colorado, Boulder
%%%     Department of Ecology and Evolutionary Biology

% I ran first section without copying images to get the lists, sorted
% things in excel some more, then ran the intersection and randomization,
% then the first section with copying turned on again

% Get chosen families
% Wanted Families
wantedFam = {'Ulmaceae', 'Betulaceae', 'Fagaceae', 'Magnoliaceae','Lauraceae',...
    'Ericaceae', 'Sapindaceae', 'Aceraceae', 'Oleaceae','Myrtaceae', ...
    'Malvaceae', 'Rhamnaceae', 'Salicaceae', 'Caprifoliaceae','Vitaceae',...
    'Adoxaceae', 'Solanaceae','Ginkoaceae','Platanaceae','Anacardiaceae','Cannabaceae'};
families = upper(wantedFam);

% Import LM ouput files
%these are modified in excel by adding the
%family,genus,species,genus_species columns and removing all NA rows
cololr = readtable("D:\Dropbox\ML_Project\Image_Database\COLO_CatalogID_LRFR_Matching\COLO_LR_Out\Data\LeafMachine_Batch__08-23-2019_21-02__FINAL_noNA.xlsx");
colofr = readtable("D:\Dropbox\ML_Project\Image_Database\LeafMachine_Validation_Images\Manuscript_Vouchers\COLOFullRes_SelectFamilies\LeafMachine_Batch__08-24-2019_03-19__FINAL.xlsx");
rlr = readtable("D:\Dropbox\ML_Project\Image_Database\LeafMachine_Validation_Images\Manuscript_Vouchers\RhodesLowRes_SelectFamilies\Data\LeafMachine_Batch__08-23-2019_02-42__FINAL_noNA.xlsx");
rfr = readtable("D:\Dropbox\ML_Project\Image_Database\LeafMachine_Validation_Images\Manuscript_Vouchers\RhodesFullRes_SelectFamilies\Data\LeafMachine_Batch__08-23-2019_17-49__FINAL_noNA.xlsx");

herbs = {rlr,rfr,cololr,colofr};

% Get dirs of the overlay images for copying to new folder for QC
dirLR = dir("D:\Dropbox\ML_Project\Image_Database\LeafMachine_Validation_Images\Manuscript_Vouchers\Overlay_LR");
dirFR = dir("D:\Dropbox\ML_Project\Image_Database\LeafMachine_Validation_Images\Manuscript_Vouchers\Overlay_FR");
dirLR = dirLR(~ismember({dirLR.name},{'.','..'}));
dirFR = dirFR(~ismember({dirFR.name},{'.','..'}));

dirPaths = {dirLR,dirFR,dirLR,dirFR};


% List output dirs
dirOutLeafLR = "D:\Dropbox\ML_Project\Image_Database\LeafMachine_Validation_Images\Manuscript_Vouchers\QC_Overlay\Leaf_Positive_LR";
dirOutLeafFR = "D:\Dropbox\ML_Project\Image_Database\LeafMachine_Validation_Images\Manuscript_Vouchers\QC_Overlay\Leaf_Positive_FR";

dirPCLR = "D:\Dropbox\ML_Project\Image_Database\LeafMachine_Validation_Images\Manuscript_Vouchers\QC_Overlay\PartialClump_LR";
dirPCFR = "D:\Dropbox\ML_Project\Image_Database\LeafMachine_Validation_Images\Manuscript_Vouchers\QC_Overlay\PartialClump_FR";

dirOUTS = {dirOutLeafLR,dirOutLeafFR,dirPCLR,dirPCFR};



fNames = ["rlr","rfr","cololr","colofr"];
% Iterate through Rhodes LR, Rhodes FR, COLO to sort out 'Leaf' and 'PC'
for i = 1:4
    % Create output tables
    headers = herbs{1}.Properties.VariableNames;
    data = cell(0,length(headers));
    Positive_Leaf_Out = cell2table(data);
    Positive_Leaf_Out.Properties.VariableNames = headers;

    NA_Out = cell2table(data);
    NA_Out.Properties.VariableNames = headers;

    PartialClump_Out = cell2table(data);
    PartialClump_Out.Properties.VariableNames = headers;
    % Indexing for name checks to prevent duplicate Overlay copies for when
    % there were mult. leaves per image
    completedFilesnames = {};
    CCC = 1;
    completedFilesnames2 = {};
    CCC2 = 1;
    
    herb = herbs{i};
%     dirOutLEAF = dirOutLEAVES{i};
%     dirOutCLUMP = dirOutCLUMPS{i};
    dirOverlay = dirPaths{i};
    dirCopy = dirOverlay(1,1).folder;
    dirOverlayNames = {};
    for m = 1:length(dirOverlay)
        fName = strsplit(dirOverlay(m,1).name,"_Overlay.jpg");
        dirOverlayNames{m,1} = fName{1};
    end
    
    for j = 1:length(herb.filename)
        %if ismember(herb.filename{j},RAND1000.filename) % toggle this 
        j    
        if ~(herb.SVMprediction{j} == "NA")
            if (herb.SVMprediction{j} == "Leaf")
                if ismember(upper(herb.family{j}),families) % leaf found, correct family
                    sprintf(upper(herb.family{j}))
                    if ismember(herb.filename{j},dirOverlayNames(:,1))
                        % add to positive table
                        Positive_Leaf_Out = [Positive_Leaf_Out;herb(j,:)];
                        
                        % copy overlay to new folder
                        fName = strjoin([herb.filename{j},"_Overlay.jpg"],"");
                        if CCC == 1
                            %imCopy = imread(fullfile(dirCopy,fName));
                            %imwrite(imCopy,fullfile(dirOutLEAF,fName))
                            completedFilesnames{CCC} = herb.filename{j};
                            CCC = CCC + 1;
                        else
                            if ~ismember(herb.filename{j},completedFilesnames)
                                %imCopy = imread(fullfile(dirCopy,fName));
                                %imwrite(imCopy,fullfile(dirOutLEAF,fName))
                                completedFilesnames{CCC} = herb.filename{j};
                                CCC = CCC + 1;
                            end
                        end
                    end
%                 else % leaf found, wrong/no family 
%                     if ismember(herb.filename{j},dirOverlayNames(:,1))
%                         % add to positive table
%                         WrongFam_Out = [WrongFam_Out;herb(j,:)];
% 
%                         % copy overlay to new folder
%                         fName = strjoin([herb.filename{j},"_Overlay.jpg"],"");
%                         if CCC2 == 1
%                             imCopy = imread(fullfile(dirCopy,fName));
%                             imwrite(imCopy,fullfile(dirOutWRONG,fName))
%                             completedFilesnames2{CCC2} = herb.filename{j};
%                             CCC2 = CCC2 + 1;
%                         else
%                             if ~ismember(herb.filename{j},completedFilesnames2)
%                                 imCopy = imread(fullfile(dirCopy,fName));
%                                 imwrite(imCopy,fullfile(dirOutWRONG,fName))
%                                 completedFilesnames2{CCC2} = herb.filename{j};
%                                 CCC2 = CCC2 + 1;
%                             end
%                         end
%                     end 
                end % end family check
            else % for SVMprediction == "LeafPartial" || "clump"
                if ismember(upper(herb.family{j}),families) % leaf found, correct family
                    sprintf(upper(herb.family{j}))
                    if ismember(herb.filename{j},dirOverlayNames(:,1))
                        % add to positive table
                        PartialClump_Out = [PartialClump_Out;herb(j,:)];
                        
                        % copy overlay to new folder
                        fName = strjoin([herb.filename{j},"_Overlay.jpg"],"");
                        if CCC2 == 1
                            %imCopy = imread(fullfile(dirCopy,fName));
                            %imwrite(imCopy,fullfile(dirOutCLUMP,fName))
                            completedFilesnames2{CCC2} = herb.filename{j};
                            CCC2 = CCC2 + 1;
                        else
                            if ~ismember(herb.filename{j},completedFilesnames2)
                                %imCopy = imread(fullfile(dirCopy,fName));
                                %imwrite(imCopy,fullfile(dirOutCLUMP,fName))
                                completedFilesnames2{CCC2} = herb.filename{j};
                                CCC2 = CCC2 + 1;
                            end
                        end
                    end
                end
            end % end leaf check
        elseif (herb.SVMprediction{j} == "NA") % if SVMpred == NA
            NA_Out = [NA_Out;herb(j,:)];
        end % end NA check
        %end % toggle for running only the rand1000 set
    end % end single herb
    fName_Leaf = ["D:\Dropbox\ML_Project\Image_Database\LeafMachine_Validation_Images\Manuscript_Vouchers\QC_Overlay\",fNames(i),"_Leaf_Positive.xlsx"];
    fName_Leaf = strjoin(fName_Leaf,"");
    fName_PC = ["D:\Dropbox\ML_Project\Image_Database\LeafMachine_Validation_Images\Manuscript_Vouchers\QC_Overlay\",fNames(i),"_PartialClump.xlsx"];
    fName_PC = strjoin(fName_PC,"");
    writetable(Positive_Leaf_Out,fName_Leaf)
    writetable(PartialClump_Out,fName_PC)
end % end herb list


%% Find intersection of Rhodes Leaf ID'd specimens and randomly select 100
%to create these files, take output from above and keep only the uniq
%filnames
LR = readtable("D:\Dropbox\ML_Project\Image_Database\LeafMachine_Validation_Images\Manuscript_Vouchers\QC_Overlay\rlr_Leaf_Positive_Uniq.xlsx");
FR = readtable("D:\Dropbox\ML_Project\Image_Database\LeafMachine_Validation_Images\Manuscript_Vouchers\QC_Overlay\rfr_Leaf_Positive_Uniq.xlsx");
COLOlr = readtable("D:\Dropbox\ML_Project\Image_Database\LeafMachine_Validation_Images\Manuscript_Vouchers\QC_Overlay\cololr_Leaf_Positive_Uniq.xlsx");
COLOfr = readtable("D:\Dropbox\ML_Project\Image_Database\LeafMachine_Validation_Images\Manuscript_Vouchers\QC_Overlay\colofr_Leaf_Positive_Uniq.xlsx");

groupLR = [LR;COLOlr];
groupFR = [FR;COLOfr];

LRpc = readtable("D:\Dropbox\ML_Project\Image_Database\LeafMachine_Validation_Images\Manuscript_Vouchers\QC_Overlay\rlr_PartialClump_Uniq.xlsx");
FRpc = readtable("D:\Dropbox\ML_Project\Image_Database\LeafMachine_Validation_Images\Manuscript_Vouchers\QC_Overlay\rfr_PartialClump_Uniq.xlsx");
COLOlrpc = readtable("D:\Dropbox\ML_Project\Image_Database\LeafMachine_Validation_Images\Manuscript_Vouchers\QC_Overlay\cololr_PartialClump_Uniq.xlsx");
COLOfrpc = readtable("D:\Dropbox\ML_Project\Image_Database\LeafMachine_Validation_Images\Manuscript_Vouchers\QC_Overlay\colofr_PartialClump_Uniq.xlsx");

groupLRpc = [LRpc;COLOlrpc];
groupFRpc = [FRpc;COLOfrpc];

randLeafFR2 = groupFR;
randLeafLR2 = groupLR;
randPCFR2 = groupFRpc;
randPCLR2 = groupLRpc;

RANDS = {randLeafFR2,randLeafLR2,randPCFR2,randPCLR2};

for ii = 1:4
    RAND = RANDS{ii};
    for jj = 1:length(RANDS{ii}.filename)
        SSS = RAND.filename{jj};
        SSS_RHODES = strsplit(SSS,"_");
        SSS_RHODES = string(SSS_RHODES{1});
        if (SSS_RHODES == "COLO")   
            SSS_S = strsplit(SSS,"_H");
            RAND.filename{jj} = SSS_S{1};
        else 
            RAND.filename{jj} = SSS;
        end
    end
    RANDS{ii} = RAND;
end
randLeafFR2 = RANDS{1};
randLeafLR2 = RANDS{2};
randPCFR2 = RANDS{3};
randPCLR2 = RANDS{4};

intersectLeaf = intersect(randLeafFR2,randLeafLR2);
intersectLeaf2 = intersect(intersectLeaf.filename,dirLR.name);
intersectPC = intersect(randPCFR2,randPCLR2);

randLeafNames = intersectLeaf(randperm(height(intersectLeaf),1000),1);
randPCNames = intersectPC(randperm(height(intersectPC),1000),1);
randNames = {randLeafNames,randPCNames};
randNames_H = randNames;
% Get _H versions for both of the above
for k = 1:2
    for kk = 1:length(randNames{k}.filename)
        CHECK = strsplit(string(randNames{k}.filename{kk}),"_");
        if CHECK{1} == "COLO"
            NEW = [string(randNames{k}.filename{kk}),"_H"];
            NEW = strjoin(NEW,"");
            randNames_H{k}.filename{kk} = char(NEW);
        else
            randNames_H{k}.filename{kk} = char(randNames{k}.filename{kk});
        end
    end
end

randLeafLR3 = randNames{1};
randLeafFR3 = randNames_H{1};
randPCLR3 = randNames{2};
randPCFR3 = randNames_H{2};

ALL_RAND = {randLeafLR3,randLeafFR3,randPCLR3,randPCFR3};

% Load these on second run, when trying to copy and move the images.
writetable(randLeafLR3,"D:\Dropbox\ML_Project\Image_Database\LeafMachine_Validation_Images\Manuscript_Vouchers\QC_Overlay\Random1000matching_Leaf_LR.xlsx")
writetable(randLeafFR3,"D:\Dropbox\ML_Project\Image_Database\LeafMachine_Validation_Images\Manuscript_Vouchers\QC_Overlay\Random1000matching_Leaf_FR.xlsx")
writetable(randPCLR3,"D:\Dropbox\ML_Project\Image_Database\LeafMachine_Validation_Images\Manuscript_Vouchers\QC_Overlay\Random1000matching_PartialClump_LR.xlsx")
writetable(randPCFR3,"D:\Dropbox\ML_Project\Image_Database\LeafMachine_Validation_Images\Manuscript_Vouchers\QC_Overlay\Random1000matching_PartialClump_FR.xlsx");

% To reload....
randLeafLR3 = readtable("D:\Dropbox\ML_Project\Image_Database\LeafMachine_Validation_Images\Manuscript_Vouchers\QC_Overlay\Random1000matching_Leaf_LR.xlsx");
randLeafFR3 = readtable("D:\Dropbox\ML_Project\Image_Database\LeafMachine_Validation_Images\Manuscript_Vouchers\QC_Overlay\Random1000matching_Leaf_FR.xlsx");
randPCLR3 = readtable("D:\Dropbox\ML_Project\Image_Database\LeafMachine_Validation_Images\Manuscript_Vouchers\QC_Overlay\Random1000matching_PartialClump_LR.xlsx");
randPCFR3 = readtable("D:\Dropbox\ML_Project\Image_Database\LeafMachine_Validation_Images\Manuscript_Vouchers\QC_Overlay\Random1000matching_PartialClump_FR.xlsx");
ALL_RAND = {randLeafLR3,randLeafFR3,randPCLR3,randPCFR3};



%% Second run
% Import LM ouput files
lr_herbs = readtable("D:\Dropbox\ML_Project\Image_Database\LeafMachine_Validation_Images\Manuscript_Vouchers\LeafMachine_Batch__08-23-2019_02-42__FINAL_COLOlr_Rhodeslr.xlsx");
fr_herbs = readtable("D:\Dropbox\ML_Project\Image_Database\LeafMachine_Validation_Images\Manuscript_Vouchers\LeafMachine_Batch__08-24-2019_03-19__FINAL_COLOhr_Rhodeshr.xlsx");

lrfr_herbs = {lr_herbs,fr_herbs};

% Iterate through Rhodes LR, Rhodes FR, COLO
for i = 1:2
    herb = lrfr_herbs{i};  
    for ii = 1:4
        if (mod(ii,2)==0)
            dirOverlay = dirPaths{2};
            dirCopy = dirOverlay(1,1).folder;
            dirOverlayNames = {};

            for m = 1:length(dirOverlay)
                fName = strsplit(dirOverlay(m,1).name,"_Overlay.jpg");
                dirOverlayNames{m,1} = fName{1};
            end
        else
            dirOverlay = dirPaths{1};
            dirCopy = dirOverlay(1,1).folder;
            dirOverlayNames = {};

            for m = 1:length(dirOverlay)
                fName = strsplit(dirOverlay(m,1).name,"_Overlay.jpg");
                dirOverlayNames{m,1} = fName{1};
            end
        end
        
        dirOut = dirOUTS{ii};
        RAND1000 = ALL_RAND{ii};
        LLL = length(herb.filename);
        
        completedFilesnames = {};
        CCC = 1;
        completedFilesnames2 = {};
        CCC2 = 1;
        
        for j = 1:LLL
            if ismember(herb.filename{j},RAND1000.filename) % toggle this 
                fprintf('ii = %.4f i = %.4f \n', ii, i) 
                fprintf('j = %.4f LLL = %.4f \n', j, LLL) 
                if ~(herb.SVMprediction{j} == "NA")
                    if (herb.SVMprediction{j} == "Leaf")
                        if ismember(upper(herb.family{j}),families) % leaf found, correct family
                            sprintf(upper(herb.family{j}))
                            if ismember(herb.filename{j},dirOverlayNames(:,1))
                                % add to positive table
                                Positive_Leaf_Out = [Positive_Leaf_Out;herb(j,:)];

                                % copy overlay to new folder
                                fName = strjoin([herb.filename{j},"_Overlay.jpg"],"");
                                if ~ismember(herb.filename{j},completedFilesnames)
                                    imCopy = imread(fullfile(dirCopy,fName));
                                    imwrite(imCopy,fullfile(dirOut,fName))
                                    completedFilesnames{CCC} = herb.filename{j};
                                    CCC = CCC + 1;
                                end
                            end
                        end % end family check
                    else % for SVMprediction == "LeafPartial" || "clump"
                        if ismember(upper(herb.family{j}),families) % leaf found, correct family
                            sprintf(upper(herb.family{j}))
                            if ismember(herb.filename{j},dirOverlayNames(:,1))
                                % add to positive table
                                PartialClump_Out = [PartialClump_Out;herb(j,:)];

                                % copy overlay to new folder
                                fName = strjoin([herb.filename{j},"_Overlay.jpg"],"");
                                if ~ismember(herb.filename{j},completedFilesnames2)
                                    imCopy = imread(fullfile(dirCopy,fName));
                                    imwrite(imCopy,fullfile(dirOut,fName))
                                    completedFilesnames2{CCC2} = herb.filename{j};
                                    CCC2 = CCC2 + 1;
                                end
                            end
                        end
                    end % end leaf check
                elseif (herb.SVMprediction{j} == "NA") % if SVMpred == NA
                    NA_Out = [NA_Out;herb(j,:)];
                end % end NA check
            end % toggle for running only the rand1000 set
        end % end single herb
    end % ii for looping through dir OUT
end % end herb list

writetable(Positive_Leaf_Out,"D:\Dropbox\ML_Project\Image_Database\LeafMachine_Validation_Images\Manuscript_Vouchers\QC_Overlay\Rand1000matching_Leaf_Positive.xlsx")
writetable(PartialClump_Out,"D:\Dropbox\ML_Project\Image_Database\LeafMachine_Validation_Images\Manuscript_Vouchers\QC_Overlay\Rand1000matching_PartialClump.xlsx")

%%
dirTEST = dir("D:\Dropbox\ML_Project\Image_Database\LeafMachine_Validation_Images\Manuscript_Vouchers\QC_Overlay\PartialClump_LR");
dirTEST = dirTEST(~ismember({dirTEST.name},{'.','..'}));
DIFF = struct2table(dirTEST);

headers = {'filename'};
data = cell(1000,length(headers));
DIFFNEW = cell2table(data);
DIFFNEW.Properties.VariableNames = headers;


for i = 1 : length(DIFF.name)
     NEW = strsplit(DIFF.name{i},"_Overlay");
     DIFF.name{i} = char(NEW{1});
end


    
MISSING = setdiff(sort(randPCLR3.filename),sort(DIFF.name));