function frap_means = bleach_corr(post_stack, laser_bin)
%%bleach_corr removed background from stack and corrects for photobleaching
%
%   input :
%       post_stack : A 3D matrixing containing the post-bleach timelapse.
%       Third dimension is time.
%
%       laser_bin : A 2D matrix containing a single binary object that
%       corresponds to bleached region.
%
%   ouput :
%       frap_means : An array containing the mean intensity values of the
%       photobleached region.

%% Use mulithresh for mean background subtraction
bg_stack = zeros(size(post_stack));
fluor_means = zeros([size(post_stack,3),1]);
bg_means = zeros([size(post_stack,3),1]);
for t = 1:size(post_stack, 3)
    frame = post_stack(:,:,t);
    bg_threshs = multithresh(frame, 2);
    bg_means(t) = mean(frame(frame < bg_threshs(1)));
    fg_mean = mean(frame(frame > bg_threshs(2)));
    fluor_means(t) = fg_mean - bg_means(t);
end
coeffs = polyfit(1:size(post_stack,3), fluor_means,1);
frap_means = zeros([size(post_stack,3),1]);
for t = 1:size(post_stack, 3)
    frame = post_stack(:,:,t);
    frap_mean = mean(frame(laser_bin));
    frap_means(t) = frap_mean - bg_means(t) - coeffs(1)*t;
end