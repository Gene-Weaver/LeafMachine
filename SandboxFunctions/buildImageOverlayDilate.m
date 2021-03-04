%%%     Merge all found features and plot over original image
%%%
%%%     Developed for LeafMachine.org
%%%
%%%     William Weaver
%%%     University of Colorado, Boulder
%%%     Department of Ecology and Evolutionary Biology

function buildImageOverlayDilate(img,mp,n,measurements,colors,destinationDirectory,filename,quality)
    for P = 1:n % iterate through found objects
        % Plot original outline
        [m,mm,~] = size(img);
        blankMask = zeros(m,mm);
        for i = 1:length(measurements{P}.cleanLeaf_PerimeterOverlay{1}(:,1))
            blankMask(round(measurements{P}.cleanLeaf_PerimeterOverlay{1}(i,2)),round(measurements{P}.cleanLeaf_PerimeterOverlay{1}(i,1))) = 255;
        end
        % Grow border through dilation and locate new coordinates 
        % Probably can be simplified by just dividing mp by 2 for larger
        % images 
        if (0 <= mp) && (mp < 2.5)
            [row,col] = ind2sub(size(img),find(imdilate(blankMask,strel('disk',3,0))));
        elseif (2.5 <= mp) && (mp < 10)
            [row,col] = ind2sub(size(img),find(imdilate(blankMask,strel('disk',5,0))));
        elseif (10 <= mp) && (mp < 20)
            [row,col] = ind2sub(size(img),find(imdilate(blankMask,strel('disk',9,0))));
        elseif (20 <= mp) && (mp < 30)
            [row,col] = ind2sub(size(img),find(imdilate(blankMask,strel('disk',12,0))));
        elseif (30 <= mp) && (mp < 40)
            [row,col] = ind2sub(size(img),find(imdilate(blankMask,strel('disk',20,0))));
        else
            [row,col] = ind2sub(size(img),find(imdilate(blankMask,strel('disk',30,0))));
        end
        % Add color
        for i = 1:length(row)
            img(row(i,1),col(i,1),1) = 255*colors{P}(1,1);
            img(row(i,1),col(i,1),2) = 255*colors{P}(1,2);
            img(row(i,1),col(i,1),3) = 255*colors{P}(1,3);
        end
    end
    % Save
    if quality == "High"
        filename2 = char(strcat(filename,'.png'));
        imwrite(img,fullfile(destinationDirectory,filename2),'BitDepth',16);
    else
        filename2 = char(strcat(filename,'.jpg'));
        imwrite(img,fullfile(destinationDirectory,filename2));
    end
end



