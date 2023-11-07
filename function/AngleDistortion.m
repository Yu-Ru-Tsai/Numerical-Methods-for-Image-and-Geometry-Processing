function [MeanAD, StdAD, AngleDiffDeg] = AngleDistortion(F, V, U, option)
if nargin < 4
    option = 0;
end
AngleV = MeshAngle(V, F);
AngleU = MeshAngle(U, F);
AngleDiff = abs(AngleV - AngleU);
AngleDiffDeg = rad2deg(AngleDiff);
MeanAD = mean( AngleDiffDeg(:) );
StdAD = std( AngleDiffDeg(:) );
if option
fprintf( 'Mean of Angle Distortion : %f\n', MeanAD );
fprintf( 'SD   of Angle Distortion : %f\n', StdAD );
end

function Angle = MeshAngle(V, F)
[Vno, Dim] = size(V);
if Dim == 2
    V = [V, zeros(Vno,1)];
end
E1 = V(F(:,2),:)-V(F(:,3),:);
E2 = V(F(:,3),:)-V(F(:,1),:);
E3 = V(F(:,1),:)-V(F(:,2),:);
E1 = sqrt( sum(E1.^2, 2) );
E2 = sqrt( sum(E2.^2, 2) );
E3 = sqrt( sum(E3.^2, 2) );
Fno = size(F,1);
Angle = zeros(Fno,3);
Angle(:,1) = acos( ( E2.^2 + E3.^2 - E1.^2 ) ./ ( 2.*E2.*E3 ) );
Angle(:,2) = acos( ( E1.^2 + E3.^2 - E2.^2 ) ./ ( 2.*E1.*E3 ) );
Angle(:,3) = acos( ( E1.^2 + E2.^2 - E3.^2 ) ./ ( 2.*E1.*E2 ) );