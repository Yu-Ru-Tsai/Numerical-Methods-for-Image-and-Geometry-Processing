function img_denoised = SplitBregman(img_noisy, linear_solver_method, ...
    lambda, mu, OUTER_MIN_ITER, OUTER_MAX_ITER, OUTER_TOL, OUTER_ERROR, ...
    INNER_MAX_ITER, INNER_TOL)
[m,n] = size(img_noisy);
N  = m*n;
[nablaX, nablaY] = DifferenceMatrices(m,n);
A  = speye(N) + nablaX.'*nablaX + nablaY.'*nablaY;                          % {Ju: 看矩陣:full(A)}
f  = double(img_noisy(:))/255;                                               % {Ju: 轉成列向量(Nx1)}

% initialize
d  = zeros(N,1);
x  = d;
y  = d;
b1 = d;
b2 = d;
b3 = d;
u0 = f;
iterations = 0;

if strcmp(linear_solver_method, 'ssor')
    w = 1.2;
    [M1, M2] = SSOR_Precond(A, w);
else
    M1 = 0;
    M2 = 0;
end

while (OUTER_ERROR > OUTER_TOL && iterations < OUTER_MAX_ITER) || iterations <= OUTER_MIN_ITER
    iterations = iterations + 1;
    rhs = f - d + b1 + nablaX.'*(x-b2) + nablaY.'*(y-b3);
    u = LinearSysSolver(linear_solver_method, A, rhs, u0, INNER_MAX_ITER, INNER_TOL, M1, M2);
    d = shrink1(f-u+b1, lambda/mu/2);
    x = shrink1(nablaX*u+b2, 1/mu/2);
    y = shrink1(nablaY*u+b3, 1/mu/2);
    b1 = b1 + f-u-d;
    b2 = b2 + nablaX*u-x;
    b3 = b3 + nablaY*u-y;
    OUTER_ERROR = norm(u-u0)/norm(u);
%     fprintf('#(%2d)%s Error = %e\n', iterations, linear_solver_method, OUTER_ERROR);
    u0 = u;
end
img_denoised = uint8(reshape(u,m,n)*255);