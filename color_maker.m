%% Create Jonathan Image

red = im2double(labeled == 1); 
green = im2double(labeled == 2); 
blue =im2double(labeled == 3); 

image3 = im2double(image); 

red_f = red.*image3; 
green_f = green.*image3; 
blue_f = blue.*image3; 