function [Val_PSNR, Val_MSE, Val_SSIM]= Measurement(U,T)
Val_MSE = MSE(U,T);
Val_PSNR = 20*log10(255) - 10*log10(Val_MSE);
Val_SSIM = ssim(U,T);