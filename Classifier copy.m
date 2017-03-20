%% Analyze Images

clc

%% Setup output
Output_file_name = 'good.tif';

%% Read in Thresholded image
I = imread('threshold_good.jpg');
level = graythresh(I);
I = im2bw(I,level);


%% Clean up/ Filter Image

% Filter Image for artifacts
% disk_size = 4; 
% 
% se2 = strel('disk',disk_size); 
% Final2 = im2double(I);
% Io = imopen(Final2,se2);
% Ie = imerode(Final2, se2);
% Iobr = imreconstruct(Ie, Final2);
% Iobrd = imdilate(Iobr, se2);
% Iobrcbr = imreconstruct(imcomplement(Iobrd), imcomplement(Iobr));
% Iobrcbr = imcomplement(Iobrcbr);
% Final_Filtered = Iobrcbr;
% Invert for white background
%Final_Filtered = imadjust(Iobrcbr, [0 1], [1 0]);

%% Label Image and find properties
labeled_image = bwlabel(I); 
Stats = regionprops(labeled_image,'All'); 

for n = 1:length(Stats)
  %  for j = 1:14
     mito_areas(n,1) = Stats(n,1).Area;
     mito_perimeters(n,1) = Stats(n,1).Perimeter;
     %mitobox
     mito_box(n,1) = Stats(n,1).BoundingBox(1);
     mito_box(n,2) = Stats(n,1).BoundingBox(2);
     mito_box(n,3) = Stats(n,1).BoundingBox(3);
     mito_box(n,4) = Stats(n,1).BoundingBox(4);
     % Create variables for other shape measures 
     mito_convexArea(n,1) = Stats(n,1).ConvexArea;
     %mito_convexHull(n,j) = Stats(1,n).cell(j,1).ConvexHull;
     mito_Eccentricity(n,1) = Stats(n,1).Eccentricity;
     mito_EquivDiameter(n,1) = Stats(n,1).EquivDiameter;
     mito_EulerNumber(n,1) = Stats(n,1).EulerNumber;
     mito_Extent(n,1) = Stats(n,1).Extent;
     mito_FilledArea(n,1) = Stats(n,1).FilledArea;
     mito_MajorAxisLength(n,1) = Stats(n,1).MajorAxisLength;
     mito_MinorAxisLength(n,1) = Stats(n,1).MinorAxisLength;
     mito_Solidity(n,1) = Stats(n,1).Solidity;
     
     % Calculated Shape Descriptors
     mito_Aspect_Ratio(n,1) = mito_MajorAxisLength(n,1)/...
         mito_MinorAxisLength(n,1);
     mito_Form_Factor(n,1) = (mito_perimeters(n,1))^2/(4*pi*mito_areas(n,1));
  
     % Create variables indicating locations of cells  
     %mito_WeightedCentroid(n,j) = Stats(1,n).cell(j,1).WeightedCentroid;
     mito_Orientation(n,1) = Stats(n,1).Orientation;
   
        % Find sizes of boxes in terms of area
    box_areas(n,1) = mito_box(n,3)*mito_box(n,4);
     
end

% Combine into a single variable for classification
for j=1:length(Stats)
class_var(j,1)= mito_areas(j,1); %1
class_var(j,2) = mito_perimeters(j,1); %2
class_var(j,3) = box_areas(j,1); %3
class_var(j,4) = mito_convexArea(j,1); %4
class_var(j,5) = mito_Eccentricity(j,1); %5
class_var(j,6) = mito_EquivDiameter(j,1); %6
class_var(j,7) = mito_EulerNumber(j,1); %7
class_var(j,8) = mito_Extent(j,1); %8
class_var(j,9)= mito_FilledArea(j,1); %9
class_var(j,10) = mito_MajorAxisLength(j,1); %10
class_var(j,11) = mito_MinorAxisLength(j,1); %11
class_var(j,12) = mito_Solidity(j,1); %12
class_var(j,13) = mito_Aspect_Ratio(j,1); %13
class_var(j,14) = mito_Form_Factor(j,1); %14
end

%% Classify Mitochondria in the image
%Read in Training Set
White_Wine = dataset('xlsfile', '4-Set_Training_Set_revised.xlsx');
X = double(White_Wine(:,1:14));
Y = double(White_Wine(:,15));
c = cvpartition(Y,'holdout',.1);

% Rerun the Bagged decision tree with a test set and a training set
X_Train = X(training(c,1),:);
Y_Train = Y(training(c,1));

b2 = TreeBagger(250,X_Train,Y_Train,'oobvarimp','on');
oobError(b2, 'mode','ensemble')

X_Test = X(test(c,1), :);
Y_Test = Y(test(c,1));

% Use the training classifiers to make Predictions about the test set
[Predicted, Class_Score] = predict(b2,X_Test);
Predicted = str2double(Predicted);
[conf, classorder] = confusionmat(Y_Test,Predicted);
conf

% Calculate what percentage of the Confusion Matrix is off diagonal
Error3 =  1 - trace(conf)/sum(conf(:))
% 
% % Predication
 [Forest_Predicted_f_set, Class_Score] = predict(b2,class_var(:,:));
 Forest_Predicted_f_set = str2double(Forest_Predicted_f_set);

%% Output data for all Mitochondria in the Image

% Fragemented 
fragmented = sum(Forest_Predicted_f_set==1)/length(Stats);

% Intermediate 
intermediate = sum(Forest_Predicted_f_set==2)/length(Stats);

% Elongated 
elongated = sum(Forest_Predicted_f_set==3)/length(Stats);

% Donuts
donuts = sum(Forest_Predicted_f_set==4)/length(Stats);

% Average Length
Length = mean(mito_MajorAxisLength);

STDLength = std(mito_MajorAxisLength);

%% Produce Color Image of Segmentation
colormap = [ 0 0 1 
             0 1 0
             1 0 0
             0 1 0];

 [labeled num] = bwlabel(labeled_image);
    stats = regionprops(labeled,'PixelIdxList');
    
    for k = 1:numel(Stats)
    kth_object_idx_list = Stats(k).PixelIdxList;
    labeled(kth_object_idx_list) = Forest_Predicted_f_set(k);
    end         
         
color_label = label2rgb(labeled, colormap, [0 0 0]);          

pcolormap = [ 1 0 0
             0 1 0
             0 0 1
             0 1 0];
pcolor_label = label2rgb(labeled, pcolormap);

%% Save Classified Image
color_name = 'Color';
pcolor_name = 'pColor';


imwrite(color_label, [color_name Output_file_name ], 'tiff'); 
imwrite(pcolor_label, [pcolor_name Output_file_name ], 'tiff'); 


