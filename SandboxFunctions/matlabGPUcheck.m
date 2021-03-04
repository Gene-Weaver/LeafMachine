% This function was recommended by Matlab staff. Some odd errors occured on
% certain Nvidia GPUs, this code pre-initializes a portion of a CNN
% allowing CNNs to function when called.

function matlabGPUcheck()

try
    try
        nnet.internal.cnngpu.reluForward(gpuArray(0));
    catch
        nnet.internal.cnngpu.reluForward(gpuArray(0));
    end
catch
end