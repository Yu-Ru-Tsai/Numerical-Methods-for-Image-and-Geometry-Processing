function y = shrink1(x, alpha)
y = sign(x).*max(0,abs(x)-alpha);