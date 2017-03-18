function myHistogram

clear all, close all;
img1 = imread('C:\Users\baser\Documents\MATLAB\imageProc\imgSource\polen1.tif');
img2 = imread('C:\Users\baser\Documents\MATLAB\imageProc\imgSource\polen2.tif');
img3 = imread('C:\Users\baser\Documents\MATLAB\imageProc\imgSource\polen3.tif');
img4 = imread('C:\Users\baser\Documents\MATLAB\imageProc\imgSource\polen4.tif');

[x, y, z] = size(img1);         %first image sizes
numPixel1 = x * y;
[x, y, z] = size(img1);         %second image sizes
numPixel2 = x * y;
[x, y, z] = size(img1);         %third image sizes
numPixel3 = x * y;
[x, y, z] = size(img1);         %fourth image sizes
numPixel4 = x * y;

%       test area
% m = 255;
% n= 50;
% [a, b] = meshgrid([1: m], [1: n]);
% 
% img(b, a) = 0;
% 
% for i = 1 : n
%     for j = 1 : m
%         img(i, j) = j;
%     end
% end

%find histogram of loaded images
myHist = findHist(img1);
myHist2 = findHist(img2);
myHist3 = findHist(img3);
myHist4 = findHist(img4);

%find histogram of images and calculate transfer functions
transF1 = transferF(myHist, numPixel1);
transF2 = transferF(myHist2, numPixel2);
transF3 = transferF(myHist3, numPixel3);
transF4 = transferF(myHist4, numPixel4);

%make new histogram equalized images 
eqIMG1 = eqHist(img1, transF1);
eqIMG2 = eqHist(img2, transF2);
eqIMG3 = eqHist(img3, transF3);
eqIMG4 = eqHist(img4, transF4);

%find new images histograms
histEq1 = findHist(eqIMG1);
histEq2 = findHist(eqIMG2);
histEq3 = findHist(eqIMG3);
histEq4 = findHist(eqIMG4);

%show results
subplot(4, 5, 1);
imshow(img1,[0 255]);
title('Original Image');
subplot(4, 5, 2);
stem(myHist, 'marker', 'none');
title('Original Histogram');
subplot(4, 5, 3);
plot(transF1);
title('Transfer Function');
subplot(4, 5, 4);
imshow(eqIMG1, [0 255]);
title('Histogram Equalized Image');
subplot(4, 5, 5);
stem(histEq1, 'marker', 'none');
title('New Histogram');

subplot(4, 5, 6);
imshow(img2,[0 255]);
subplot(4, 5, 7);
stem(myHist2, 'marker', 'none');
subplot(4, 5, 8);
plot(transF2);
subplot(4, 5, 9);
imshow(eqIMG2, [0 255]);
subplot(4, 5, 10);
stem(histEq2, 'marker', 'none');

subplot(4, 5, 11);
imshow(img3,[0 255]);
subplot(4, 5, 12);
stem(myHist3, 'marker', 'none');
subplot(4, 5, 13);
plot(transF3);
subplot(4, 5, 14);
imshow(eqIMG3, [0 255]);
subplot(4, 5, 15);
stem(histEq3, 'marker', 'none');

subplot(4, 5, 16);
imshow(img4,[0 255]);
subplot(4, 5, 17);
stem(myHist4, 'marker', 'none');
subplot(4, 5, 18);
plot(transF4);
subplot(4, 5, 19);
imshow(eqIMG4, [0 255]);
subplot(4, 5, 20);
stem(histEq4, 'marker', 'none');

end

function val = findHist(img)

%find dimensions of parameter
% x : width
% y : height
% z : channel count
[x, y, z] = size(img);

val(256) = 0;
%!!!histogram array can be overflow to 256 so we take the array size 256 !!!

%find histogram array
for i = 1: x
    for j = 1: y
        var = img(i, j);
        val(var + 1) = val(var + 1) + 1;
     end
end

end

%calculate transfer function
function val = transferF(hist, numPix)

val(255) = 0;

%divide every pixel member of histogram array with pixel count
%and take the integral
for i = 1 : 255
    var = hist(i) / numPix;
    if i == 1   %do this for first member of array 
        val(i) = var;
    else
        val(i) = val(i - 1) + var;
    end
end

end

%find new histogram equalized image
function val = eqHist(img, tf)

[x, y, z] = size(img);

val(x, y) = 0;

for i = 1 : x
    for j = 1 : y
        if(img(i ,j) ~= 0)
            %product every pixel of image with transfer function
            val(i ,j) = round(tf(img(i, j)) * 255);
        end
    end
end

end