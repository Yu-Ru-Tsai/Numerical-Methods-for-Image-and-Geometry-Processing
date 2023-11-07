function uv = SquareHarmonic(F, V, CornerVid)
% 4 -- 3
% |    |
% 1 -- 2
[VB, VI, Vno] = BoundaryIndex(F, V);
VBno = size(VB,1);
CornerVBid = knnsearch(VB, CornerVid);
C12 = SortVB(CornerVBid([1,2]), VBno);
C23 = SortVB(CornerVBid([2,3]), VBno);
C34 = SortVB(CornerVBid([3,4]), VBno);
C41 = SortVB(CornerVBid([4,1]), VBno);
uv = zeros(Vno,2);
uv(VB(C23),1) = 1;
uv(VB(C34),2) = 1;
L = LaplaceBeltrami(F, V);
VUD = [VB(C12(2:end-1)); VB(C34(2:end-1))];
VI1 = union(VI, VUD);
VB1 = VB([C23, C41]);
rhs = -L(VI1,VB1)*uv(VB1,1);
uv(VI1,1) = L(VI1,VI1)\rhs;
VLR = [VB(C23(2:end-1)); VB(C41(2:end-1))];
VI2 = union(VI, VLR);
VB2 = VB([C12, C34]);
rhs = -L(VI2,VB2)*uv(VB2,2);
uv(VI2,2) = L(VI2,VI2)\rhs;

function C12 = SortVB(CornerVBid, VBno)
if CornerVBid(1)>CornerVBid(2)
    C12 = [CornerVBid(1):VBno, 1:CornerVBid(2)];
else
    C12 = CornerVBid(1):CornerVBid(2);
end