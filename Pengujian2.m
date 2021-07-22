clc; clear; close all;

image_folder = 'New Citra Uji';
filenames = dir(fullfile(image_folder, '*.jpg'));
total_images = numel(filenames);

area = zeros(1,total_images);
perimeter = zeros(1,total_images);
metric = zeros(1,total_images);
eccentricity = zeros(1,total_images);
convexarea = zeros(1,total_images);
majoraxislength = zeros(1,total_images);
minoraxislength = zeros(1,total_images);
Contrast = zeros(1,total_images);
Correlation = zeros(1,total_images);
Homogeneity = zeros(1,total_images);
Energy = zeros(1,total_images);
for n = 1:total_images
    full_name= fullfile(image_folder, filenames(n).name);
    I = imread(full_name);
    J = I(:,:,2);
 %tresholding
    level = graythresh(J);
    K = im2bw(J,level);
    L = imcomplement(K);
    str = strel('disk',5);
    M = imclose(L,str);
    N = imfill(M,'holes');
    O = bwareaopen(N,5000);
    [glcms,SI] = graycomatrix(O,'Symmetric',true);
    stats2 = regionprops(O,'Area','Perimeter','Eccentricity','ConvexArea','MajorAxisLength','MinorAxisLength');
    stats = graycoprops(glcms,{'Contrast', 'Correlation' ,'Homogeneity','Energy'});
    area(n) = stats2.Area;
    perimeter(n) = stats2.Perimeter;
    metric(n) = 4*pi*area(n)/(perimeter(n)^2);
    eccentricity(n) = stats2.Eccentricity;
    convexarea(n) = stats2.ConvexArea;
    majoraxislength(n) = stats2.MajorAxisLength;
    minoraxislength(n) = stats2.MinorAxisLength;
    Contrast (n) = stats.Contrast;
    Correlation (n) = stats.Correlation;
    Homogeneity (n)= stats.Homogeneity;
    Energy (n)= stats.Energy;
end

input = [area;perimeter;metric;eccentricity;convexarea;majoraxislength;minoraxislength;Contrast;Correlation;Homogeneity;Energy];
target = zeros(1,57);
target(:,1:4) = 1;
target(:,5:15) = 2;
target(:,16:19) = 3;
target(:,20:33) = 4;
target(:,34:37) = 5;
target(:,38:43) = 6;
target(:,44:50) = 7;
target(:,51:54) = 8;
target(:,55:59 ) = 9;

load ('net2.mat')
output = round(sim(net,input));

[m,n] = find(output==target);
akurasi = sum(m)/total_images*100