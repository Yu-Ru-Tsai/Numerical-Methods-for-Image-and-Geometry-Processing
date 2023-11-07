function L = LatticeLaplacian(n, m, h, k)
if nargin == 2
    h = 1;
    k = 1;
end
% Try to finish the remaining part of this code
Ln = PathLaplacian(n, h);
Lm = PathLaplacian(m, k);
In = speye(n);
Im = speye(m);
L = kron(Im,Ln) + kron(Lm,In);