clc;clear;close all;
%% parameters setting
addpath("footage");
addpath("function");

IMG_NAME = 'dog-n.jpg';

model_name = ["1-Norm", "Isotropic", "Anisotropic", "2-Norm", "1&2-Norm", "1->2-Norm", "2->1-Norm"];

OUTER_MIN_ITER = 5;
OUTER_MAX_ITER = 50;
OUTER_TOL   = 1e-5;
OUTER_ERROR = 1;

INNER_MAX_ITER = 50;
INNER_TOL = 1e-5;

rng(1);
%% noise and linear solver selecting
img_origin = imread(IMG_NAME);

noise_type = input("Select the type of noise(g/sp/mix1[g->sp]/mix2[sp->g]/none): ", "s");
% type = 'g';
switch noise_type
    case 'g'
        img_noisy = imnoise(img_origin, 'gaussian');
    case 'sp'
        img_noisy = imnoise(img_origin, 'salt & pepper', 0.3);
    case 'mix1'
        img_noisy = imnoise(img_origin, 'gaussian');
        img_noisy = imnoise(img_noisy , 'salt & pepper');
    case 'mix2'      
        img_noisy = imnoise(img_origin, 'salt & pepper');
        img_noisy = imnoise(img_noisy , 'gaussian');
    case 'none'
        img_noisy = img_origin;
    otherwise
        fprintf('error noise type\n');
        return;
end
linear_solver_method = input("Select the method of solving linear systems\n(mld/g/cg/cgs/pcg/ssor): ", "s");
% linear_solver_method = 'cgs';

optimal_parameters = ones([length(model_name), 3, 3]); %(model_num, r&g&b, lambda&mu&alpha)
[img_size_h, img_size_w, img_size_d] = size(img_noisy);
img_denoised = uint8(zeros([length(model_name), img_size_h, img_size_w, img_size_d]));

time = zeros(1, length(model_name)); % each model rum time
time_start = tic;
%% model
for model_num = 1 : length(model_name)
    
    fprintf('%s:\n', model_name(model_num));
    tic;
    
    if strcmp(model_name(model_num), "1-Norm") || strcmp(model_name(model_num), "Isotropic") ...
            || strcmp(model_name(model_num), "Anisotropic") || strcmp(model_name(model_num), "2->1-Norm")

        lambda = 1;
        mu     = 1;

        if strcmp(model_name(model_num), "2->1-Norm") % changing the noisy image with 2-norm denoised image

            [~, max_index] = max([ssim(reshape(img_denoised(2,:,:), [img_size_h, img_size_w, img_size_d]), img_origin), ...
                ssim(reshape(img_denoised(3,:,:), [img_size_h, img_size_w, img_size_d]), img_origin), ...
                ssim(reshape(img_denoised(4,:,:), [img_size_h, img_size_w, img_size_d]), img_origin)]); % selecting the highest ssim denoised image

            img_noisy_temp = reshape(img_denoised(max_index+1,:,:), [img_size_h, img_size_w, img_size_d]); 
        else
            img_noisy_temp = img_noisy;
        end

        img_denoised(model_num, :,:,:) = cat(3, ...
            WhichModel(model_name(model_num), img_noisy_temp(:,:,1), linear_solver_method, lambda, mu, 0, ...
                OUTER_MIN_ITER, OUTER_MAX_ITER, OUTER_TOL, OUTER_ERROR, INNER_MAX_ITER, INNER_TOL), ...
            WhichModel(model_name(model_num), img_noisy_temp(:,:,2), linear_solver_method, lambda, mu, 0, ...
                OUTER_MIN_ITER, OUTER_MAX_ITER, OUTER_TOL, OUTER_ERROR, INNER_MAX_ITER, INNER_TOL), ...
            WhichModel(model_name(model_num), img_noisy_temp(:,:,3), linear_solver_method, lambda, mu, 0, ...
                OUTER_MIN_ITER, OUTER_MAX_ITER, OUTER_TOL, OUTER_ERROR, INNER_MAX_ITER, INNER_TOL));

        time(model_num) = toc;

    elseif strcmp(model_name(model_num), "2-Norm") || strcmp(model_name(model_num), "1->2-Norm")

        mu     = 1;

        if strcmp(model_name(model_num), "1->2-Norm") % changing the noisy image with 1-norm denoised image
            img_noisy_temp = reshape(img_denoised(1,:,:), [img_size_h, img_size_w, img_size_d]);
        else
            img_noisy_temp = img_noisy;
        end

        img_denoised(model_num, :,:,:) = cat(3, ...
            WhichModel(model_name(model_num), img_noisy_temp(:,:,1), linear_solver_method, 0, mu, 0, 0, 0, 0, 0, ...
                INNER_MAX_ITER, INNER_TOL), ...
            WhichModel(model_name(model_num), img_noisy_temp(:,:,2), linear_solver_method, 0, mu, 0, 0, 0, 0, 0, ...
                INNER_MAX_ITER, INNER_TOL), ...
            WhichModel(model_name(model_num), img_noisy_temp(:,:,3), linear_solver_method, 0, mu, 0, 0, 0, 0, 0, ...
                INNER_MAX_ITER, INNER_TOL));

        time(model_num) = toc;

    elseif strcmp(model_name(model_num), "1&2-Norm")

        lambda = 1;
        mu     = 1;
        alpha  = 1;

        img_denoised(model_num, :,:,:) = cat(3, ...
            WhichModel(model_name(model_num), img_noisy(:,:,1), linear_solver_method, lambda, mu, alpha, ...
                OUTER_MIN_ITER, OUTER_MAX_ITER, OUTER_TOL, OUTER_ERROR, INNER_MAX_ITER, INNER_TOL), ...
            WhichModel(model_name(model_num), img_noisy(:,:,2), linear_solver_method, lambda, mu, alpha, ...
                OUTER_MIN_ITER, OUTER_MAX_ITER, OUTER_TOL, OUTER_ERROR, INNER_MAX_ITER, INNER_TOL), ...
            WhichModel(model_name(model_num), img_noisy(:,:,3), linear_solver_method, lambda, mu, alpha, ...
                OUTER_MIN_ITER, OUTER_MAX_ITER, OUTER_TOL, OUTER_ERROR, INNER_MAX_ITER, INNER_TOL));

        time(model_num) = toc;

    end
end
%% plotting
[~, name, ~] = fileparts(IMG_NAME);
result_name = append('result/', name, '_', upper(string(noise_type)), '_RGB.png');

PlotResultRGB(img_origin, img_noisy, noise_type, img_denoised, result_name, optimal_parameters)

time_end = toc(time_start);
