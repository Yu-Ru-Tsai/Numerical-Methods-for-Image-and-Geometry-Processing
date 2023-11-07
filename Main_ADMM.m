clear;clc;close all;
Img = imread('image\cameraman.jpg');
NoisyImg = imnoise(Img, 'gaussian');
lambda = 0.05;
rho = 0.01;

% NoisyImg = imnoise(Img, 'salt & pepper');
% lambda = 0.04;
% rho = 0.01;

% Img = imread('image\beach.jpg');
% Img=rgb2gray(Img);
% NoisyImg = imnoise(Img, 'gaussian');
% lambda = 0.05;
% rho = 0.05;

tic
DenoisedImg = ADMM_ATV(NoisyImg, lambda, rho);
toc

figure
subplot(1,2,1)
imshow(NoisyImg);
title('Noisy Image');
subplot(1,2,2)
imshow(DenoisedImg);
title('Denoised Image')

Noisy_PSNR = PSNR(NoisyImg,Img)
Value_PSNR = PSNR(DenoisedImg,Img)
