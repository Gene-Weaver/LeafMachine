%%%     Build SVM dataset - BATCH
%%%     "runLazySnappingforBlobs.m"
%%%
%%%     Developed for LeafMachine.org
%%%
%%%     William Weaver
%%%     University of Colorado, Boulder
%%%     Department of Ecology and Evolutionary Biology

% Bag Classification Using Support Vector Machines
% Uri Kartoun, Helman Stern, Yael Edan
% https://scholar.harvard.edu/files/kartoun/files/1ca003_225e1f90fc02d788a6a390665a58091b.pdf

% Open folders, rename each image, store new name as entry in table,
% calculate Area, BBox Ratio, Major Axis Length, Minor Axis
% Length, Eccentricity, Equivalent Diameter, Extent, Roundness, Convex Perimeter

function tableOut = buildSVMdataset_multImages(imgArray,family,megapixels)
%     Original SVM
%     headers = {'area','bbRatio','majorAxisLen','minorAxisLen','eccentricity','eqDiameter','extent','roundness','perimeter'};
%     data = cell(1,9);
%     tableOut = cell2table(data);
%     tableOut.Properties.VariableNames = headers;
    nImg = length(imgArray);
    
    headers = {'family','megapixels','area','bbRatio','majorAxisLen','minorAxisLen','eccentricity','eqDiameter','extent','roundness','perimeter'};
    data = cell(nImg,length(headers));
    tableOut = cell2table(data);
    tableOut.Properties.VariableNames = headers;

    % Process binary img
    try
        
        for i = 1:nImg
            img = bwareafilt(imgArray{i},1);
            img = imfill(img,'holes');
            values = regionprops(img,'Area','BoundingBox','MajorAxisLength','MinorAxisLength','Eccentricity','EquivDiameter','Extent','Perimeter');
            try 
                tableOut.family{i} = family;
                tableOut.megapixels{i} = megapixels;
                tableOut.area{i} = values.Area;
                tableOut.bbRatio{i} = values.BoundingBox(3)/values.BoundingBox(4);
                tableOut.majorAxisLen{i} = values.MajorAxisLength;
                tableOut.minorAxisLen{i} = values.MinorAxisLength;
                tableOut.eccentricity{i} = values.Eccentricity;
                tableOut.eqDiameter{i} = values.EquivDiameter;
                tableOut.extent{i} = values.Extent;
                tableOut.roundness{i} = (values.Perimeter .^ 2) ./ (4 * pi * values.Area);
                tableOut.perimeter{i} = values.Perimeter;
            catch
                tableOut.family{i} = [];
                tableOut.megapixels{i} = [];
                tableOut.area{i} = [];
                tableOut.bbRatio{i} = [];
                tableOut.majorAxisLen{i} = [];
                tableOut.minorAxisLen{i} = [];
                tableOut.eccentricity{i} = [];
                tableOut.eqDiameter{i} = [];
                tableOut.extent{i} = [];
                tableOut.roundness{i} = [];
                tableOut.perimeter{i} = [];
            end
        end
    catch
        tableOut = [];
    end
    
    % Save values
    
    
    % Format table
	if ~isempty(tableOut)
        for j = 1:nImg
            tableOut.family{j} = cell2mat(tableOut.family(j));
            for i = 2:width(tableOut)
                if iscell(tableOut.(i))
                    tableOut.(i) = cell2mat(tableOut.(i));  
                end 
            end
        end
    end
end