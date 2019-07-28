%%% Dynamic Crop:
% Divide all training and validation images and masks into 360 x 360
% subsections. Start at origin, move right 180 pxs, repeat, end with
% difference on right hand side so whole image of any size is covered. Then
% repeat 180 pixels down, whole row, etc. 

% Largest(ish) Image:
% 6879 x 9893 ==> 
% 360-540-720-900-1080-1260-1440-1620-1800-1980-2160-2340

function imgCropNames = dynamicCrop(fNameFull,setName) 

    % Setup
    img = imread(fNameFull);
    [dimRows,dimCols,~] = size(img);
    %Parse fName
    parts = strsplit(fNameFull,'\');
    fName = parts{length(parts)};
    newFolder = {parts{length(parts)-1},'__dynamicCrop','_',setName};
    newFolder = strjoin(newFolder,'');
    fName2 = strsplit(fName,'.');
    fNamePre = fName2{1}
    fNameSuffix = fName2{2};
    mkNewFolder = {fullfile(parts{1:(length(parts)-2)}),'\',newFolder};
    mkNewFolder = strjoin(mkNewFolder,'');
    if ~exist(mkNewFolder, 'dir')
        mkdir(mkNewFolder)
    end
    
    % Get dims
    nBlocksRows = ceil(dimRows/180);
    nBlocksCols = ceil(dimCols/180);
    maxDimRows = 180*nBlocksRows;
    maxDimCols = 180*nBlocksCols;

    boundsRows_Floor = (maxDimRows - 180);
    boundsCols_Floor = (maxDimCols - 180);
    boundsRows_ShiftUp = dimRows - boundsRows_Floor;
    boundsCols_ShiftUp = dimCols - boundsCols_Floor;
    boundsRows_ShiftDn = 360 - boundsRows_ShiftUp;
    boundsCols_ShiftDn = 360 - boundsCols_ShiftUp;

    boundsRows_MaxDn = boundsRows_Floor - boundsRows_ShiftDn;
    boundsCols_MaxDn = boundsCols_Floor - boundsCols_ShiftDn;

    headers = {'Filenames'};
    data = cell(1,1);
    imgCropNames = cell2table(data);
    imgCropNames.Properties.VariableNames = headers;
    
    idx = 1;
    % Col
    for col = 2:nBlocksCols
        % Row
        for row = 2:nBlocksRows
            %Bottom right corner, very last crop
            if ((1+(180*(col-2)) + 179) >= boundsCols_Floor) && ((1+(180*(row-2)) + 179) >= boundsRows_Floor)
                imgCrop = imcrop(img,[boundsCols_MaxDn boundsRows_MaxDn  359 359]);
                % Save crop
                fNameNew = {fullfile(parts{1:(length(parts)-2)}),'\',newFolder,'\',fNamePre,'__c',int2str(col-1),'__r',int2str(row-1),'__idx',int2str(idx),'.',fNameSuffix};
                fNameNew = strjoin(fNameNew,'');
                imwrite(imgCrop,fNameNew)
                imgCropNames.Filenames{idx} = fNameNew;
                idx = idx + 1;
            else
                if (1+(180*(row-2)) + 179) >= boundsRows_Floor % The last top to bottom crop
                    imgCrop = imcrop(img,[(1+(180*(col-2))) boundsRows_MaxDn 359 359]);
                    % Save crop
                    fNameNew = {fullfile(parts{1:(length(parts)-2)}),'\',newFolder,'\',fNamePre,'__c',int2str(col-1),'__r',int2str(row-1),'__idx',int2str(idx),'.',fNameSuffix};
                    fNameNew = strjoin(fNameNew,'');
                    imwrite(imgCrop,fNameNew)
                    imgCropNames.Filenames{idx} = fNameNew;
                    idx = idx + 1;
                elseif (1+(180*(col-2)) + 179) >= boundsCols_Floor % The last laft to right crop
                    imgCrop = imcrop(img,[boundsCols_MaxDn (1+(180*(row-2))) 359 359]);
                    % Save crop
                    fNameNew = {fullfile(parts{1:(length(parts)-2)}),'\',newFolder,'\',fNamePre,'__c',int2str(col-1),'__r',int2str(row-1),'__idx',int2str(idx),'.',fNameSuffix};
                    fNameNew = strjoin(fNameNew,'');
                    imwrite(imgCrop,fNameNew)
                    imgCropNames.Filenames{idx} = fNameNew;
                    idx = idx + 1;
                else % The typical crop
                    imgCrop = imcrop(img,[(1+(180*(col-2))) (1+(180*(row-2))) 359 359]);
                    % Save crop
                    fNameNew = {fullfile(parts{1:(length(parts)-2)}),'\',newFolder,'\',fNamePre,'__c',int2str(col-1),'__r',int2str(row-1),'__idx',int2str(idx),'.',fNameSuffix};
                    fNameNew = strjoin(fNameNew,'');
                    imwrite(imgCrop,fNameNew)
                    imgCropNames.Filenames{idx} = fNameNew;
                    idx = idx + 1;
                end
            end
        end
    end
end

