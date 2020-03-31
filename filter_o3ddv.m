function [ o3ddv ] = filter_o3ddv( )
%% oeclifton 
%% TEXT S1
% this script loads ozone deposition velocity (o3ddv) calculated with 
% calc_o3ddv_stp_harvard.m and filters it for near zero values then for
% outliers

%% load ozone deposition velocity (o3ddv) calculated with calc_o3ddv_stp.m
% ATTN! must load time series starting at 1/1/1990

%% remove periods of 0 that are not removed w/ removing periods of
% missing turbulent fluxes
o3ddv(7942+1:  7945+24) = NaN; %nov 1990, double checked this range, includes bad data periods and no more
o3ddv(24753+8: 24806+22) = NaN; %oct 1992, double checked this range, includes bad data periods and no more
o3ddv(25309: 25359+24) = NaN; %nov 1992,double checked this range, includes bad data periods and no more
o3ddv(84803+4: 84860+15) = NaN; %sept 1999, includes bad data periods and no more
%% filter o3ddv for outliers 
tempstd = std(o3ddv, 'omitnan');
tempmean = nanmean(o3ddv); 
o3ddv(o3ddv > tempmean + 3*tempstd | o3ddv < tempmean - 3*tempstd) = NaN;
disp(tempmean); disp(tempstd);clear tempmean; clear tempstd;
end

