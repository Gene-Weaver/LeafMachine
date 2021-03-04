function [deltaE,meanA,meanB] = deltaE_blobsGrayscale(imgA,imgB)
    % Get means of first image
    meanA = mean2(imgA(:,:,1));

    % Get means of second image
    meanB = mean2(imgB(:,:,1));
    
    deltaE = abs(double(meanA) - double(meanB));
    
   
end