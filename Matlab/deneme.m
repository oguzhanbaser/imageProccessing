clear all, close all;

load polardata

dizi = [300 -60.2; 310 -60; 320 -57.2; 330 -55.4; 340 -47; 350 -40.8; 0 -37.8];

values = [-37.8 -40.8 -47 -55.4 -57.2 -60 -60.2];

h = helix;
[D,az,el] = pattern(h,2e9);
phi = az';
theta = (90-el);
MagE = D';
patternCustom(MagE, theta, phi);