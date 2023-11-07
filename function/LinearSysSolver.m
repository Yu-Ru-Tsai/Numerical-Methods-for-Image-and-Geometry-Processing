function u = LinearSysSolver(method, A, rhs, u0, maxiter, tol, M1, M2)
switch method
    case 'mld'                                                              
        u = A\rhs;                                                      % {En: Direct: mldivide}
    case 'g'   
        u = GradientMethod(A, rhs, u0, maxiter, tol);                   % {En: Iterative(Symmetric): Gradient}
    case 'cg'  
        u = ConjugateGradientMethod(A, rhs, u0, maxiter, tol);          % {En: Iterative(Symmetric): Conjugate Gradient}
    case 'cgs' 
        [u, ~] = cgs(A, rhs, tol, maxiter, [], [], u0);                 % {En: Iterative(Nonsymmetric): Conjugate Gradient Square}
    case 'pcg'   
        [u, ~] = pcg(A, rhs, tol, maxiter, [], [], u0);                 % {En: Iterative(Symmetric): Preconditioned Conjugate Gradient
    case 'ssor'   
        [u, ~] = pcg(A, rhs, tol, maxiter, M1, M2, u0);
    otherwise
        fprintf('Error method\n');
end