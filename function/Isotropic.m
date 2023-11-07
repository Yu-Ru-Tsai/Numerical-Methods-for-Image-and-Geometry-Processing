function img_denoised = Isotropic(img_noisy, linear_solver_method, ...
    lambda, mu, OUTER_MIN_ITER, OUTER_MAX_ITER, OUTER_TOL, OUTER_ERROR, ...
    INNER_MAX_ITER, INNER_TOL)
[m,n] = size(img_noisy);
N  = m*n;
[nablaX, nablaY] = DifferenceMatrices(m,n);
laplace = -[nablaX; nablaY]'*[nablaX; nablaY];
A = mu*speye(N) - lambda*laplace;
f = double(img_noisy(:))/255; 

% initialize
d  = zeros(N,1);
bX = d;
bY = d;
dX = d;
dY = d;
u0  = f;
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
    rhs = mu*f + lambda*nablaX'*(dX-bX) + lambda*nablaY'*(dY-bY);
    u = LinearSysSolver(linear_solver_method, A, rhs, u0, INNER_MAX_ITER, INNER_TOL, M1, M2);
    s = sqrt((nablaX*u + bX).^2 + (nablaY*u + bY).^2);                      % update s^k, equation (4.6)
    dX = max(s-1/lambda,0) .* (nablaX*u + bX) ./ s;                         % update d_x^{k+1}, equation (4.4)
    dY = max(s-1/lambda,0) .* (nablaY*u + bY) ./ s;                         % update d_y^{k+1}, equation (4.5)
    bX = bX + (nablaX*u - dX);                                              % update b_x^{k+1}
    bY = bY + (nablaY*u - dY);                                              % update b_y^{k+1}
    OUTER_ERROR = norm(u0-u)/norm(u);
%     fprintf('#(%2d)%s Error = %e\n', iterations, linear_solver_method, OUTER_ERROR);
    u0 = u;
end
img_denoised = uint8(reshape(u,m,n)*255);