function x = ConjugateGradientMethod(A, rhs, x, MaxIter, Tol)
r    = rhs - A*x;
p    = r;
Res  = norm(r);
Iter = 0;
while Iter < MaxIter && Res > Tol
    Iter  = Iter + 1;
    Ap    = A*p;
    pAp   = p.'*Ap;
    alpha = (p.'*r) / pAp;
    x     = x + alpha*p;
    r     = r - alpha*Ap;
    beta  = (p.'*(A*r)) / pAp;
    p     = r - beta*p;
    Res   = norm(Res);
end