function [ o3ddv ] = read_o3ec_filter_kane( )
%% oeclifton
%% TEXT S1
% this function reads in ozone concentrations from the fast sensor 
% and ozone eddy covariance fluxes from Kane Experimental Forest
% and calculates an ozone deposition velocity 
%% load half-hourly data from Kane (o3flux, o3f, tv)

%% remove values w erroneous temperature measurements 
% (e.g., Tv greater than 100ºC and Tv less than -10ºC 
% during the growing season) 
ind = tv_kane>100 | tv_kane < -10;
o3f_kane(ind)=NaN;
disp(sum(ind));
%% convert half-hourly data to hourly data
o3flx_kane = reshape(o3flx_kane, [2 length(o3flx_kane)/2]);
o3flx_kane = mean(o3flx_kane,1); 
o3f_kane = reshape(o3f_kane, [2 length(o3f_kane)/2]);
o3f_kane = mean(o3f_kane,1); 
%% calculate ozone deposition velocity
o3ddv = -1.*(o3flx_kane./o3f_kane)*100; % in cm/s
%% filter data
o3ddv(abs(o3ddv)>10)=NaN;
tempstd = std(o3ddv, 'omitnan');
tempmean = nanmean(o3ddv); 
o3ddv(o3ddv > tempmean + 3*tempstd | o3ddv < tempmean - 3*tempstd) = NaN;
disp(tempmean); disp(tempstd);clear tempmean; clear tempstd;
end

