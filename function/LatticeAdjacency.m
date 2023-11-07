function A = LatticeAdjacency(h, w)
Ah =  sparse(1:h-1, 2:h,  1, h, h)...
    + sparse(2:h, 1:h-1,  1, h, h);
Aw =  sparse(1:w-1, 2:w,  1, w, w)...
    + sparse(2:w, 1:w-1,  1, w, w);
Ih = speye(h);
Iw = speye(w);
A = kron(Iw,Ah) + kron(Aw,Ih);