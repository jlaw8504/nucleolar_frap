function [exponents, norm_mat, frap_mat] = frap_analysis_dir(dir_name, num_timepoints)
%%frap_analysis_dir performs FRAP analysis on all ND2 files in a directory.
%
%   inputs : 
%       dir : A string variable specifying the directory containing the ND2
%       sequence files to parse
%
%       num_timepoints : A scalar variable specifying the number of time
%       points in the timelapse following laser bleaching
%
%   outputs :
%       exponenets : A vector containing the exponential coefficients for
%       each normalized recovery curve, excluding the pre-bleach value.
%
%       norm_mat : A 2D matrix containing the normalized recovery curves.
%       Each row is a recovery curve and each column represents a time
%       point. The first value in the recovery curve, corresponding to the
%       pre-bleach intensity value, is set to 1.
%
%       frap_mat : A 2D matrix containing the background-subtracted,
%       photo-bleach corrected, mean intensity values for the bleached
%       region. Only the post-bleach values are included in this curve.
nd2_files =  dir(fullfile(dir_name, '*.nd2'));
bleach_area_array = zeros([numel(nd2_files)/2, 1]);
frap_mat = zeros([numel(nd2_files)/2, num_timepoints]);
norm_mat = zeros([numel(nd2_files)/2, num_timepoints + 1]);
exponents = zeros([numel(nd2_files)/2, 1]);
idx = 1;
times = transpose([0:49]/30); %s
for n = 1:2:numel(nd2_files)
    cell_seq = {nd2_files(n).name, nd2_files(n+1).name};
    [pre_im, laser_im, post_stack] = parse_seq(cell_seq);
    [fg_bin, bg_bin, ~, laser_bin, pre_val] = ...
        binary_process(pre_im, laser_im);
    area_bleach = 1 - sum(bg_bin(:))/sum(fg_bin(:));
    frap_means = bleach_corr(post_stack, laser_bin);
    norm_means = frap_means/pre_val;
    exp_fit = fit(times, norm_means, 'exp1');
    coeffs = coeffvalues(exp_fit);
    exponents(idx) = coeffs(end);
    frap_mat(idx,:) = frap_means';
    norm_mat(idx,:) = [1, norm_means'];
    bleach_area_array(idx) = area_bleach;
    idx = idx + 1;
end