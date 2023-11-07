function Val = MSE(U,T)
U = double(U);
T = double(T);
Val = mean((U-T).^2, 'all');