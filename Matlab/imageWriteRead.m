clear all, close all;

%N, M image dimensions
%disp('N degerini giriniz: ');input('N='); N=ans;
%disp('M degerini giriniz: ');input('M='); M=ans;
N = 50;
M = 50;

[x, y] = meshgrid([1:N],[1:M]); %test image
gor(y, x) = 150;
for y=round(M/2)-2:round(M/2)+2
    for x=round(N/3):round(2*N/3)
        gor(y,x)=80;
    end
end
subplot(1,2,1);
imshow(gor, [0 255]);
title('oluþturulan görüntü');

%write to file
dosya=fopen('dos1.raw', 'w');
fwrite(dosya, gor, 'uint8');
fclose(dosya);

%read from file
dosya2=fopen('dos1.raw', 'r');
A=fread(dosya2, M*N, 'uint8');
A1=A;

z=1;
for a=1:M
    for b=1:N
        B(b,a)=A1(z);
        z=z+1;
    end
end

%show results
subplot(1,2,2);
imshow(B, [0 255]);
title('dosyadan okunan görüntü');
fclose(dosya2);