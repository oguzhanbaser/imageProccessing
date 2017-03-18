close all, clear all;

img = imread('C:\Users\baser\Documents\MATLAB\imageProc\imgSource\skeleton.tif');

img = double(img);              %org image
[x, y, z] = size(img);
imgL = zeros(x, y);             %laplacian image
imgHN = zeros(x, y);            
imgS = zeros(x, y);             %sobel gradient image
imgA = zeros(x, y);             %averaging filter image
imgP = zeros(x, y);             %product of normalize laplacian and sobel gradient image
imgSH = zeros(x, y);            %sum of original image and producted image
imgG = zeros(x, y);             %gamma corrected image

% img = [5 8 6 2 3 1;           %test image
%     1 5 3 6 5 8;
%     9 5 4 2 8 7;
%     4 9 2 3 7 8;
%     25 26 27 28 29 30];

mask = [0 -1  0;
       -1  4 -1;
        0 -1  0];    %laplacian mask
    
maskAv = 1 / 25 * [1 1 1 1 1;         %5 * 5 average mask
                   1 1 1 1 1;
                   1 1 1 1 1;
                   1 1 1 1 1;
                   1 1 1 1 1];
              
sobelMaskY = [-1 0 1; 
              -2 0 2; 
              -1 0 1];  %sobel maks vertical
          
sobelMaskX = [-1 -2 -1;
               0  0  0; 
               1  2  1];  %sobel mask horizontal
mySum = 0;

%add laplacian maks to original image
for i = 2: x - 1
    for j = 2: y - 1
        mySum = 0;
        for a = 1: 3
            for b = 1: 3
               maskA = mask(a, b);
               mySum = mySum + maskA * img(i + a - 2, j + b - 2); 
            end 
        end
        imgL(i, j) = mySum;
    end
end

%add sobel gradient maks to original image
for i = 2: x - 1
    for j = 2: y - 1
        mySum1 = 0;
        mySum2 = 0;
        for a = 1: 3
            for b = 1: 3
               maskX = sobelMaskX(a, b);
               maskY = sobelMaskY(a, b);
               mySum1 = mySum1 + maskX * img(i + a - 2, j + b - 2); 
               mySum2 = mySum2 + maskY * img(i + a - 2, j + b - 2); 
            end 
        end
        imgS(i, j) = sqrt(mySum1 * mySum1 + mySum2 * mySum2);
    end
end

%add 5*5 average filter to sobel gradient image
for i = 3: x - 2
    for j = 3: y - 2
        mySum = 0;
        for a = 1: 5
            for b = 1: 5
               maskA = maskAv(a, b);
               mySum = mySum + maskA * imgS(i + a - 3, j + b - 3); 
            end 
        end
        imgA(i, j) = mySum;
    end
end


imgH = img + imgL;

%find max value of 
maxVal = 0;
for i = 1: x
    for j = 1 : y
        if imgH(i,j) > maxVal
            maxVal = imgH(i, j);
        end
    end
end

imgHN = imgH / maxVal;      %normalize laplacian image
imgP = imgHN .* imgA;       %product of original image and normalized image

imgSH = img + imgP;        %add original image normalized image
imgG = 255 * ((imgSH / 255) .^ (1 / 2));    %gamma correction

%show results

%A = imfilter(imgS, maskAv);
%[Gx, Gy] = imgradientxy(img, 'sobel');
%[Gmag, Gdir] = imgradient(Gx, Gy);
    
subplot(2, 4, 1);
imshow(img, [0 255]);

imgLS = imgL + 125;         %show laplacian image with gray color
subplot(2, 4, 2);
imshow(imgLS, [0 255]);

subplot(2, 4, 3);
imshow(imgH, [0 255]);

subplot(2, 4, 4);
imshow(imgS, [0 255]);

subplot(2, 4, 5);
imshow(imgA, [0 255]);

subplot(2, 4, 6);
imshow(imgP, [0 255]);

subplot(2, 4, 7);
imshow(imgSH, [0 255]);

subplot(2, 4, 8);
imshow(imgG, [0 255]);



