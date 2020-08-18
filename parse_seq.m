function [pre_im, laser_im, post_stack] = parse_seq(seq_cell)
%%parse_seq parses the two ND2 files in a FRAP sequence
%
%   input :
%       seq_cell : A cell array containing the strings specifying the two
%       ND2 Sequence files. The first ND2 file should contain the Trans,
%       Pre-bleach, and laser images. The second ND2 file contains the
%       subsequent timelapse.
%
%   ouputs :
%       pre_im : A 2D matrix containing the pre-bleach image.
%
%       laser_im : A 2D matrix containing the laser image.
%
%       post_stack : A 3D matrixing containing the post-bleach timelapse.
%       Third dimension is time.

%% Use bfopen to parse files
pre_cell = bfopen(seq_cell{1});
pre_im = pre_cell{1,1}{2,1};
laser_im = pre_cell{1,1}{3,1};
post_stack = bf2mat(bfopen(seq_cell{2}));