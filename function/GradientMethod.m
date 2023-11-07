function x = GradientMethod(A, rhs, x, MaxIter, Tol)
p = rhs - A*x;
Res = norm(p);
Iter = 0;
while Iter < MaxIter && Res > Tol
    Iter = Iter + 1;
    alpha = (p.'*p) / (p.'*(A*p));
    x = x + alpha*p;
    p = rhs - A*x;
    Res = norm(p);
end