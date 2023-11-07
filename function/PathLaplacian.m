function L = PathLaplacian(n, h)
if nargin == 1
    h = 1;
end
L =   sparse(1:n-1  , 2:n   ,  1, n, n)...
    + sparse(1:n    , 1:n   , -2, n, n)...
    + sparse(2:n    , 1:n-1 ,  1, n, n);
L = L/h^2;