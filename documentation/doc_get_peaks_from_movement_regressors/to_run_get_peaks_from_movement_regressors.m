%% To run get_peaks_from_movement_regressors.m
%
%% Credit and date
% Code developed by Oscar Miranda-Dominguez.
%
% First line of documentation: NOvember 11, 2019
%% Intro
%
% This function identifies the peak in the spectrum
%% Repo location
% https://github.com/DCAN-Labs/movement_regressors_power_plots

%% Basic usage
% The two mandatory input arguments for this function are:
%
% # the path to the Movement Regressors files made by the pipelin. in this
% casi it is only the path to a single file (not a cell with paths to
% multiple Movement Regressors files as in cat_mov_reg_power
% # TR, BOLD's repetition time
%
%% Example 1
%
% 

% cd /mnt/max/shared/code/internal/utilities/mov_reg_power % move to the folder to save the data
f=filesep;
TR=0.8;% TR in seconds

ver=1;
% Path to Movement regressors file
dest_path='P:\code\internal\utilities\OSCAR_WIP\movement_regressors_power_plots\mov_reg_files\subject_with_PMU_data';
path_mov_reg=[dest_path f 'random_ix_1_ver' num2str(ver) '_Movement_Regressors.txt'];

peaks_at = get_peaks_from_movement_regressors(path_mov_reg,TR)
%% Show peaks in the figure
CLIM=power_per_Resting(path_mov_reg,TR,'show_line_peak_power',1);
