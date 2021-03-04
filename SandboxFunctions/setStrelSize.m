%%%     Build blank data file for export
%%%
%%%     Developed for LeafMachine.org
%%%
%%%     William Weaver
%%%     University of Colorado, Boulder
%%%     Department of Ecology and Evolutionary Biology

function SE = setStrelSize(r,n)
%     r = 30;
%     n = 4;
    SE1 = strel('diamond',r);
    SE2 = strel('disk',r,n);
    SE3 = strel('octagon',r);
    SE4 = strel('line',r,0);%Long leaves
    SE5 = strel('line',r,45);%Long leaves
    SE6 = strel('line',r,90);%Long leaves
    SE7 = strel('line',r,135);%Long leaves
    SE = {SE1,SE2,SE3,SE4,SE5,SE6,SE7};
end