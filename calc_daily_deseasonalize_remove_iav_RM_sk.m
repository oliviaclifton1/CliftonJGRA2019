function [med_day_anom] = calc_daily_deseasonalize_remove_iav_RM_sk(time, metvar, thresholddaily,  beghr,finhr)
%% oeclifton
%% TABLE 1, FIGURE 2, TEXT S6
% creates daily median data, then de-seasonalizes & takes out IAV with 30
% day running mean for hourly data
% thresholddaily is the number of hours you will allow to have missing data
% in the calculation of the daytime median
% this is for kane and sand flats data 

ndays = length(time)/24;

temp = reshape(metvar, [24 ndays]);
daytime = temp(beghr:finhr,:);
%count how many nans are in daytime for each day
count = sum(isnan(daytime));
%if number of nans is greater than threshold then set as NaN
daytime(:,count > thresholddaily) = NaN;
med_day =  median(daytime,1,'omitnan');clear temp daytime count 

% calculate 30 day backwards running mean
med_day_30rm = NaN(1,ndays);
for i = 30:ndays
    if sum(~isnan(med_day(i-29:i))) >= 7
        med_day_30rm(i) = nanmean(med_day(i-29:i)); 
    end
end
%calculate anomaly
med_day_anom = med_day-med_day_30rm; 

end