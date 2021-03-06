% This script calculate the number of rice grains of a sample image to show
% how our method works.

clear;clc;close all;
% Read image and binarize it
img = imread('sample_image.jpg');
img_bina = imbinarize(img);
% Show the image
figure; imshow(img_bina,[]);
% Calculate the estimated number of rice grains in the image with area
% method. The average area of each rice grains is 2670.268571428571, which
% is obtained by the script get_average_area.m.
np_base = bwarea(img_bina) / 2670.268571428571;
% Get the edge coordinates of each connected regions
[all_component, L] = bwboundaries(img_bina);
% Get the number of connected regions
num_component = size(all_component, 1);

% Get the area of each connected regions
area_component = cell(num_component,1);
area_all = zeros(num_component,1);
for i = 1:num_component
     [r, c] = find(L==i);
     area_component{i,1} = [r ,c];
     area_all(i) = length(r);
end

% Get the distance(1-D sequence) of edge to the main axis in each 
% connected regions.
dist = cell(num_component, 1);
for i = 1:num_component
    dist{i,1} = cal_dist_point_line(flip(all_component{i,1},2));
end

% Calculate the number of grains in each connected regions
area_fix = zeros(length(area_all), 1);
for i = 1:length(area_all)
    x = dist{i};
    % Wavelet transform
    [wt,f] = con_wavelet_t(x,0);
    % Wavelet reconstruction in 10.5595Hz to 64Hz
    xrec = icwt(wt,f,[max(10.5595,min(f)),min(max(f),64)],'amor');
    % Wavelet transform to reconstructed signal
    [wt,f] = con_wavelet_t(xrec,0);
    % Get the fixed coefficient
    k0 = cal_wavelet_fre(wt,f) / 10.5595; 
    % Calculate the fixed area in the region with base area
    % and the fixed coefficient.
    area_fix(i) = area_all(i) * k0 ;
    % This is a strategies to fix the area which has showed in the paper
    if area_fix(i) < 2670.268571428571
        area_fix(i) = 2670.268571428571;
    end
end
% Calculate the number of rice grains in each connected region using fixed
% area of each regions.
np_rice = area_fix ./ 2670.268571428571;

% The real number of rice grains in our sample image is 107.
np_real_rice = 107;

disp(['The real number of rice grains is: ', num2str(np_real_rice)]);
disp(['The calculation value is : ',num2str(sum(np_rice))]);
disp(['The calculation accuracy is : ',...
    num2str((1 - abs(sum(np_rice)-np_real_rice)/np_real_rice)* 100), '%']);








