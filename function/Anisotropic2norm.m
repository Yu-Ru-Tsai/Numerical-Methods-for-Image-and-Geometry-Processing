function img_denoised = Anisotropic2norm(img_noisy, linear_solver_method, ...
    mu, INNER_MAX_ITER, INNER_TOL)
[m,n] = size(img_noisy);
N  = m*n;
[nablaX, nablaY] = DifferenceMatrices(m,n);
A = nablaX.'*nablaX + nablaY.'*nablaY + mu/2*speye(N);
f  = double(img_noisy(:))/255;

% initialize
u0 = f;
     
if strcmp(linear_solver_method, 'ssor')
    w = 1.2;
    [M1, M2] = SSOR_Precond(A, w);
else
    M1 = 0;
    M2 = 0;
end

rhs = mu/2*f;
u = LinearSysSolver(linear_solver_method, A, rhs, u0, INNER_MAX_ITER, INNER_TOL, M1, M2);
% OUTER_ERROR = norm(u0-u)/norm(u);
% fprintf('#( 1)%s Error = %e\n', linear_solver_method, OUTER_ERROR);

img_denoised = uint8(reshape(u,m,n)*255);