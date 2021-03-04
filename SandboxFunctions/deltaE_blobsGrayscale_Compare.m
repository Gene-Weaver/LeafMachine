function [deltaE,meanA,meanB] = deltaE_blobsGrayscale_Compare(imgA,meanB) % b is meant to be the Background
    % Get means of first image
    meanA = mean2(imgA(:,:,1));

    deltaE = abs(double(meanA) - double(meanB));

end