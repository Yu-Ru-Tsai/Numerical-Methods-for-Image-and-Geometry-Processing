clc;clear;close all;
%% parameters setting
addpath("footage");
addpath("function");

IMG_NAME = 'dog.jpg';

model_name = ["1-Norm", "Isotropic", "Anisotropic", "2-Norm", "1&2-Norm", "1->2-Norm", "2->1-Norm"];

OUTER_MIN_ITER = 5;
OUTER_MAX_ITER = 50;
OUTER_TOL   = 1e-5;
OUTER_ERROR = 1;

INNER_MAX_ITER = 50;
INNER_TOL = 1e-5;

EVALUTION_HYPERPARAMETER = 50;

rng(1);
%% noise and linear solver selecting
img_origin = imread(IMG_NAME);
img_origin = im2gray(img_origin);

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

optimal_parameters = ones([length(model_name), 3]); %(model_num, lambda&mu&alpha)
[img_size_h, img_size_w] = size(img_noisy);
img_denoised = uint8(zeros([length(model_name), img_size_h, img_size_w])); % images array

time = zeros(1, length(model_name)); % each model rum time
time_start = tic;
%% model
for model_num = 1 : length(model_name)
    
    fprintf(['%s: ================================================================================================================' ...
        '==========================\n'], model_name(model_num));
    tic;
    
    % two parameters
    if strcmp(model_name(model_num), "1-Norm") || strcmp(model_name(model_num), "Isotropic") ...
        || strcmp(model_name(model_num), "Anisotropic") || strcmp(model_name(model_num), "2->1-Norm")

        lambda = optimizableVariable('lambda', [0, 2]); % parameter bound
        mu     = optimizableVariable('mu',     [0, 2]);
        vars   = [lambda, mu]; 
        
        vars0 = table(1, 1); % initial values
    
        if strcmp(model_name(model_num), "2->1-Norm") % changing the noisy image with 2-norm denoised image

            [~, max_index] = max([ssim(reshape(img_denoised(2,:,:), [img_size_h, img_size_w]), img_origin), ...
                ssim(reshape(img_denoised(3,:,:), [img_size_h, img_size_w]), img_origin), ...
                ssim(reshape(img_denoised(4,:,:), [img_size_h, img_size_w]), img_origin)]); % selecting the highest ssim denoised image

            img_noisy_temp = reshape(img_denoised(max_index+1,:,:), [img_size_h, img_size_w]);  
        else
            img_noisy_temp = img_noisy;
        end

        results = bayesopt(@(vars)(ssim(WhichModel(model_name(model_num), img_noisy_temp, linear_solver_method, vars.lambda, vars.mu, 0, ...
            OUTER_MIN_ITER, OUTER_MAX_ITER, OUTER_TOL, OUTER_ERROR, INNER_MAX_ITER, INNER_TOL), img_origin)*-1), vars, 'PlotFcn', [], ...
            'MaxObjectiveEvaluations', EVALUTION_HYPERPARAMETER, 'UseParallel', true, 'InitialX', vars0);        
        
        optimal_parameters(model_num, 1:2) = [results.XAtMinObjective.lambda, results.XAtMinObjective.mu];

        img_denoised(model_num, :,:) = WhichModel(model_name(model_num), img_noisy_temp, linear_solver_method, optimal_parameters(model_num, 1),  optimal_parameters(model_num, 2), 0, ...
            OUTER_MIN_ITER, OUTER_MAX_ITER, OUTER_TOL, OUTER_ERROR, INNER_MAX_ITER, INNER_TOL);

        time(model_num) = toc;

    % one parameter
    elseif strcmp(model_name(model_num), "2-Norm") || strcmp(model_name(model_num), "1->2-Norm")

        mu_upperbound = 1;
        while(optimal_parameters(model_num, 2) == 1 || round(optimal_parameters(model_num, 2), 1) == mu_upperbound)

            mu_upperbound = round(mu_upperbound + 1);

            mu     = optimizableVariable('mu', [0, mu_upperbound]);
            vars   = mu;
            
            vars0 = table(optimal_parameters(model_num, 2)); % initial values
    
            if strcmp(model_name(model_num), "1->2-Norm") % changing the noisy image with 1-norm denoised image
                img_noisy_temp = reshape(img_denoised(1,:,:), [img_size_h, img_size_w]);
            else
                img_noisy_temp = img_noisy;
            end
        
            results = bayesopt(@(vars)(ssim(WhichModel(model_name(model_num), img_noisy_temp, linear_solver_method, 0, vars.mu, 0, ...
                0, 0, 0, 0, INNER_MAX_ITER, INNER_TOL), img_origin)*-1), vars, 'PlotFcn', [], ...
                'MaxObjectiveEvaluations', EVALUTION_HYPERPARAMETER, 'UseParallel', true, 'InitialX', vars0);
            
            optimal_parameters(model_num, 2) = results.XAtMinObjective.mu;

        end

        img_denoised(model_num, :,:) = WhichModel(model_name(model_num), img_noisy_temp, linear_solver_method, 0, optimal_parameters(model_num, 2), 0, ...
            0, 0, 0, 0, INNER_MAX_ITER, INNER_TOL);

        time(model_num) = toc;

    % three parameters
    elseif strcmp(model_name(model_num), "1&2-Norm")

        lambda = optimizableVariable('lambda', [0, 2]); % parameter bound
        mu     = optimizableVariable('mu',     [0, 2]);
        alpha  = optimizableVariable('alpha',  [0, 2]);
        vars   = [lambda, mu, alpha];
        
        vars0 = table(1, 1, 1); % initial values
    
        results = bayesopt(@(vars)(ssim(WhichModel(model_name(model_num), img_noisy, linear_solver_method, vars.lambda, vars.mu, vars.alpha, ...
            OUTER_MIN_ITER, OUTER_MAX_ITER, OUTER_TOL, OUTER_ERROR, INNER_MAX_ITER, INNER_TOL), img_origin)*-1), vars, 'PlotFcn', [], ...
            'MaxObjectiveEvaluations', EVALUTION_HYPERPARAMETER, 'UseParallel', true, 'InitialX', vars0);        
        
        optimal_parameters(model_num, 1:3) = [results.XAtMinObjective.lambda, results.XAtMinObjective.mu, results.XAtMinObjective.alpha];

        img_denoised(model_num, :,:) = WhichModel(model_name(model_num), img_noisy, linear_solver_method, optimal_parameters(model_num, 1), optimal_parameters(model_num, 2), ...
            optimal_parameters(model_num, 3), OUTER_MIN_ITER, OUTER_MAX_ITER, OUTER_TOL, OUTER_ERROR, INNER_MAX_ITER, INNER_TOL);

        time(model_num) = toc;
    end
end
%% plotting
[~, name, ~] = fileparts(IMG_NAME);
result_name = append('result/opt_bayes_', name, '_', upper(string(noise_type)), '_GRAY_ssim.png');

PlotResultGRAY(img_origin, img_noisy, noise_type, img_denoised, result_name, optimal_parameters);

time_end = toc(time_start);
