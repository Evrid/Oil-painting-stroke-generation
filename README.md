# Oil-painting-stroke-generation

% parts code from Painterly Rendering with Curved Brush Strokes of Multiple Sizes
%https://github.com/fionazeng3/Painterly-Rendering-with-Curved-Brush-Strokes-of-Multiple-Sizes

It generate strokes with start and end point with color from a picture, the points can be used in robotarm or CNC to actually paint it.

Best first reduce the number of color an image has using  https://onlinejpgtools.com/reduce-jpg-colors


Required:
    MATLAB R2022a or later
    Image Processing Toolbox
    Computer Vision System Toolbox
    Statistics and Machine Learning Toolbox
    Robotics System Toolbox

----------------------------------
MakeStrokeFinalVersion2DifferentColor.m

in this file, the order of stroke is not by color.

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

in this file, the order of stroke is by color and is drawn with standardized color.

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

----------------------------------
Some other similar projects:

ERB322 Oil Painting Robot
https://www.youtube.com/watch?v=2okNLX5593A

If ( ) Then {Paint}
https://hackaday.io/project/166524-if-then-paint

IfThenPaint_Image2Gcode
https://github.com/johnopsahl/IfThenPaint_Image2Gcode

----------------------------------
other useful links

png color replacer
https://onlinepngtools.com/change-png-color

image compressor
https://imagecompressor.com/

image color picker
https://pinetools.com/image-color-picker

RGB color
https://www.rapidtables.com/web/color/RGB_Color.html









