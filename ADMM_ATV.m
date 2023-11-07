function DenoisedImg = test(NoisyImg, lambda, rho)
[m,n] = size(NoisyImg);
N = m*n;
[Dx, Dy] = DifferenceMatrices(m,n);
D=[Dx; Dy];
DT = D';
DTD = D'*D;

A = rho*DTD + lambda*speye(N);
f = im2double(NoisyImg(:));
u0 = f;
y = zeros(2*N,1);
v = y;
Iter = 0;
MinIter = 5;
MaxIter = 20;
Tol = 1;
Error = Inf;

while (Error > Tol && Iter < MaxIter) || Iter <= MinIter
    Iter = Iter + 1;
    
    % u sub-problem
    rhs = lambda*f + rho*DT*(v- (y/rho));
    %u = A\rhs;
    %u = GradientMethod(A, rhs, u0, 5, 1e-4);
    %u = ConjugateGradientMethod(A, rhs, u0, 5, 1e-4);
    %[u,~] = cgs(A, rhs, 1e-4, 5, [], [], u0);
    [u,~] = pcg(A, rhs, 1e-4, 5, [], [], u0);
    
    % v sub-problem
    x = D*u + y/rho;
    v = shrink(x, 1);
    
    % Update Lagrange multiplier
    y = y + rho*(D*u- v);
    Error = norm(u- u0);
    fprintf('#(%2d) Error = %e\n', Iter, Error);
    u0 = u;
end
DenoisedImg = im2uint8(reshape(u,m,n));
end


function [Gx, Gy] = DifferenceMatrices(m,n)
Dx = sparse(1:n-1, 1:n-1, -1, n, n) + sparse(1:n-1, 2:n, 1, n, n);
Gx = kron(Dx, speye(m));
Dy = sparse(1:m-1, 1:m-1, -1, m, m) + sparse(1:m-1, 2:m, 1, m, m);
Gy = kron(speye(n), Dy);
end

function z = shrink(x,r)
z = sign(x).*max(abs(x)- r,0);
end