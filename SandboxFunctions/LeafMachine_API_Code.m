%%% LeafMachine API -- Single Image
function [imageIn,imageOut,nLeaves,time] = LeafMachine_API_Code(ID,DwC_Images,DwC_Occurences)




[nFiles,BatchTime] = LeafMachineBatchSegmentation_API(...
    handles.dirOpen,...
    handles.dirOpen2,...
    handles.segOpts,...
    handles.LeafMachine_SegNet_v1,...
    handles.SVM,...
    5,...
    feature,...
    'cpu',...
    'url',...
    "goodQualityAccessURI",...
    'High',...
    handles.filesSuffix,...
    handles.dirSave_wSuffix,...
    handles,hObject);