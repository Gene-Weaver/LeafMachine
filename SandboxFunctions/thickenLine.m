%%%     Thicken line segment for fcn: buildImageOverlayDirect()
%%%     Developed for LeafMachine.org
%%%
%%%     William Weaver
%%%     University of Colorado, Boulder
%%%     Department of Ecology and Evolutionary Biology


function img = thickenLine(img,measurements,colors,P,i,shift1,shift2)
    try %measurements{P}.cleanLeaf_PerimeterOverlay{1}(:,1)
        img(measurements{P}.cleanLeaf_PerimeterOverlay{1}(i,2)+shift1,measurements{P}.cleanLeaf_PerimeterOverlay{1}(i,1)+shift2,1) = 255*colors{P}(1,1);
        img(measurements{P}.cleanLeaf_PerimeterOverlay{1}(i,2)+shift1,measurements{P}.cleanLeaf_PerimeterOverlay{1}(i,1)+shift2,2) = 255*colors{P}(1,2);
        img(measurements{P}.cleanLeaf_PerimeterOverlay{1}(i,2)+shift1,measurements{P}.cleanLeaf_PerimeterOverlay{1}(i,1)+shift2,3) = 255*colors{P}(1,3);
    catch
    end
end