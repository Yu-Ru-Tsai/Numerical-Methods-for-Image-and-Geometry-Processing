function PlotResultRGB(img_origin, img_noisy, noise_type, img_denoised, result_name, optimal_parameters)

[img_size_h, img_size_w, img_size_d] = size(img_noisy);
img_denoised_1  = reshape(img_denoised(1,:,:,:), [img_size_h, img_size_w, img_size_d]);
img_denoised_I  = reshape(img_denoised(2,:,:,:), [img_size_h, img_size_w, img_size_d]);
img_denoised_A  = reshape(img_denoised(3,:,:,:), [img_size_h, img_size_w, img_size_d]);
img_denoised_2  = reshape(img_denoised(4,:,:,:), [img_size_h, img_size_w, img_size_d]);
img_denoised_12 = reshape(img_denoised(5,:,:,:), [img_size_h, img_size_w, img_size_d]);
img_denoised_1then2 = reshape(img_denoised(6,:,:), [img_size_h, img_size_w, img_size_d]);
img_denoised_2then1 = reshape(img_denoised(7,:,:), [img_size_h, img_size_w, img_size_d]);

[PSNR_N, ~, SSIM_N]    = Measurement(img_noisy      , img_origin);
[PSNR_1, ~, SSIM_1]    = Measurement(img_denoised_1 , img_origin);
[PSNR_I, ~, SSIM_I]    = Measurement(img_denoised_I , img_origin);
[PSNR_A, ~, SSIM_A]    = Measurement(img_denoised_A , img_origin);
[PSNR_2, ~, SSIM_2]    = Measurement(img_denoised_2 , img_origin);
[PSNR_12, ~, SSIM_12] = Measurement(img_denoised_12, img_origin);
[PSNR_1then2, ~, SSIM_1then2] = Measurement(img_denoised_1then2, img_origin);
[PSNR_2then1, ~, SSIM_2then1] = Measurement(img_denoised_2then1, img_origin);

fig = figure;
fig.WindowState = "maximized";

% lbwh = get(fig, 'position');
% w = lbwh(3);
% h = lbwh(4);

cols = 5;
rows = 2;

axisw = (1 / cols) * 0.95;
axish = (1 / rows) * 0.95;

axisb = zeros(1, rows);
axisl = zeros(1, cols);

for row = 1 : rows
    axisb(row) = axish * (row - 1) + row * 0.0125;
    for col = 1 : cols
        axisl(col) = axisw * (col - 1) + col * 0.009;
    end
end

format_spec = '%.3f';

subplot('position', [axisl(1), axisb(2), axisw, axish])
axis off;
imshow(img_origin);
axis off;
title({'Original Image' ' '}, 'FontSize', 20)

subplot('position', [axisl(2), axisb(2), axisw, axish])
imshow(img_noisy);
axis off;
switch noise_type
    case 'g'
        title({'Noisy Image: Gaussian Noise' ...
            ['PSNR = ', num2str(PSNR_N, format_spec), ', SSIM = ', num2str(SSIM_N, format_spec)]}, ...
            'FontSize', 20);
    case 'sp'
        title({'Noisy Image: Salt & Pepper Noise' ...
            ['PSNR = ', num2str(PSNR_N, format_spec), ', SSIM = ', num2str(SSIM_N, format_spec)]}, ...
            'FontSize', 20);
    case 'mix1'
        title({'Noisy Image: Mix(G->SP) Noise' ...
            ['PSNR = ', num2str(PSNR_N, format_spec), ', SSIM = ', num2str(SSIM_N, format_spec)]}, ...
            'FontSize', 20);
    case 'mix2'
        title({'Noisy Image: Mix(SP->G) Noise' ...
            ['PSNR = ', num2str(PSNR_N, format_spec), ', SSIM = ', num2str(SSIM_N, format_spec)]}, ...
            'FontSize', 20);
    otherwise
        fprintf('Error\n');
end

subplot('position', [axisl(3), axisb(2), axisw, axish])
imshow(img_denoised_1);
axis off;
title({'1-norm TV model' ...
    ['R \lambda = ', num2str(optimal_parameters(1,1,1), format_spec), ', \mu = ', num2str(optimal_parameters(1,1,2), format_spec)] ...
    ['G \lambda = ', num2str(optimal_parameters(1,2,1), format_spec), ', \mu = ', num2str(optimal_parameters(1,2,2), format_spec)] ...
    ['B \lambda = ', num2str(optimal_parameters(1,3,1), format_spec), ', \mu = ', num2str(optimal_parameters(1,3,2), format_spec)] ...
    ['PSNR = ', num2str(PSNR_1, format_spec), ', SSIM = ', num2str(SSIM_1, format_spec)]}, ...
    'FontSize', 20);

subplot('position', [axisl(4), axisb(2), axisw, axish])
imshow(img_denoised_I);
axis off;
title({'Isotropic TV model' ...
    ['R \lambda = ', num2str(optimal_parameters(2,1,1), format_spec), ', \mu = ', num2str(optimal_parameters(2,1,2), format_spec)] ...
    ['G \lambda = ', num2str(optimal_parameters(2,2,1), format_spec), ', \mu = ', num2str(optimal_parameters(2,2,2), format_spec)] ...
    ['B \lambda = ', num2str(optimal_parameters(2,3,1), format_spec), ', \mu = ', num2str(optimal_parameters(2,3,2), format_spec)] ...
    ['PSNR = ', num2str(PSNR_I, format_spec), ', SSIM = ', num2str(SSIM_I, format_spec)]}, ...
    'FontSize', 20);

subplot('position', [axisl(5), axisb(2), axisw, axish])
imshow(img_denoised_A);
axis off;
title({'Anisotropic TV model' ...
    ['R \lambda = ', num2str(optimal_parameters(3,1,1), format_spec), ', \mu = ', num2str(optimal_parameters(3,1,2), format_spec)] ...
    ['G \lambda = ', num2str(optimal_parameters(3,2,1), format_spec), ', \mu = ', num2str(optimal_parameters(3,2,2), format_spec)] ...
    ['B \lambda = ', num2str(optimal_parameters(3,3,1), format_spec), ', \mu = ', num2str(optimal_parameters(3,3,2), format_spec)] ...
    ['PSNR = ', num2str(PSNR_A, format_spec), ', SSIM = ', num2str(SSIM_A, format_spec)]}, ...
    'FontSize', 20);

subplot('position', [axisl(1), axisb(1), axisw, axish])
imshow(img_denoised_2);
axis off;
title({'2-norm TV model' ...
    ['R \mu = ', num2str(optimal_parameters(4,1,2), format_spec)] ...
    ['G \mu = ', num2str(optimal_parameters(4,2,2), format_spec)] ...
    ['B \mu = ', num2str(optimal_parameters(4,3,2), format_spec)] ...
    ['PSNR = ', num2str(PSNR_2, format_spec), ', SSIM = ', num2str(SSIM_2, format_spec)]}, ...
    'FontSize', 20);

subplot('position', [axisl(2), axisb(1), axisw, axish])
imshow(img_denoised_12);
axis off;
title({'1 & 2-norm TV model' ...
    ['R \lambda = ', num2str(optimal_parameters(5,1,1), format_spec), ', \mu = ', num2str(optimal_parameters(5,1,2), format_spec), ', \alpha = ', num2str(optimal_parameters(5,1,3), format_spec)] ...
    ['G \lambda = ', num2str(optimal_parameters(5,2,1), format_spec), ', \mu = ', num2str(optimal_parameters(5,2,2), format_spec), ', \alpha = ', num2str(optimal_parameters(5,2,3), format_spec)] ...
    ['B \lambda = ', num2str(optimal_parameters(5,3,1), format_spec), ', \mu = ', num2str(optimal_parameters(5,3,2), format_spec), ', \alpha = ', num2str(optimal_parameters(5,3,3), format_spec)] ...
    ['PSNR = ', num2str(PSNR_12, format_spec), ', SSIM = ', num2str(SSIM_12, format_spec)]}, ...
    'FontSize', 20);

subplot('position', [axisl(3), axisb(1), axisw, axish])
imshow(img_denoised_1then2);
axis off;
title({'1 -> 2-norm TV model' ...
    ['R \mu = ', num2str(optimal_parameters(6,1,2), format_spec)] ...
    ['G \mu = ', num2str(optimal_parameters(6,2,2), format_spec)] ...
    ['B \mu = ', num2str(optimal_parameters(6,3,2), format_spec)] ...
    ['PSNR = ', num2str(PSNR_1then2, format_spec), ', SSIM = ', num2str(SSIM_1then2, format_spec)]}, ...
    'FontSize', 20);

subplot('position', [axisl(4), axisb(1), axisw, axish])
imshow(img_denoised_2then1);
axis off;
title({'2 -> 1-norm TV model' ...
    ['R \lambda = ', num2str(optimal_parameters(7,1,1), format_spec), ', \mu = ', num2str(optimal_parameters(7,1,2), format_spec)] ...
    ['G \lambda = ', num2str(optimal_parameters(7,2,1), format_spec), ', \mu = ', num2str(optimal_parameters(7,2,2), format_spec)] ...
    ['B \lambda = ', num2str(optimal_parameters(7,3,1), format_spec), ', \mu = ', num2str(optimal_parameters(7,3,2), format_spec)] ...
    ['PSNR = ', num2str(PSNR_2then1, format_spec), ', SSIM = ', num2str(SSIM_2then1, format_spec)]}, ...
    'FontSize', 20);

pause(5);
saveas(fig, result_name);