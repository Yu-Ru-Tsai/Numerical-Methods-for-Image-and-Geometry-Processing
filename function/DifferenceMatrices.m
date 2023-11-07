function [Gx, Gy] = DifferenceMatrices(m,n)
Dx = sparse(1:n-1, 1:n-1, -1, n, n) + sparse(1:n-1, 2:n, 1, n, n);
Gx = kron(Dx, speye(m));
Dy = sparse(1:m-1, 1:m-1, -1, m, m) + sparse(1:m-1, 2:m, 1, m, m);
Gy = kron(speye(n), Dy);