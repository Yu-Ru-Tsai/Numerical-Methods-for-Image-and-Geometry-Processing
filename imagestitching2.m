clear;close all;
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% fprintf('Loading Image & Reset  ');
tic;

Ifile = imageDatastore('footage/myhouse2-1080');
proj(2) = projective2d(eye(3));
I1 = readimage(Ifile, 1);
grayI1 = im2gray(I1);
Isize = size(grayI1);
I2 = readimage(Ifile, 2);
grayI2 = im2gray(I2); 

% Timesum = 0;
% toc;Timesum = Timesum + toc;
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% fprintf('Selecting Good Matches :\n');
% fprintf('Unused  ')
% tic;

grayI1( : , 1 : (Isize(1, 2) / 3)) = 0;
grayI2( : , (Isize(1, 2) * 2 / 3) : end) = 0;

% toc;Timesum = Timesum + toc;
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% fprintf('Detect  ')
% tic;

points1 = detectSIFTFeatures(grayI1);
points2 = detectSIFTFeatures(grayI2);

% toc;Timesum = Timesum + toc;
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% fprintf('Extract ')
% tic;

[features1, points11] = extractFeatures(grayI1, points1);
[features2, points22] = extractFeatures(grayI2, points2);
indexPAIRS = matchFeatures(features1, features2, 'Unique', true);
matchedPoints11 = points11(indexPAIRS(:,1), :); 
matchedPoints12 = points22(indexPAIRS(:,2), :);

% toc;Timesum = Timesum + toc;
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% fprintf('Offsets ')
% tic;

vector = matchedPoints11.Location - matchedPoints12.Location;
vectormean = mean(vector( : , : ));
vectorstd = std(vector( : , : ));
indexoffsetsdel = (((abs(vector(:,1)-vectormean(1))) > (vectorstd(1)*2)) ...
    | ((abs(vector(:,2)-vectormean(2))) > (vectorstd(2)*2)));
indexPAIRS(indexoffsetsdel, :) = [];
matchedPoints11 = points11(indexPAIRS(:,1), :); 
matchedPoints12 = points22(indexPAIRS(:,2), :);

% toc;Timesum = Timesum + toc;
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% fprintf('Section ')
% tic;

vectorup = matchedPoints11.Location - matchedPoints12.Location;
vectoruppos = (matchedPoints11.Location(:,2)<Isize(1,1)/3);
vectorupmean = mean(vectorup(vectoruppos, : ));
vectorupstd = std(vectorup(vectoruppos, : ));

indexdelup = ((vectoruppos(:) == 1) ...
    & (((abs(vectorup(:, 1) - vectorupmean(1))) > (vectorupstd(1) * 1)) ...
    | ((abs(vectorup(:, 2) - vectorupmean(2))) > ((vectorupstd(2)) * 1))));
indexPAIRS(indexdelup, :) = [];
matchedPoints11 = points11(indexPAIRS(:,1), :); 
matchedPoints12 = points22(indexPAIRS(:,2), :);

vectormid = matchedPoints11.Location - matchedPoints12.Location;
vectorposmid = ((matchedPoints11.Location(:,2)>Isize(1,1)/3) & (matchedPoints11.Location(:,2)<Isize(1,1)*2/3));
vectormeanmid = mean(vectormid(vectorposmid, : ));
vectorstdmid = std(vectormid(vectorposmid, : ));

indexdelmid = ((vectorposmid == 1) ...
    & (((abs(vectormid(:, 1) - vectormeanmid(1))) > (vectorstdmid(1) * 1)) ...
    | ((abs(vectormid(:, 2) - vectormeanmid(2))) > ((vectorstdmid(2)) * 1))));

indexPAIRS(indexdelmid, :) = [];
matchedPoints11 = points11(indexPAIRS(:,1), :);
matchedPoints12 = points22(indexPAIRS(:,2), :);

vectordown = matchedPoints11.Location - matchedPoints12.Location;
vectorposdown = (matchedPoints11.Location(:,2)>Isize(1,1)*2/3);
vectormeandown = mean(vectordown(vectorposdown, : ));
vectorstddown = std(vectordown(vectorposdown, : ));

indexdeldown = ((vectorposdown == 1) ...
    & (((abs(vectordown(:, 1) - vectormeandown(1))) > (vectorstddown(1) * 1)) ...
    | ((abs(vectordown(:, 2) - vectormeandown(2))) > ((vectorstddown(2)) * 1))));
indexPAIRS(indexdeldown, :) = [];
matchedPoints11 = points11(indexPAIRS(:,1), :); 
matchedPoints12 = points22(indexPAIRS(:,2), :);

% figure; ax = axes;
% showMatchedFeatures(I1, I2, matchedPoints11, matchedPoints12, 'montage', 'Parent', ax);
    
% toc;Timesum = Timesum + toc;
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% fprintf('Calculating Proj       ');
% tic;

proj(2) = estimateGeometricTransform2D(matchedPoints12, matchedPoints11, ...
    'projective', 'Confidence', 99.99, 'MaxNumTrials', 100000);
Projinv = proj(1);
Projinv.T = (invert(proj(1)).T + invert(proj(2)).T) / 2;


proj(1).T = proj(1).T * Projinv.T;
proj(2).T = proj(2).T * Projinv.T;

% toc;Timesum = Timesum + toc;
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% fprintf('Calculating Pano Area  ');
% tic;

[xlim(1,:), ylim(1,:)] = outputLimits(proj(1), [1 Isize(1,2)], [1 Isize(1,1)]);
[xlim(2,:), ylim(2,:)] = outputLimits(proj(2), [1 Isize(1,2)], [1 Isize(1,1)]);
xMin = min([1; xlim(:)]);xMax = max([Isize(1,2); xlim(:)]);
yMin = min([1; ylim(:)]);yMax = max([Isize(1,1); ylim(:)]);
width  = round(xMax - xMin);
height = round(yMax - yMin);
panorama = zeros([height width 3], 'like', I2);
xLimits = [xMin xMax];
yLimits = [yMin yMax];
panoramaView = imref2d([height width], xLimits, yLimits);
warpedImage1 = imwarp(I1, proj(1), 'OutputView', panoramaView);
warpedImage2 = imwarp(I2, proj(2), 'OutputView', panoramaView);

% toc;Timesum = Timesum + toc;
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% fprintf('Calculating Mask :\n');
% fprintf('Creating Masks ');
% tic;

mask1 = imwarp(ones(size(I1,1),size(I1,2)), proj(1), 'OutputView', panoramaView);
mask2 = imwarp(ones(size(I2,1),size(I2,2)), proj(2), 'OutputView', panoramaView);

% toc;Timesum = Timesum + toc;
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% fprintf('Dots           ');
% tic;

[Jj1,Ii1] = find(mask1 > max(mask1(:)) / 2);
IJ1 = [Jj1, Ii1];
[~, idxx1] = min(IJ1 * [1 1; -1 1; 1 -1; -1 -1].');
Cornerss1 = IJ1(idxx1, :);
x1 = Cornerss1(:, 2);
y1 = Cornerss1(:, 1);

[Jj2, Ii2] = find(mask2 > max(mask2(:)) / 2);
IJ2 = [Jj2, Ii2];
[~, idxx2] = min(IJ2 * [1 1; -1 1; 1 -1; -1 -1].');
Cornerss2 = IJ2(idxx2, :);
x2 = Cornerss2(:, 2);
y2 = Cornerss2(:, 1);

a1u=[ x1(1), y1(1) ];
b1u=[ x1(3), y1(3) ];
a2u=[ x2(1), y2(1) ];
b2u=[ x2(3), y2(3) ];
[Xu, Yu]=node(a1u, b1u, a2u, b2u);
a1d=[ x1(2), y1(2) ];
b1d=[ x1(4), y1(4) ];
a2d=[ x2(2), y2(2) ];
b2d=[ x2(4), y2(4) ];
[Xd, Yd]=node(a1d, b1d, a2d, b2d);
maskmix = round(( mask1 + mask2 ) * 0.4 );

% toc;Timesum = Timesum + toc;
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% fprintf('Lines          ');
% tic;

[alllines(1,:)]=linefunc(x2(1),y2(1),floor(Xu),ceil(Yu));%leftupline
[alllines(2,:)]=linefunc(floor(Xu),ceil(Yu),x1(3),y1(3));%rightupline
[alllines(3,:)]=linefunc(x1(3),y1(3),x1(4),y1(4));%rightline
[alllines(4,:)]=linefunc(x1(4),y1(4),floor(Xd),floor(Yd));%rightdownline
[alllines(5,:)]=linefunc(floor(Xd),floor(Yd),x2(2),y2(2));%leftdownline
[alllines(6,:)]=linefunc(x2(2),y2(2),x2(1),y2(1));%leftline

% toc;Timesum = Timesum + toc;
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% fprintf('Fill Mask      ');
% tic;

maskright = maskmix;
maskleft = maskmix;
masksize = size(maskmix);
indexmask = find(maskmix == 1);
[y, x] = ind2sub(masksize, indexmask);
maskrighttemp = ratio(x, y, alllines);
masklefttemp = 1 - maskrighttemp;
maskright(indexmask) = maskrighttemp;
maskleft(indexmask) = masklefttemp;

% toc;Timesum = Timesum + toc;
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% fprintf('Producing Panoramic    ');
% tic;

warpedImage1=double(warpedImage1)/255;
warpedImage2=double(warpedImage2)/255;
panorama=double(panorama)/255;
panorama = panorama + warpedImage1 .* (mask1-maskmix);%figure;imshow(panorama);
panorama = panorama + warpedImage2 .* (mask2-maskmix);%figure;imshow(panorama);
panorama = panorama + warpedImage1 .* maskleft;%figure;imshow(panorama);
panorama = panorama + warpedImage2 .* maskright;figure;imshow(panorama);

toc;
% Timesum = Timesum + toc;
% fprintf(['*************************************Sum : %3.6f ' ...
%     'seconds*************************************\n'], Timesum)
%=====================================================================
function [X, Y] = node( X1,Y1,X2,Y2 )
    if X1(1)==Y1(1)
        X=X1(1);
        k2=(Y2(2)-X2(2))/(Y2(1)-X2(1));
        b2=X2(2)-k2*X2(1); 
        Y=k2*X+b2;
    end
    if X2(1)==Y2(1)
        X=X2(1);
        k1=(Y1(2)-X1(2))/(Y1(1)-X1(1));
        b1=X1(2)-k1*X1(1);
        Y=k1*X+b1;
    end
    if X1(1)~=Y1(1)&&X2(1)~=Y2(1)
        k1=(Y1(2)-X1(2))/(Y1(1)-X1(1));
        k2=(Y2(2)-X2(2))/(Y2(1)-X2(1));
        b1=X1(2)-k1*X1(1);
        b2=X2(2)-k2*X2(1);
        if k1==k2
            X=[];
            Y=[];
        else
            X=(b2-b1)/(k1-k2);
            Y=k1*X+b1;
        end
    end
end
%=====================================================================
function [line] = linefunc(x1,y1,x2,y2)
    if x1==x2
        line=[1,0,-x1];
    else
        line=[y2-y1,x1-x2,(x2-x1)*y1+(y1-y2)*x1];
    end
end
%=====================================================================
function [d] = ratio(x, y, alllines)
    wlu=(abs(alllines(1,1)*x+alllines(1,2)*y+alllines(1,3))/sqrt(alllines(1,1)^2+alllines(1,2)^2));
    wl =(abs(alllines(6,1)*x+alllines(6,2)*y+alllines(6,3))/sqrt(alllines(6,1)^2+alllines(6,2)^2));
    wld=(abs(alllines(5,1)*x+alllines(5,2)*y+alllines(5,3))/sqrt(alllines(5,1)^2+alllines(5,2)^2));
    wru=(abs(alllines(2,1)*x+alllines(2,2)*y+alllines(2,3))/sqrt(alllines(2,1)^2+alllines(2,2)^2));
    wr =(abs(alllines(3,1)*x+alllines(3,2)*y+alllines(3,3))/sqrt(alllines(3,1)^2+alllines(3,2)^2));
    wrd=(abs(alllines(4,1)*x+alllines(4,2)*y+alllines(4,3))/sqrt(alllines(4,1)^2+alllines(4,2)^2));
    w1 =min([wlu wl wld], [], 2);
    w2 =min([wru wr wrd], [], 2);
    d = w1 ./ ( w1 + w2);
end