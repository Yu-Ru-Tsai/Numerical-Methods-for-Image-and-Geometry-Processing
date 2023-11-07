function [Val_PSNR]= PSNR(U,T)
Val_PSNR = 20*log10(255) - 10*log10(MSE(U,T));