%%
clc;clear;close all;

addpath("footage");
addpath("function");

rng(1);

Img = imread('cameraman.tif');
NoisyImg = imnoise(Img, 'salt & pepper', 0.1);
%%
lambda = 2;
mu     = 1;

MinIter = 5;
MaxIter = 30;
Tol   = 1;
Error = Inf;

maxiter = 30;
tol = 1e-3;

tic
DenoisedImg = SplitBregman(NoisyImg, 'g', lambda, mu, MinIter, MaxIter, Tol, Error, maxiter, tol);
toc

figure 
subplot(1,2,1)
imshow(NoisyImg);
title('Noisy Image')
subplot(1,2,2)
imshow(DenoisedImg);
title('Denoised Image')
%% 
[Val_PSNR, Val_MSE] = PSNR(DenoisedImg, Img);
fprintf('MSE = %f PSNR = %f\n', Val_MSE, Val_PSNR)