function myFurier
close all, clear all;

%read image
imgOrg = imread('C:\Users\baser\Documents\MATLAB\imageProc\imgSource\char.tif');
imgL = low_pass(imgOrg);
imgC = centerTrasnform(imgL);
imgFFT = fft2(imgC);

%ideal low pass filter
lowPassMat = makeFilter(imgOrg, 'ideal');
imgMX2 = lowPassMat .* imgFFT;
imgIn2 = real(ifft2(imgMX2));
imgCIn2 =  centerTrasnform(imgIn2);

%butterworth low pass filter
butterworthMath = makeFilter(imgOrg, 'butterworth');
imgMX3 = butterworthMath .* imgFFT;
imgIn3 = real(ifft2(imgMX3));
imgCIn3 =  centerTrasnform(imgIn3);

%gaussian low pass filter
gaussianMat = makeFilter(imgOrg, 'gaussian');
imgMX4 = butterworthMath .* imgFFT;
imgIn4 = real(ifft2(imgMX4));
imgCIn4 =  centerTrasnform(imgIn4);

%show first image and FFT
subplot(4, 3, 1);
imshow(imgOrg, [0 255]);
subplot(4, 3, 2);

%show ideal low pass filter
imshow(real(imgFFT), [0 255]);
subplot(4, 3, 4);
imshow(lowPassMat, [0 1]);
subplot(4, 3, 5);
surf(lowPassMat);
subplot(4, 3, 6);
imshow(imgCIn2, [0 255]);

%show butterworth low pass filter
subplot(4, 3, 7);
imshow(butterworthMath, [0 1]);
subplot(4, 3, 8);
surf(butterworthMath);
subplot(4, 3, 9);
imshow(imgCIn3, [0 255]);

%show gaussian low pass filter
subplot(4, 3, 10);
imshow(gaussianMat, [0 1]);
subplot(4, 3, 11);
surf(gaussianMat);
subplot(4, 3, 12);
imshow(imgCIn4, [0 255]);

end

function r_mat = low_pass(p_mat)
[x, y, z] = size(p_mat);
r_mat = p_mat;

maskAv = 1 / 25 * [1 1 1 1 1;         %5 * 5 average mask
                   1 1 1 1 1;
                   1 1 1 1 1;
                   1 1 1 1 1;
                   1 1 1 1 1];

for i = 3: x - 2
    for j = 3: y - 2
        mySum = 0;
        for a = 1: 5
            for b = 1: 5
               maskA = maskAv(a, b);
               mySum = mySum + maskA * p_mat(i + a - 3, j + b - 3); 
            end 
        end
        r_mat(i, j) = mySum;
    end
end
    
end

%a function for making filter
%there are three types filter in this function
%   ->ideal
%   ->butterworth
%   ->gaussian
function r_mat = makeFilter(p_mat, type)
[x, y, z] = size(p_mat);
r_mat(x,y) = 0;
u = x / 2;
v = y / 2;
D0 = 30;

if strcmp(type, 'ideal')
    
    for i = 1 : x
        for j = 1 : y
            if get_distance(i,j,u,v) <= D0
                r_mat(i, j) = 1;
            else
                r_mat(i, j) = 0;
            end
        end
    end
elseif strcmp(type, 'butterworth')
    n = 2;
    
    for i = 1 : x
        for j = 1 : y
            r_mat(i, j) = 1 / (1 + (get_distance(i ,j , u, v) / D0)^n);
        end
    end
elseif strcmp(type, 'gaussian')
    for i = 1 : x
        for j = 1 : y
            r_mat(i, j) = exp((-(get_distance(i, j, u, v)^2)) / (2 * (D0^2)) );
        end
    end
    
else
    disp('Error in filter params');
end

end

%getting index distance from center point
function r_val = get_distance(x1,y1,x2,y2)
    r_val = sqrt((x1 - x2)^2 + (y1 - y2)^2);
end

%make center transform for input image
function r_mat = centerTrasnform(p_mat)
[x, y, z] = size(p_mat);
r_mat(x,y) = 0;

for a = 1 : x
    for b = 1 : y
        r_mat(a, b) = ((-1) ^ (a + b)) * int16(p_mat(a, b));
    end
end

end