function [fg_bin, bg_bin, ref_bin, laser_bin, pre_val] = binary_process(pre_im, laser_im)
%%binary_process parses the pre-bleach image and the laser image to
%%automatically select the foreground/bleached cell and the other
%%reference/unbleached cells.
%
%   inputs :
%       pre_im : A 2D matrix containing the pre-bleach image.
%
%       laser_im : A 2D matrix containing the laser image.
%
%   outputs :
%       fg_binary : A 2D matrix containing a single binary object that
%       corresponds to the bleached cell.
%
%       ref_binary : A 2D matrix containing multiple binary objects that
%       correspond to the unbleach cells.
%
%       laser_bin : A 2D matrix containing a single binary object that
%       corresponds to bleached region.
%
%       pre_val : A scalar variable containing the mean intensity value
%       withing the bleached region prior to laser bleaching. Commonly used
%       to normalized the recovery curve.
%% Thresholding of pre and laser images
pre_threshs = multithresh(pre_im, 2);
bg_mean = mean(pre_im(pre_im < pre_threshs(1)));
laser_thresh = multithresh(laser_im, 3);
%% Generate binary images
pre_bin = pre_im > pre_threshs(end);
laser_bin = laser_im > laser_thresh(end);
%% Select binary object in pre_bin that co-localizes with laser_bin object
%ensure there is only one laser_bin object
laser_cc = bwconncomp(laser_bin);
if laser_cc.NumObjects ~= 1
    obj_sizes = cellfun(@numel, [laser_cc.PixelIdxList]);
    [~, max_idx] = max(obj_sizes);
    laser_bin = false(size(laser_bin));
    laser_bin(laser_cc.PixelIdxList{max_idx}) = true;
    laser_cc = bwconncomp(laser_bin);
end
pre_cc = bwconncomp(pre_bin);
obj_idx = nan;
for n = 1:pre_cc.NumObjects
    if ~isempty( ...
            intersect( ...
            pre_cc.PixelIdxList{n}, laser_cc.PixelIdxList{1}))
        obj_idx = n;
        continue
    end
end
%% Create fg_bin from blank image
fg_bin = zeros(size(pre_im));
fg_bin(pre_cc.PixelIdxList{obj_idx}) = 1;
fg_bin = boolean(fg_bin);
%% Create bg_bin by removing laser_bin from fg_bin
bg_bin = fg_bin;
bg_bin(laser_bin) = false;
%% Create ref_bin by removing fg binary object from pre_bin
ref_bin = pre_bin;
ref_bin(pre_cc.PixelIdxList{obj_idx}) = false;
%% Calculate the intensity value for bleach region of pre-bleach image
pre_val = mean(pre_im(laser_bin)) - bg_mean;
