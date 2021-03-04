%%%     Build SVM dataset - modified to run on one image inside
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

function tableOut = buildSVMdataset_oneImage(img,family,megapixels)
%     Original SVM
%     headers = {'area','bbRatio','majorAxisLen','minorAxisLen','eccentricity','eqDiameter','extent','roundness','perimeter'};
%     data = cell(1,9);
%     tableOut = cell2table(data);
%     tableOut.Properties.VariableNames = headers;
    
    headers = {'family','megapixels','area','bbRatio','majorAxisLen','minorAxisLen','eccentricity','eqDiameter','extent','roundness','perimeter'};
    data = cell(1,length(headers));
    tableOut = cell2table(data);
    tableOut.Properties.VariableNames = headers;

    % Process binary img
    img = bwareafilt(img,1);
    img = imfill(img,'holes');
    values = regionprops(img,'Area','BoundingBox','MajorAxisLength','MinorAxisLength','Eccentricity','EquivDiameter','Extent','Perimeter');

    % Save values
    try 
        tableOut.family{1} = family;
        tableOut.megapixels{1} = megapixels;
        tableOut.area{1} = values.Area;
        tableOut.bbRatio{1} = values.BoundingBox(3)/values.BoundingBox(4);
        tableOut.majorAxisLen{1} = values.MajorAxisLength;
        tableOut.minorAxisLen{1} = values.MinorAxisLength;
        tableOut.eccentricity{1} = values.Eccentricity;
        tableOut.eqDiameter{1} = values.EquivDiameter;
        tableOut.extent{1} = values.Extent;
        tableOut.roundness{1} = (values.Perimeter .^ 2) ./ (4 * pi * values.Area);
        tableOut.perimeter{1} = values.Perimeter;
    catch
        tableOut = [];
    end
    
    % Format table
	if ~isempty(tableOut)
        tableOut.(1) = cell2mat(tableOut.family(1));
        for i = 2:width(tableOut)
            if iscell(tableOut.(i))
                tableOut.(i) = cell2mat(tableOut.(i)); 
            end 
        end
    end
end