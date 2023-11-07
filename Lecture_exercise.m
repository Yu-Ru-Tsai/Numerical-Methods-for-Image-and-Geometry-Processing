%%
clc;clear;close all;

addpath("footage");
addpath("function");

rng(1);

Img = imread('exercise.png');
%%
lambda = 1;
mu     = 1;

MinIter = 5;
MaxIter = 30;
Tol   = 1;
Error = Inf;

maxiter = 30;
tol = 1e-3;

DenoisedImg = cat(3, ...
    SplitBregman(Img(:,:,1), 'g', lambda, mu, MinIter, MaxIter, Tol, Error, maxiter, tol), ...
    SplitBregman(Img(:,:,2), 'g', lambda, mu, MinIter, MaxIter, Tol, Error, maxiter, tol), ...
    SplitBregman(Img(:,:,3), 'g', lambda, mu, MinIter, MaxIter, Tol, Error, maxiter, tol));

%%
[Val_PSNR, Val_MSE] = PSNR(DenoisedImg, Img);

figure
subplot(1,2,1)
imshow(Img);
title({
    'Noisy Image'
    'Gaussian Noise' });
subplot(1,2,2)
imshow(DenoisedImg);
title({
    'Denoised Image'
    ['Denoised Image, PSNR = ', num2str(Val_PSNR)]});
%%
fprintf('MSE = %f PSNR = %f\n', Val_MSE, Val_PSNR)