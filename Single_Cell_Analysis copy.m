%% Single Cell Analysis
warning('off');
for n = 1:20
%% Read in File
image = imread('Colorfused_lev8_pth-9-seg.tif');
Output_file_name = 'Colorfused_lev8_pth-9-seg.tif';

cell_num = '1'; 

%% Find Cutting Area
[x, y, BW, xi, yi] = roipoly(image);
BW = double(BW); 
close all

single_cell_image_frag = BW.*double(image(:,:,3));
single_cell_image_inter = BW.*double(image(:,:,2));
single_cell_image_elongated = BW.*double(image(:,:,1)); 

%%
recombined_image(:,:,1) = single_cell_image_elongated;
recombined_image(:,:,2) = single_cell_image_inter;
recombined_image(:,:,3) = single_cell_image_frag;

%%  Find properties of each mitochondria type

% Rethreshold whole image for each classification
thresh1 = graythresh(single_cell_image_frag);
frag_BW = im2bw(single_cell_image_frag, thresh1);

thresh2 = graythresh(single_cell_image_inter);
inter_BW = im2bw(single_cell_image_inter, thresh2);

thresh3 = graythresh(single_cell_image_elongated);
elongated_BW = im2bw(single_cell_image_elongated, thresh3); 

%% Find All properties for each image
[frag_label fragnum] = bwlabel(frag_BW);
[inter_label internum] = bwlabel(inter_BW);
[elong_label elongnum] = bwlabel(elongated_BW); 

fragmented = regionprops(frag_label, 'All');
intermediate = regionprops(inter_label, 'All');
elongated = regionprops(elong_label, 'All'); 

%% Find Properties of Each Cell

% Totals
total = fragnum + internum + elongnum;

frag_percent = fragnum/total;
inter_percent = internum/total;
elong_percent = elongnum/total; 

%% Average Lengths

%% In case there are zeros

if elongnum <= 0
    elong_areas = 0;
end
%% total area
for n= 1: size(fragmented,1)
frag_areas(n,1) = fragmented(n,1).Area;
end
frag_area = sum(frag_areas); 

for n= 1: size(intermediate,1)
inter_areas(n,1) = intermediate(n,1).Area;
end
inter_area = sum(inter_areas); 

for n= 1: size(elongated,1)
elong_areas(n,1) = elongated(n,1).Area;
end
elong_area = sum(elong_areas); 

%% Calculate Cell Size Properties
length = max(xi) - min(xi);
width = max(xi) - min(xi); 

cell_size =length*width; 

%% Whole Frame Properties

whole_image_frag = image(3,:,:); 
whole_image_inter = image(2,:,:); 
whole_image_elong = image(1,:,:); 

wprops_frag = regionprops(whole_image_frag);
wprops_inter = regionprops(whole_image_inter);
wprops_elong = regionprops(whole_image_elong);

%% Print out values
output = [fragnum, internum, elongnum, frag_area, inter_area,...
    elong_area, cell_size ]; 
%format long g
disp(output); 

%% Make output variable
printvalue(n,1) = fragnum;
printvalue(n,2) = internum;
printvalue(n,3) = elongnum;
printvalue(n,4) = frag_area;
printvalue(n,5) = inter_area;
printvalue(n,6) = elong_area;
printvalue(n,7) = cell_size;
%% Save image
imwrite(recombined_image, [cell_num Output_file_name ], 'tiff'); 
end
