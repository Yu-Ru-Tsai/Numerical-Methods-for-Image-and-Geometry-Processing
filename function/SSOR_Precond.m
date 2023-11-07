%% This function construct SSOR preconditioner for the linear system (Lx=b)
% Input:
% L: a sparse matrix of size n-by-n
% omega: a coefficient between 0 and 2.
% Output:
% M1, M2: two function handles that can solve M1\x and M2\x;
function [M1, M2] = SSOR_Precond(L, omega)
    lowerL = tril(L, -1);
    diagL = diag(L);
    coef = sqrt(omega / (2-omega));
    
    M1 = coef * (diag(diagL / omega) + lowerL) .* (diagL .^ (-1/2))';
    M2 = M1';
    
    M1 = @(x) (M1\x);
    M2 = @(x) (M2\x);