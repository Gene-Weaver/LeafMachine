%%%     Measure leaf features
%%%
%%%     Developed for LeafMachine.org
%%%
%%%     William Weaver
%%%     University of Colorado, Boulder
%%%     Department of Ecology and Evolutionary Biology

function measurements = measureLeafFeatures(cleanLeaf,bound2)
    headers = {'cleanLeaf_Area','cleanLeaf_Perimeter','cleanLeaf_PerimeterOverlay','cleanLeaf_Centroid'};
    data = cell(1,4);
    measurements = cell2table(data);
    measurements.Properties.VariableNames = headers;
    
    % Get area
    measurements.cleanLeaf_Area{1} = bwarea(cleanLeaf);
    % Get Perimeter
    [rowsP, columnsP] = find(bwperim(cleanLeaf));
    measurements.cleanLeaf_Perimeter{1} = struct2array(regionprops(cleanLeaf,'Perimeter'));
    cleanLeaf_Centroid = struct2array(regionprops(cleanLeaf,'Centroid'));
    measurements.cleanLeaf_Centroid{1} = [cleanLeaf_Centroid(1,1)+bound2(1),cleanLeaf_Centroid(1,2)+bound2(2)];
    measurements.cleanLeaf_PerimeterOverlay{1} = [columnsP+bound2(1),rowsP+bound2(2)];
    
    %measurements = {cleanLeaf_Area,cleanLeaf_Perimeter,cleanLeaf_PerimeterOverlay,cleanLeaf_Centroid};
end