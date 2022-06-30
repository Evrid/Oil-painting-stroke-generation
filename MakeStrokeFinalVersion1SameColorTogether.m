
% parts code from Painterly Rendering with Curved Brush Strokes of Multiple Sizes
%https://github.com/fionazeng3/Painterly-Rendering-with-Curved-Brush-Strokes-of-Multiple-Sizes
%if you don't want draw step by step then comment line 343 drawnow; by
%adding a %

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

                            strokeNum=strokeNum+1;  %every time we loop it we need add one number, will print total strokes later

                            XYMatrixWithColor(strokeNum,1)=x-tipX;   %the first row of XYMatrixWithColor store x-tipX which is begin position's x
                            XYMatrixWithColor(strokeNum,2)=y-tipY;  %the second row of XYMatrixWithColor store y-tipY which is begin position's y
                            XYMatrixWithColor(strokeNum,3)=x+tipX;  %third row end position's x
                            XYMatrixWithColor(strokeNum,4)=y+tipY;  %fourth row end position's y

                            StringStrokeRGB=squeeze(sourceImage(y,x,:));  %we get the origional pixel's color and set it as stroke's color
                           

                            XYMatrixWithColor(strokeNum,5)=StringStrokeRGB(1);
                            XYMatrixWithColor(strokeNum,6)=StringStrokeRGB(2);
                            XYMatrixWithColor(strokeNum,7)=StringStrokeRGB(3);

                             % above we put the color of the points with coordinates (RGB value on the 5th 6th 7th row) because easier to sort

 
                           

                            %plot([x-tipX x+tipX], [y-tipY y+tipY],'color',StringStrokeRGB,'LineWidth',3 )  //display dynamic plotting  
                            %drawnow;
                            %hold on;


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

%% Sort by color
%we want sort by color because if we actually draw, it will be more
%efficient to draw with one color then change to another color (no need to wash pen)
%you can also change the color of picture to below standard value using https://onlinepngtools.com/change-png-color
%you can also reduce the color of your image first

Black=  [0,0,0];
White=	[255,255,255];
Red=	[255,0,0];
Lime=	[0,255,0];
Blue=	[0,0,255];
Yellow=	[255,255,0];
Cyan=	[0,255,255];
Magenta=[255,0,255];
Silver=	[192,192,192];
Gray=	[128,128,128];
Maroon=	[128,0,0];
Olive=	[128,128,0];
Green=	[0,128,0];
Purple=	[128,0,128];
Teal=	[0,128,128];
Navy=	[0,0,128];

ColorToleranceR=50;   %if not get enough certain color then change this value
ColorToleranceG=80;
ColorToleranceB=60;

BlackStrokes=SortRGB(Black,XYMatrixWithColor,strokeNum,ColorToleranceR,ColorToleranceG,ColorToleranceB);  
WhiteStrokes=SortRGB(White,XYMatrixWithColor,strokeNum,ColorToleranceR,ColorToleranceG,ColorToleranceB);
RedStrokes=SortRGB(Red,XYMatrixWithColor,strokeNum,ColorToleranceR,ColorToleranceG,ColorToleranceB);
LimeStrokes=SortRGB(Lime,XYMatrixWithColor,strokeNum,ColorToleranceR,ColorToleranceG,ColorToleranceB);
BlueStrokes=SortRGB(Blue,XYMatrixWithColor,strokeNum,ColorToleranceR,ColorToleranceG,ColorToleranceB);
YellowStrokes=SortRGB(Yellow,XYMatrixWithColor,strokeNum,ColorToleranceR,ColorToleranceG,ColorToleranceB);
CyanStrokes=SortRGB(Cyan,XYMatrixWithColor,strokeNum,ColorToleranceR,ColorToleranceG,ColorToleranceB);
MagentaStrokes=SortRGB(Magenta,XYMatrixWithColor,strokeNum,ColorToleranceR,ColorToleranceG,ColorToleranceB);
SilverStrokes=SortRGB(Silver,XYMatrixWithColor,strokeNum,ColorToleranceR,ColorToleranceG,ColorToleranceB);
GrayStrokes=SortRGB(Gray,XYMatrixWithColor,strokeNum,ColorToleranceR,ColorToleranceG,ColorToleranceB);
MaroonStrokes=SortRGB(Maroon,XYMatrixWithColor,strokeNum,ColorToleranceR,ColorToleranceG,ColorToleranceB);
OliveStrokes=SortRGB(Olive,XYMatrixWithColor,strokeNum,ColorToleranceR,ColorToleranceG,ColorToleranceB);
GreenStrokes=SortRGB(Green,XYMatrixWithColor,strokeNum,ColorToleranceR,ColorToleranceG,ColorToleranceB);
PurpleStrokes=SortRGB(Purple,XYMatrixWithColor,strokeNum,ColorToleranceR,ColorToleranceG,ColorToleranceB);
TealStrokes=SortRGB(Teal,XYMatrixWithColor,strokeNum,ColorToleranceR,ColorToleranceG,ColorToleranceB);
NavyStrokes=SortRGB(Navy,XYMatrixWithColor,strokeNum,ColorToleranceR,ColorToleranceG,ColorToleranceB);

%% Display number of strokes

Disp1=['total number of stroke for Black is: '];
disp(Disp1);
disp (size(BlackStrokes,1))  %we count rows to find how many strokes it is

Disp2=['total number of stroke for White is: '];
disp(Disp2);
disp (size(WhiteStrokes,1))  %we count rows to find how many strokes it is

Disp3=['total number of stroke for Red is: '];
disp(Disp3);
disp (size(RedStrokes,1))  %we count rows to find how many strokes it is

Disp4=['total number of stroke for Lime is: '];
disp(Disp4);
disp (size(LimeStrokes,1))  %we count rows to find how many strokes it is

Disp5=['total number of stroke for Blue is: '];
disp(Disp5);
disp (size(BlueStrokes,1))  %we count rows to find how many strokes it is

Disp6=['total number of stroke for Yellow is: '];
disp(Disp6);
disp (size(YellowStrokes,1))  %we count rows to find how many strokes it is

Disp7=['total number of stroke for Cyan is: '];
disp(Disp7);
disp (size(CyanStrokes,1))  %we count rows to find how many strokes it is

Disp8=['total number of stroke for Magenta is: '];
disp(Disp8);
disp (size(MagentaStrokes,1))  %we count rows to find how many strokes it is

Disp9=['total number of stroke for Silver is: '];
disp(Disp9);
disp (size(SilverStrokes,1))  %we count rows to find how many strokes it is

Disp10=['total number of stroke for Gray is: '];
disp(Disp10);
disp (size(GrayStrokes,1))  %we count rows to find how many strokes it is

Disp11=['total number of stroke for Maroon is: '];
disp(Disp11);
disp (size(MaroonStrokes,1))  %we count rows to find how many strokes it is

Disp12=['total number of stroke for Olive is: '];
disp(Disp12);
disp (size(OliveStrokes,1))  %we count rows to find how many strokes it is

Disp13=['total number of stroke for Green is: '];
disp(Disp13);
disp (size(GreenStrokes,1))  %we count rows to find how many strokes it is

Disp14=['total number of stroke for Purple is: '];
disp(Disp14);
disp (size(PurpleStrokes,1))  %we count rows to find how many strokes it is

Disp15=['total number of stroke for Teal is: '];
disp(Disp15);
disp (size(TealStrokes,1))  %we count rows to find how many strokes it is

Disp16=['total number of stroke for Navy is: '];
disp(Disp16);
disp (size(NavyStrokes,1))  %we count rows to find how many strokes it is

%% Sum of all strokes then draw it

SumOfStrokeInColorOrder=[BlackStrokes;WhiteStrokes;RedStrokes;LimeStrokes;BlueStrokes;YellowStrokes;CyanStrokes;MagentaStrokes;SilverStrokes;GrayStrokes;MaroonStrokes;OliveStrokes;GreenStrokes;PurpleStrokes;TealStrokes;NavyStrokes];

%the order is BlackStrokes;WhiteStrokes;RedStrokes;LimeStrokes;BlueStrokes;YellowStrokes;CyanStrokes;MagentaStrokes;SilverStrokes;GrayStrokes;MaroonStrokes;OliveStrokes;GreenStrokes;PurpleStrokes;TealStrokes;NavyStrokes

writematrix(SumOfStrokeInColorOrder,'test.txt');   
%we write SumOfStrokeInColorOrder in test.txt, order
% is [x-tipX, y-tipY, x+tipX, y+tipY, GotR, GotG, GotB, UseR, UseG, UseB]
%we have UseR UseG because we have limited paint in hand, don't have all
%color got on picture

%% Draw it

for ooo=1:size(SumOfStrokeInColorOrder,1)
    RGBForEachStroke=[SumOfStrokeInColorOrder(ooo,8) SumOfStrokeInColorOrder(ooo,9) SumOfStrokeInColorOrder(ooo,10)];
      plot([SumOfStrokeInColorOrder(ooo,1) SumOfStrokeInColorOrder(ooo,3)], [SumOfStrokeInColorOrder(ooo,2) SumOfStrokeInColorOrder(ooo,4)],'color',ScaleDown(RGBForEachStroke),'LineWidth',3 )  %display dynamic plotting  
      %here we write as above because we want plot a line, and write as : plot([x1 x2], [y1 y2],'color',xxxxx,'LineWidth',3) 
      
      drawnow;
      hold on;
end



%% Sort RGB function
%we want sort RGB on the picture to one of the standard color we gave
%earlier (since we have limited paint)
function vvv = SortRGB(RGB,XYMatrixWithColorr,strokeNumm,ColorToleranceRR,ColorToleranceGG,ColorToleranceBB)   %we need stroke numm here because it is within the function
PointsOfTheColor=[0 0 0 0 0 0 0 0 0 0];
 for iii=1: strokeNumm 

     % see if R match first including tolerance, we use this because is easier to see
     if (RGB(1)-ColorToleranceRR)<XYMatrixWithColorr(iii,5) && XYMatrixWithColorr(iii,5) <(RGB(1)+ColorToleranceRR)
       RMatch=1;
     else
       RMatch=0;  
     end

     if (RGB(2)-ColorToleranceGG)<XYMatrixWithColorr(iii,6) && XYMatrixWithColorr(iii,6) <(RGB(2)+ColorToleranceGG)
       GMatch=1;
     else
       GMatch=0;  
     end

     if (RGB(3)-ColorToleranceBB)<XYMatrixWithColorr(iii,7) && XYMatrixWithColorr(iii,7) <(RGB(3)+ColorToleranceBB)
       BMatch=1;
     else
       BMatch=0;  
     end


     if RMatch==1 && GMatch==1 && BMatch==1

       PointsOfTheColor=[PointsOfTheColor;XYMatrixWithColorr(iii,1) XYMatrixWithColorr(iii,2) XYMatrixWithColorr(iii,3) XYMatrixWithColorr(iii,4) XYMatrixWithColorr(iii,5) XYMatrixWithColorr(iii,6) XYMatrixWithColorr(iii,7) RGB(1) RGB(2) RGB(3)];
       
 %can use this line or not      %XYMatrixWithColorr(iii,:)=0;  %after we assign the color we replace that row with 0 means the stroke is taken and won't have multiple color

     %Append rows at the end of Matrix each time condition is met, then we
     %append the color we are going to use as well
     %so the total matrix is [x-tipX, y-tipY, x+tipX, y+tipY, GotR, GotG, GotB, UseR, UseG, UseB]
     %GotR is the R value we got by squeeze the origional image, useR is
     %the actual R we will use to paint

     end
 end
 vvv=PointsOfTheColor;
end


%% Scale RGB function
%we need it because when draw it accept value between 0 to 1, and what we
%got is 0 to255
function ScaledRGB = ScaleDown(RGBname)
RGBname(1)=RGBname(1)/255;
RGBname(2)=RGBname(2)/255;
RGBname(3)=RGBname(3)/255;
ScaledRGB=RGBname;
end

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







