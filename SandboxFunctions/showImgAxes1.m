%%%     Build blank data file for export
%%%
%%%     Developed for LeafMachine.org
%%%
%%%     William Weaver
%%%     University of Colorado, Boulder
%%%     Department of Ecology and Evolutionary Biology

function showImgAxes1(show,handles,hObject,imgOut)
    if show == "show"
        axes(handles.axes1)
        imshow(imgOut)
    end
    guidata(hObject, handles);
end