function panorama_reshaped = ConformalReshape2(V, panorama)
% 1 -- 2 -- 3
% |         |
% 6 -- 5 -- 4

F = [1 6 2;
     2 6 5;
     2 5 3;
     3 5 4];
V = [V, 0*V(:,1)];
for k = 1:5
    [V, F] = meshSubdivision(V, F);
end
V(:,3) = [];

% figure
% imshow(panorama);
% hold on
% trimesh(F, V(:,1), V(:,2), 0*V(:,1), 'FaceAlpha', 0);
% plot(V(1:6,1), V(1:6,2), 'r*');

CornerVid = [6; 4; 3; 1];
uv = SquareHarmonic(F, V, CornerVid);
[height, width, ~] = size(panorama);
uv(:,1) = width * uv(:,1);
uv(:,2) = height * uv(:,2);

AD = @(alpha) AngleDistortion(F, V, [alpha*uv(:,1), uv(:,2)]);
alpha = fminbnd(AD, 1, 10);
uv = [alpha*uv(:,1), uv(:,2)];

max_uv = max(uv);

width1 = round(max_uv(1));
height1 = round(max_uv(2));
uv(:,1) = uv(:,1) / max_uv(1) * width1;
uv(:,2) = uv(:,2) / max_uv(2) * height1;

[X1, Y1] = meshgrid(1:width1, 1:height1);
X1 = double(X1);
Y1 = double(Y1);
MapXY = SimplicialMap(F, uv, V, [X1(:), Y1(:)]);

R0 = double(panorama(:,:,1));
G0 = double(panorama(:,:,2));
B0 = double(panorama(:,:,3));

[X, Y] = meshgrid(1:width, 1:height);
X = double(X);
Y = double(Y);

tic
R = griddata(X, Y, R0, MapXY(:,1), MapXY(:,2));
G = griddata(X, Y, G0, MapXY(:,1), MapXY(:,2));
B = griddata(X, Y, B0, MapXY(:,1), MapXY(:,2));
toc

R = 255*R;
G = 255*G;
B = 255*B;

R = uint8(reshape(R, height1, width1));
G = uint8(reshape(G, height1, width1));
B = uint8(reshape(B, height1, width1));
panorama_reshaped = cat(3, R, G, B);
panorama_reshaped = flipud(panorama_reshaped);

% figure
% imshow(panorama_reshaped);
% hold on
% trimesh(F, uv(:,1), uv(:,2), 0*uv(:,1), 'FaceAlpha', 0);

