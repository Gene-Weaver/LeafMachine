function [Binary,GradMag,Iobrcbr,BinaryCorrected] = ImagePreProcessing(Image)
[~,~,d] = size(Image);
if d>1
    Image = rgb2gray(Image);
end
Binary = imbinarize(Image);
hy = fspecial('sobel');
hx = hy';
Iy = imfilter(double(Image), hy, 'replicate');
Ix = imfilter(double(Image), hx, 'replicate');
GradMag = sqrt(Ix.^2 + Iy.^2); % Visualize dendritic structure, some leaf outline based on gradient magnitude
%GradMag = imcomplement(GradMag)
% Steps to eliminate pixel-sixed holes in binary image
se = strel('disk', 10);
Ie = imerode(Image, se);
Iobr = imreconstruct(Ie, Image);
Iobrd = imdilate(Iobr, se);
Iobrcbr = imreconstruct(imcomplement(Iobrd), imcomplement(Iobr));
Iobrcbr = imcomplement(Iobrcbr); %Pixel-sezed holes are filled and smoothed retaining original shape
BinaryCorrected = imbinarize(Iobrcbr);

%ImOut = {Binary,GradMag,Iobrcbr,BinaryCorrected};
end