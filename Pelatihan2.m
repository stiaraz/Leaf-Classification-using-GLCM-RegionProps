clc; clear; close all;

image_folder = 'New Citra Latih';
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
    offsets = [-1 1];
    glcms = graycomatrix(O,'offset',offsets,'Symmetric',true);
    stats2 = regionprops(O,'Area','Perimeter','Eccentricity','ConvexArea','MajorAxisLength','MinorAxisLength');
    stats = graycoprops(glcms,{'Contrast','Correlation','Energy', 'Homogeneity'});
    area(n) = stats2.Area;
    perimeter(n) = stats2.Perimeter;
    metric(n) = 4*pi*area(n)/(perimeter(n)^2);
    eccentricity(n) = stats2.Eccentricity;
    convexarea(n) = stats2.ConvexArea;
    majoraxislength(n) = stats2.MajorAxisLength;
    minoraxislength(n) = stats2.MinorAxisLength;
    Contrast(n) = stats.Contrast;
    Correlation(n) = stats.Correlation;
    Homogeneity(n) = stats.Homogeneity;
    Energy(n) = stats.Energy;
end

input = [area;perimeter;metric;eccentricity;convexarea;majoraxislength;minoraxislength;Contrast;Correlation;Homogeneity;Energy];
target = zeros(1,78);
target(:,1:8) = 1;
target(:,9:21) = 2;
target(:,22:27) = 3;
target(:,28:40) = 4;
target(:,41:47) = 5;
target(:,48:54) = 6;
target(:,55:64) = 7;
target(:,65:71) = 8;
target(:,72:78) = 9;

net = newff(input,target,[11 6],{'logsig','logsig'},'trainlm');
net.trainParam.epochs = 1000;
net.trainParam.goal = 1e-6;
akurasi = 0;
ct = 0;
while (akurasi < 90 && ct < 150) 
    ct = ct+1;        
    net = train(net,input,target);
    output = round(sim(net,input));
    [m,n] = find(output==target);
    akurasi = sum(m)/total_images*100;
end
save net3.mat net
akurasi