%% To run aliased_RR
%
%
%% Credit and date
% Code developed by Oscar Miranda-Dominguez.
%
% First line of documentation: November 11, 2019
%% Intro
%
% This function displays the aliased frequency in Hz of a signal in events
% per minute (RR_bpm). YOu also need to provide the TR in seconds
%% Repo location
% https://gitlab.com/Fair_lab/movement_regressors_power_plots
%% Dependencies:
%
% NO extra dependencies needed
% 
%% Basic usage
%
% if you like to calculate the aliases respiration rate of 12,
% 12.5,... 25 breaths per minute at a TR of 2.2. you need to do the
% following:
%
RR_bpm=12:3:25;% respiration rate (RR_bpm)in breaths per minute
TR=2.2; % TR in seconds
[T,RRa_Hz] = aliased_RR(RR_bpm,TR);