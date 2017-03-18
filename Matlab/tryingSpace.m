close all;

Image = imread('C:\Users\baser\Desktop\CShapes.png');

imageGray = rgb2gray(Image);

[centers, radii] = imfindcircles(imageGray, [20,25], 'ObjectPolarity', 'dark', ...
    'Sensitivity' , 0.985);

centers
radii


figure;
imshow(Image);
%imshow(imageGray);