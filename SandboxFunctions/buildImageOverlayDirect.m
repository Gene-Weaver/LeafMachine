%%%     Merge all found features and plot over original image
%%%
%%%     Developed for LeafMachine.org
%%%
%%%     William Weaver
%%%     University of Colorado, Boulder
%%%     Department of Ecology and Evolutionary Biology

function buildImageOverlayDirect(img,n,measurements,colors,destinationDirectory,filename,quality)
    % Extract measurements
    % measurements ==> {cleanLeaf_Area,cleanLeaf_Perimeter,cleanLeaf_PerimeterOverlay,cleanLeaf_Centroid};

    % Plot Text
%     for P = 1:n
%         T = ['Leaf(',num2str(P),')','A:',num2str(measurements{P}{1}),'-','P:',num2str(measurements{P}{2})];
%         img = insertText(img,measurements{P}{4},T,'FontSize',20,'BoxColor','white','BoxOpacity',0.5,'TextColor',colors{P});
%     end

    % Plot features for export
%     [m,mm,~] = size(img);
%     blankMask = zeros(m,mm);
%     blankMask3 =blankMask;
%     
%     for k = 1:length(measurements{P}.cleanLeaf_PerimeterOverlay{1}(:,1))
%         blankMask3(measurements{1}.cleanLeaf_PerimeterOverlay{1}(k,2),measurements{1}.cleanLeaf_PerimeterOverlay{1}(k,1)) = 255;
%     end
%     idx = imdilate(blankMask3,strel('disk',1,0));
%     blankMask(measurements{1}.cleanLeaf_PerimeterOverlay{1}(:,2),measurements{1}.cleanLeaf_PerimeterOverlay{1}(:,1)) = 255;
%     blankMask2 = uint8(repmat(idx,[1 1 3]));
%     figure();imshow(blankMask2);
    
    for P = 1:n
        for i = 1:length(measurements{P}.cleanLeaf_PerimeterOverlay{1}(:,1))
            img = thickenLine(img,measurements,colors,P,i,0,0);
%             img(measurements{P}{3}(i,2),measurements{P}{3}(i,1),1) = 255*colors{P}(1,1);
%             img(measurements{P}{3}(i,2),measurements{P}{3}(i,1),2) = 255*colors{P}(1,2);
%             img(measurements{P}{3}(i,2),measurements{P}{3}(i,1),3) = 255*colors{P}(1,3);

            img = thickenLine(img,measurements,colors,P,i,1,0);
%             img(measurements{P}{3}(i,2)+1,measurements{P}{3}(i,1),1) = 255*colors{P}(1,1);
%             img(measurements{P}{3}(i,2)+1,measurements{P}{3}(i,1),2) = 255*colors{P}(1,2);
%             img(measurements{P}{3}(i,2)+1,measurements{P}{3}(i,1),3) = 255*colors{P}(1,3);

            img = thickenLine(img,measurements,colors,P,i,0,1);
%             img(measurements{P}{3}(i,2),measurements{P}{3}(i,1)+1,1) = 255*colors{P}(1,1);
%             img(measurements{P}{3}(i,2),measurements{P}{3}(i,1)+1,2) = 255*colors{P}(1,2);
%             img(measurements{P}{3}(i,2),measurements{P}{3}(i,1)+1,3) = 255*colors{P}(1,3);
            
            img = thickenLine(img,measurements,colors,P,i,1,1);
%             img(measurements{P}{3}(i,2)+1,measurements{P}{3}(i,1)+1,1) = 255*colors{P}(1,1);
%             img(measurements{P}{3}(i,2)+1,measurements{P}{3}(i,1)+1,2) = 255*colors{P}(1,2);
%             img(measurements{P}{3}(i,2)+1,measurements{P}{3}(i,1)+1,3) = 255*colors{P}(1,3);

            img = thickenLine(img,measurements,colors,P,i,-1,0);
%             img(measurements{P}{3}(i,2)-1,measurements{P}{3}(i,1),1) = 255*colors{P}(1,1);
%             img(measurements{P}{3}(i,2)-1,measurements{P}{3}(i,1),2) = 255*colors{P}(1,2);
%             img(measurements{P}{3}(i,2)-1,measurements{P}{3}(i,1),3) = 255*colors{P}(1,3);
            
            img = thickenLine(img,measurements,colors,P,i,0,-1);
%             img(measurements{P}{3}(i,2),measurements{P}{3}(i,1)-1,1) = 255*colors{P}(1,1);
%             img(measurements{P}{3}(i,2),measurements{P}{3}(i,1)-1,2) = 255*colors{P}(1,2);
%             img(measurements{P}{3}(i,2),measurements{P}{3}(i,1)-1,3) = 255*colors{P}(1,3);
            
            img = thickenLine(img,measurements,colors,P,i,-1,-1);
%             img(measurements{P}{3}(i,2)-1,measurements{P}{3}(i,1)-1,1) = 255*colors{P}(1,1);
%             img(measurements{P}{3}(i,2)-1,measurements{P}{3}(i,1)-1,2) = 255*colors{P}(1,2);
%             img(measurements{P}{3}(i,2)-1,measurements{P}{3}(i,1)-1,3) = 255*colors{P}(1,3);

            img = thickenLine(img,measurements,colors,P,i,-1,1);
%             img(measurements{P}{3}(i,2)-1,measurements{P}{3}(i,1)+1,1) = 255*colors{P}(1,1);
%             img(measurements{P}{3}(i,2)-1,measurements{P}{3}(i,1)+1,2) = 255*colors{P}(1,2);
%             img(measurements{P}{3}(i,2)-1,measurements{P}{3}(i,1)+1,3) = 255*colors{P}(1,3);

            img = thickenLine(img,measurements,colors,P,i,1,-1);
%             img(measurements{P}{3}(i,2)+1,measurements{P}{3}(i,1)-1,1) = 255*colors{P}(1,1);
%             img(measurements{P}{3}(i,2)+1,measurements{P}{3}(i,1)-1,2) = 255*colors{P}(1,2);
%             img(measurements{P}{3}(i,2)+1,measurements{P}{3}(i,1)-1,3) = 255*colors{P}(1,3);
        end
    end
    if quality == "High"
        filename2 = char(strcat(filename,'.png'));
        imwrite(img,fullfile(destinationDirectory,filename2),'BitDepth',16);
    else
        filename2 = char(strcat(filename,'.jpg'));
        imwrite(img,fullfile(destinationDirectory,filename2));
    end


%     imgNew = img;
%     k = sub2ind(size(imgNew),measurements{P}{3}(:,1),measurements{P}{3}(:,2));
%     k2 = transpose(k);
%     RGB = insertShape(imgNew,'Line',k2,'Color','black','LineWidth',3,'SmoothEdges',false);
%     figure()
%     imshow(RGB)
end



