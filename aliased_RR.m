function [T,RRa_Hz] = aliased_RR(RR_bpm,TR)

%% RR_HZ = aliased_RR(RR_bpb,TR)

%% Credits and date
%
% Oscar Miranda-Dominguez
% First line of code: Nov 11, 2019
%
%% Basic usage
%
% This function displays the aliased frequency in Hz of a signal in events
% per minute (RR_bpm). YOu also need to provide the TR in seconds
%
% Example, if you like to calculate the aliases respiration rate of 12,
% 12.5,... 25 breaths per minute at a TR of 2.2. you need to do the
% following:
%
% RR_bpm=12:3:25;% respiration rate (RR_bpm)in breaths per minute
% TR=2.2; TR in seconds
% [T,RRa_Hz] = aliased_RR(RR_bpm,TR);
%% Define a title

tit=['Aliased frequencies at a TR of ' num2str(TR) ' seconds'];


%%
% Calculate the provided signal in Hz
RR_Hz=RR_bpm/60; %RR_bpm in Hz

fs = 1/TR;% sampling frequency
fNy=fs/2; % nyquist frequency
RRa_Hz=abs(RR_Hz-floor((RR_Hz+fNy)/fs)*fs);

T=table(num2str(RR_bpm','%4.1f'),RR_Hz',RRa_Hz');
T=table(num2str(RR_bpm','%4.1f'),num2str(RR_Hz','%4.3f'),num2str(RRa_Hz','%4.4f'));
T.Properties.VariableNames{1}='Resp_rate_bpm';
T.Properties.VariableNames{2}='Resp_rate_Hz';
T.Properties.VariableNames{3}='Resp_rate_aliased_Hz';
T.Properties.Description=tit;
disp(tit)
disp(T)


