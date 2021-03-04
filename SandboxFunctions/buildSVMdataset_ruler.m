%%%     SVM check for ruler blobs
%%%
%%%     Developed for LeafMachine.org
%%%
%%%     William Weaver
%%%     University of Colorado, Boulder
%%%     Department of Ecology and Evolutionary Biology

function parametersRuler = buildSVMdataset_ruler(img)
    headers = {'id','class','area','areaI','majorAxisLen','majorAxisLenI','minorAxisLen','minorAxisLenI',...
    'eccentricity','eccentricityI','eqDiameter','eqDiameterI','count','countI','avgBbox','avgBboxI'};
    data = cell(1,16);
    parametersRuler = cell2table(data);
    parametersRuler.Properties.VariableNames = headers;
    
    % Process binary img
    values = regionprops(imcomplement(img),'Area','BoundingBox','MajorAxisLength','MinorAxisLength','Eccentricity','EquivDiameter');
    valuesInverted = regionprops(img,'Area','BoundingBox','MajorAxisLength','MinorAxisLength','Eccentricity','EquivDiameter');

    BB = [];
    BBi = [];
    for i = 1 : length(values)
        BB{i} = values(i).BoundingBox(3)/values(i).BoundingBox(4);
    end
    for i = 1 : length(valuesInverted)
        BBi{i} = valuesInverted(i).BoundingBox(3)/valuesInverted(i).BoundingBox(4);
    end
    BB = cell2mat(BB);
    BBi = cell2mat(BBi);

    % Save values
    try 
        % Save values
        n = strsplit(imgFiles(k).name,'.');
        nn = strsplit(imgFiles(k).name,'__');
        parametersRuler.id{k} = n(1);
        parametersRuler.class{k} = nn(1);
        parametersRuler.area{k} = nanmean([values.Area]);
        parametersRuler.majorAxisLen{k} = nanmean([values.MajorAxisLength]);
        parametersRuler.minorAxisLen{k} = nanmean([values.MinorAxisLength]);
        parametersRuler.eccentricity{k} = nanmean([values.Eccentricity]);
        parametersRuler.eqDiameter{k} = nanmean([values.EquivDiameter]);
        parametersRuler.avgBbox{k} = harmmean(BB, 'omitnan');
        parametersRuler.count{k} = length(values);

        parametersRuler.areaI{k} = nanmean([valuesInverted.Area]);
        parametersRuler.majorAxisLenI{k} = nanmean([valuesInverted.MajorAxisLength]);
        parametersRuler.minorAxisLenI{k} = nanmean([valuesInverted.MinorAxisLength]);
        parametersRuler.eccentricityI{k} = nanmean([valuesInverted.Eccentricity]);
        parametersRuler.eqDiameterI{k} = nanmean([valuesInverted.EquivDiameter]);
        parametersRuler.avgBboxI{k} = harmmean(BBi, 'omitnan');
        parametersRuler.countI{k} = length(valuesInverted);
    catch
        parametersRuler = [];
    end
    
    % Format table
	if ~isempty(parametersRuler) 
        for i = 1:width(parametersRuler), if iscell(parametersRuler.(i)), parametersRuler.(i) = cell2mat(parametersRuler.(i)); end, end
    end
end