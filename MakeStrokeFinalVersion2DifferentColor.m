
% parts code from Painterly Rendering with Curved Brush Strokes of Multiple Sizes
%https://github.com/fionazeng3/Painterly-Rendering-with-Curved-Brush-Strokes-of-Multiple-Sizes
%if don't want see draw step by step, then comment drawnow; in line 182 (by adding a %)

close all; clear all; clc;

sourceImage = imread(uigetfile);  % you choose All file type then choose 'reduced8colors.JPG' I uploaded
%sourceImage=imread('reduced8colors.JPG');
R = [8,6,4, 2];

strokeNum=0;   %calculate how many strokes we have

%% parameters 


ThresholdOfError=2;    %the larger the less exquisite

strokeNum=0;

maxStrokeLength = 1;   %the larger the less exquisite
minStrokeLength = 0.5;   %the larger the less exquisite

fc = 0.1;  %was 0.25 the larger the less exquisite


%% paint
%At the highest level of this painting algorithm, I first created an empty canvas. Using a for loop, 
% I blurred the image with Gaussian low-pass filter and obtain the stroke layer of 
% each brush size from the paintLayer function. 
% In each iteration, I masked the stroke layer onto the canvas and cumulatively made a complete painting.

[row, column] = size(sourceImage(:,:,1));
canvas = zeros(row, column, 3);
canvas = double(canvas);

for k = 1:length(R)
    referenceImage = sourceImage;


%% paint layer

%search each grid point’s
%neighborhood to find the nearby point with the greatest error
%and paint at this location.


    layer = zeros(size(canvas));
    referenceImage = double(referenceImage);
    L = 0.3 * referenceImage(:,:,1) + 0.59 *referenceImage(:,:,2) + 0.11 * referenceImage(:,:,3);
    [gradientX, gradientY] = gradient(L);
    G = sqrt(gradientX .^2 + gradientY .^2);
    diff = referenceImage - canvas;
    D = sqrt(double(diff(:,:,1)).^2 + double(diff(:,:,2)).^2 + double(diff(:,:,3)).^2);
    grid = R(k);
    T = ThresholdOfError;  %was 50, can set manually
     ygrid = grid:grid:size(referenceImage,1)-grid;
     xgrid = grid:grid:size(referenceImage,2)-grid;
     yorder = ygrid(randperm(length(ygrid)));
     xorder = xgrid(randperm(length(xgrid)));


    for x0 = 1:length(xorder)
        j = xorder(x0)-(grid/2)+1:xorder(x0)+(grid/2);
        for y0 = 1:length(yorder)
             i = yorder(y0)-(grid/2)+1:yorder(y0)+(grid/2);
           % sum the error near (x,y)
            M = D(i,j);
            areaError = sum(sum(M))/(grid*grid);
            if(areaError > T)
                %find the largest error point
                [~, id] = max(M(:));
                [yi, xi] = ind2sub(size(M), id);
                 y1 = yorder(y0) + yi;
                 x1 = xorder(x0) + xi;
 
%% make stroke


   
    S = [x1 y1];
    x = x1;
    y = y1;
    lastDx = 0;
    lastDy = 0;
    strokeRGB = referenceImage(y1, x1, :);

    [row, column] = size(referenceImage(:,:,1));
    for i = 1: maxStrokeLength + 1
        %detect color difference
        isDiff = isColorDiff(referenceImage, canvas, x1, y1, x, y);
        if(i >  minStrokeLength && isDiff == 1)
            break;
        end
        %detect vanishing gradient
        Gx = gradientX(y,x);
        Gy = gradientY(y,x);
        if(G(y,x) == 0)
            break
        end
        %compute a normal direction
        dx = -Gy;
        dy = Gx;
        %if necessary, reverse direction
        if(lastDx * dx + lastDy*dy < 0)
            dx = -dx;
            dy = -dy;
        end
        %filter the stroke direction
       
        dx = fc .* dx + (1-fc) .* lastDx;
        dy = fc .* dy + (1-fc) .* lastDy;
        dx_norm = dx ./ sqrt(dx * dx + dy*dy);
        dy_norm = dy ./sqrt(dx * dx + dy*dy);
        x = x + R(k)*dx_norm;
        y = y + R(k)*dy_norm;
        x = floor(x + R(k)*dx);
        y = floor(y + R(k)*dy);
        xy = [x, y];
        isValid = isValidPoint(x, y, row, column);
        if(isValid == 0)
            break;
        end
        lastDx = dx_norm;
        lastDy = dy_norm;
        S = [S;xy];


    end

              
                strokeRGB = double(strokeRGB);




                if ~isempty(S)
                    tip = circle(R(k)); 
                    tipX = floor(size(tip,2)/2);
                    tipY = floor(size(tip,1)/2);
                    tipR = tip*strokeRGB(1,1,1);
                    tipG = tip*strokeRGB(1,1,2);
                    tipB = tip*strokeRGB(1,1,3);
                    brush = cat(3,tipR,tipG,tipB);
                    [py,px] = size(S);
                    for p = 1: py
                        point = S(p,:);
                        x = point(1,1);
                        y = point(1,2);
                        xMax = size(referenceImage,2) - tipX;
                        xMin = 1 + tipX;
                        yMax = size(referenceImage,1) - tipY;
                        yMin = 1 + tipY;
                        % paints stroke on layer
                        if x >= xMin && x <= xMax && y >= yMin && y <= yMax
                            area = layer(y-tipY:y+tipY,x-tipX:x+tipX,1:3);
                            painted = (brush.*area ~= 0);
                            clean = (painted == 0);
                            layer(y-tipY:y+tipY,x-tipX:x+tipX,1:3) = area + brush.*clean;

                            strokeNum=strokeNum+1;

                            XYMatrixWithColor(strokeNum,1)=x-tipX;   %the first row of XYMatrixWithColor store x-tipX which is begin position's x
                            XYMatrixWithColor(strokeNum,2)=y-tipY;  %the second row of XYMatrixWithColor store y-tipY which is begin position's y
                            XYMatrixWithColor(strokeNum,3)=x+tipX;   %third row end position's x
                            XYMatrixWithColor(strokeNum,4)=y+tipY;   %fourth row end position's y

                            StringStrokeRGB=squeeze(sourceImage(y,x,:));
                            % we put the color of the points with
                            % coordinates because easier to sort

                            XYMatrixWithColor(strokeNum,5)=StringStrokeRGB(1);
                            XYMatrixWithColor(strokeNum,6)=StringStrokeRGB(2);
                            XYMatrixWithColor(strokeNum,7)=StringStrokeRGB(3);

                             % above we put the color of the points with coordinates (RGB value on the 5th 6th 7th row) because easier to sort

 
                           

                            plot([x-tipX x+tipX], [y-tipY y+tipY],'color',StringStrokeRGB,'LineWidth',3 )  %display dynamic plotting  
                            drawnow;
                            hold on;


                        end
                    end
                end
            end
        end
    end


   % layer = paintLayer(canvas,referenceImage, R(k));
    blank = (layer == 0);
    notLayer = canvas.*blank;

   %%%imshow(uint8(canvas));   %show gradual change process

    canvas = (canvas).*(canvas ~= 0).*(blank) +(canvas ~=0).*(layer ~= 0).*(layer) +(notLayer + layer).*(canvas == 0);
    
end
canvas = uint8(canvas);

oilPaint = canvas;
%%%imshow(oilPaint);

DisplayStroke=['total number of stroke is: '];
disp(DisplayStroke);
disp(strokeNum);


writematrix(XYMatrixWithColor,'test.txt');   %export the matrix to test.txt


%% isValidPoint

function isValid = isValidPoint(x, y, row, column)
if (x >= 1 && x <= column && y >= 1 && y <= row)
    isValid = 1;
else 
    isValid = 0;
end
end

%% is color diff

function isDiff = isColorDiff(referenceImage, canvas, x0, y0, x, y)
    %|refImage.color(x,y)-canvas.color(x,y)|<|refImage.color(x,y)-strokeColor|)
    left = norm(double(referenceImage(y,x) - canvas(y,x)));
    right = norm(double(referenceImage(y,x) -referenceImage(y0,x0)));


    if(left < right)
        isDiff = 1;
    else 
        isDiff = 0;
    end
end

%% creates circular brush element for a given radius

function c = circle(R)
% creates circular brush element for a given radius
if R < 3 % keeps non-zero brush element circular and not square
    R = R + 1;
end
c = zeros(R);
for x = R:-1:1 % for one quadrant of circle
    y = (R^2 - (x-1)^2)^(1/2);
    y = floor(y);
    c(y:-1:1,x) = ones(y,1);
end
% forms circle out of quadrant
c = [c(end:-1:2,end:-1:2), c(end:-1:2,:); c(:,end:-1:2), c];
end







