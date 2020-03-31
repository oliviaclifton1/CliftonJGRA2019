function [ LAI ] = calc_lai_80016_wdir( )
%%   oeclifton
%%   TEXT S2
%   maps multiyear mean LAI for each wind sector (calculated with
%   calc_lai_by_plot.m) to hourly time series that is size (80016,1)
%   this script is for harvard forest 
%% read in LAI for each wind sector calculated with calc_lai_by_plot.n
load lai_harvard.mat 
%% create hourly time series for LAI from multiyear mean LAI
% for 10/28/1991 to 12/12/2000 
% LAI from northwest
laiq_mm = laiq_sw_avg_mm';
laiq_mm_leap = zeros(366,1);
laiq_mm_leap(1) = NaN;
laiq_mm_leap(2:366) = laiq_mm;
% october 28 - december 31 1991 
LAI_1991 = laiq_mm(301:365);
% jan 1 to december 12 2000
LAI_2000 = laiq_mm_leap(1:347);
%put all years together 
LAI = [LAI_1991;laiq_mm_leap;laiq_mm; ...
    laiq_mm;laiq_mm;laiq_mm_leap;laiq_mm; ...
    laiq_mm;laiq_mm;LAI_2000];
LAI = repmat(LAI, [1 24])'; 
LAI_sw = reshape(LAI, [1 numel(LAI)])';
clear LAI LAI_2000 LAI_1991 laiq_mm_leap laiq_mm laiq_sw_avg_mm
% LAI from southwest
laiq_mm = laiq_nw_avg_mm';
laiq_mm_leap = zeros(366,1);
laiq_mm_leap(1) = NaN;
laiq_mm_leap(2:366) = laiq_mm;
% october 28 - december 31 1991 
LAI_1991 = laiq_mm(301:365);
% jan 1 to december 12 2000
LAI_2000 = laiq_mm_leap(1:347);
%put all years together 
LAI = [LAI_1991;laiq_mm_leap;laiq_mm; ...
    laiq_mm;laiq_mm;laiq_mm_leap;laiq_mm; ...
    laiq_mm;laiq_mm;LAI_2000];
LAI = repmat(LAI, [1 24])'; 
LAI_nw = reshape(LAI, [1 numel(LAI)])';
clear LAI LAI_2000 LAI_1991 laiq_mm_leap laiq_mm laiq_nw_avg_mm
%% calculate LAI according to hourly wind direction
[~,~,~,wdir,~] = read_hf004();
LAI = zeros(80016,1); LAI(:,1)=NaN;
LAI(wdir>270) = LAI_nw(wdir>270);
LAI(wdir<=270) = LAI_sw(wdir<=270);
LAI(wdir~=wdir) = NaN; 
end