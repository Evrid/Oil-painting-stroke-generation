# Oil-painting-stroke-generation

% parts code from Painterly Rendering with Curved Brush Strokes of Multiple Sizes
%https://github.com/fionazeng3/Painterly-Rendering-with-Curved-Brush-Strokes-of-Multiple-Sizes

It generate strokes with start and end point with color from a picture, the points can be used in robotarm or CNC to actually paint it.


Required:
    MATLAB R2022a or later
    Image Processing Toolbox
    Computer Vision System Toolbox
    Statistics and Machine Learning Toolbox
    Robotics System Toolbox

----------------------------------
MakeStrokeFinalVersion2DifferentColor.m

The result see
https://www.youtube.com/watch?v=cV7cfhHnwPc
and 'result of MakeStrokeFinalVersion2DifferentColor.png'

after begin, it ask you to select an image, best be small like 35k, too big take too long time, you can choose 'reduced8colors.JPG'

%% paint
%At the highest level of this painting algorithm, I first created an empty canvas. Using a for loop, 
% I blurred the image with Gaussian low-pass filter and obtain the stroke layer of 
% each brush size from the paintLayer function. 
% In each iteration, I masked the stroke layer onto the canvas and cumulatively made a complete painting.

%% paint layer

%search each grid point’s
%neighborhood to find the nearby point with the greatest error
%and paint at this location.

output will be in the 'text.txt' will be [StartPointX, StartPointY, EndPointX, EndPointY, GotR, GotG, GotB]

----------------------------------
MakeStrokeFinalVersion1SameColorTogether.m

the result see 'MakeStrokeFinalVersion1SameColorTogether.jpg'

after begin, it ask you to select an image, best be small like 35k, too big take too long time, you can choose 'reduced8colors.JPG'

%% paint
%At the highest level of this painting algorithm, I first created an empty canvas. Using a for loop, 
% I blurred the image with Gaussian low-pass filter and obtain the stroke layer of 
% each brush size from the paintLayer function. 
% In each iteration, I masked the stroke layer onto the canvas and cumulatively made a complete painting.

%% paint layer

%search each grid point’s
%neighborhood to find the nearby point with the greatest error
%and paint at this location.

%% Sort by color
%we want sort by color because if we actually draw, it will be more
%efficient to draw with one color then change to another color (no need to wash pen)
%you can also change the color of picture to below standard value using https://onlinepngtools.com/change-png-color
%you can also reduce the color of your image first


output will be in the 'text.txt' with [StartPointX, StartPointY, EndPointX, EndPointY, GotR, GotG, GotB, UseR, UseG, UseB]



