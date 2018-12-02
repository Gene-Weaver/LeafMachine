%%%     Measure leaf features
%%%
%%%     Developed for LeafMachine.org
%%%
%%%     William Weaver
%%%     University of Colorado, Boulder
%%%     Department of Ecology and Evolutionary Biology

function measurements = measureLeafFeatures(cleanLeaf,bound2)
    % Get area
    cleanLeaf_Area = bwarea(cleanLeaf);
    % Get Perimeter
    [rowsP, columnsP] = find(bwperim(cleanLeaf));
    cleanLeaf_Perimeter = struct2array(regionprops(cleanLeaf,'Perimeter'));
    cleanLeaf_Centroid = struct2array(regionprops(cleanLeaf,'Centroid'));
    cleanLeaf_Centroid = [cleanLeaf_Centroid(1,1)+bound2(1),cleanLeaf_Centroid(1,2)+bound2(2)];
    cleanLeaf_PerimeterOverlay = [columnsP+bound2(1),rowsP+bound2(2)];
    
    measurements = {cleanLeaf_Area,cleanLeaf_Perimeter,cleanLeaf_PerimeterOverlay,cleanLeaf_Centroid};
end