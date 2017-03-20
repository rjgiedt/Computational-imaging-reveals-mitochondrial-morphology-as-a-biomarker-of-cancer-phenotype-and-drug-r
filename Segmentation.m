%% Setup
clc;	% Clear command window.
clear;	% Delete all variables.
close all;	% Close all figure windows except those created by imtool.
imtool close all;	% Close all figure windows created by imtool.
workspace;	% Make sure the workspace panel is showing.
fontSize = 16;

%% Load Image
original_image = imread('testimage.tif');
folderName = '1';

%% Background Subtraction
disk_size = 10; 
se2 = strel('disk',disk_size); 

background = imopen(original_image, se2);
background_subtracted = original_image - background;
background_subtracted_inverse = imadjust(background_subtracted, [0 1], [1 0]);

%% Implement Huang
[T, threshold] = huangentropy2(background_subtracted);

%% Filter Image for artifacts

disk_size = 4; 

% Filter Dapi regions
se2 = strel('disk',disk_size); 
Final2 = im2double(T);
Io = imopen(Final2,se2);
Ie = imerode(Final2, se2);
Iobr = imreconstruct(Ie, Final2);
Iobrd = imdilate(Iobr, se2);
Iobrcbr = imreconstruct(imcomplement(Iobrd), imcomplement(Iobr));
Iobrcbr = imcomplement(Iobrcbr);
Final_Filtered = Iobrcbr;

%% Imoverlay of original image
labeled = bwlabel(Final_Filtered);
outline = bwperim(labeled);
overlay = imoverlay(imadjust(original_image, stretchlim(original_image,0)), outline, [1 .2 .2]);

%% Save Segmented Final Images
figure; imshow(imadjust(original_image)); 
figure; imshow(overlay);
figure; imshow(Iobrcbr); 

%% Save Segmented Images
mkdir(folderName)

original_image_adj = imadjust(original_image); 
imwrite(original_image_adj,'original_image_2.tiff');
imwrite(overlay, 'Overlay_2.tiff');
imwrite(Iobrcbr, 'Segmented_2.tiff');

%% h 

h = [ -1 -1 -1 -1 -1
      -1 -1 -1 -1 -1
      -1 -1 50 -1 -1
       -1 -1 -1 -1 -1 
       -1 -1 -1 -1 -1];