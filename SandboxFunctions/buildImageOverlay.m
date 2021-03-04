%%%     Merge all found features and plot over original image
%%%
%%%     Developed for LeafMachine.org
%%%
%%%     William Weaver
%%%     University of Colorado, Boulder
%%%     Department of Ecology and Evolutionary Biology

function buildImageOverlay(img,n,measurements,colors,destinationDirectory,filename)
    % Extract measurements
    % measurements ==> {cleanLeaf_Area,cleanLeaf_Perimeter,cleanLeaf_PerimeterOverlay,cleanLeaf_Centroid};

    % Plot Text
%     for P = 1:n
%         T = ['Leaf(',num2str(P),')','A:',num2str(measurements{P}{1}),'-','P:',num2str(measurements{P}{2})];
%         img = insertText(img,measurements{P}{4},T,'FontSize',20,'BoxColor','white','BoxOpacity',0.5,'TextColor',colors{P});
%     end

    % Plot features for export
    imgOverlay = figure;
    set(imgOverlay, 'Visible', 'off');
    imshow(img)
    hold on
    for P = 1:n
        scatter(measurements{P}{3}(:,1),measurements{P}{3}(:,2),2,colors{P});
    end
    hold off
    print(imgOverlay,fullfile(destinationDirectory,filename),'-dpng','-r500'); 
    delete(imgOverlay);
    %saveas(imgOverlay,fullfile(destinationDirectory,filename))
    
    
end



